#!/usr/bin/env bash
set -eo pipefail

## Globals ##
# Get script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RED="\033[0;31m"
NC="\033[0m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
CMD=${1}
GITHUB_AUTH=${GITHUB_AUTH:?"Specify GH Auth for packages registry. https://dev.to/asizikov/using-github-container-registry-with-kubernetes-38fb"}

trap 'handle_error' ERR SIGTERM SIGQUIT SIGINT

print_error() {
  echo -e "❌ ${RED}$1${NC}"
}

print_success() {
  echo -e "✅ ${GREEN}$1${NC}"
}

print_info() {
  echo -e "✍️  ${BLUE}$1${NC}"
}

command_exists () {
  command -v "$1" >/dev/null 2>&1
}

handle_error() {
    print_error "An error occurred. Exiting script..."
    print_info "Script does not shutdown the minikube cluster and does not uninstall helm resources automatically!"
    print_info "Please clean up manually before running script again."
    exit 1
}

print_help() {
  print_error "No command was passed"
  print_info "Usage: $0 <command>"
  echo -e "\tPlease specify a command to run."
  echo -e "\tExample: $0 apply - to create minikube cluster and install observabilitty stack dependecies + demo apps."
  echo -e "\tExample: $0 destroy - to destroy created components."
  exit 1
}

# Validate if dependencies for running start-up script are fulfilled
validate() {
  # check if minikube/helm/terraform are installed
  print_info "Checking dependencies."
  if ! command_exists minikube || ! command_exists helm || ! command_exists terraform || ! command_exists yq; then
    print_error "One or more required commands (Minikube, Helm, Terraform) are not installed; exiting"
    exit 1
  fi
  print_success "All needed dependencies are installed."
}

minikube_create() {
    local args=("--nodes" "3")
    print_info "Creating minikube cluster..."
    minikube start "${args[@]}"
    print_success "Created cluster."
}

tf_apply() {
  # clean up possible local left-overs
  rm -rf .terraform* terraform.tfstate*

  # Run terraform
  print_info "Running terraform..."

  terraform init -input=false
  terraform apply -input=false -auto-approve -compact-warnings -var "py_logging_gh_token=${GITHUB_AUTH}"

  print_success "Applied terraform config."
}

ask_yes_no() {
    while true; do
        print_info "${1}"
        read yn
        case $yn in
            [Yy]* ) 
              print_info "Proceeding with the script."
              return 0
            ;;
            [Nn]* )
              print_info "Declained."
              exit 1
            ;;
            * ) 
              print_info "Please answer y or n."
              exit 1
            ;;
        esac
    done
}

setup_grafana_connection() {
  # setup port-forward
  kubectl port-forward "svc/"$(kubectl get svc -n "demo-monitoring" \
    --no-headers -o custom-columns=":metadata.name" | grep "grafana") 8080:80 -n demo-monitoring &

  # print info
  local grafana_admin_user=$(kubectl get secret monitoring-grafana -n demo-monitoring \
    -o yaml | yq -e '.data.admin-user' | base64 -d)
  local grafana_admin_pass=$(kubectl get secret monitoring-grafana -n demo-monitoring \
    -o yaml | yq -e '.data.admin-password' | base64 -d)

  echo
  print_info "Admin user: ${grafana_admin_user}"
  print_info "Admin pass: ${grafana_admin_pass}"
  print_info "Visit http://localhost:8080 to access Grafana web UI."
  echo
}

minikube_delete() {
  print_info "Shutting down minikube..."
  minikube delete
  print_success "Deleted minikube cluster."
}

tf_destroy() {
  print_info "Running tf destroy..."
  terraform apply -input=false -auto-approve -compact-warnings -destroy
  print_success "Deleted resources by terraform."
}

main() {
    print_info "Starting script..."
    # cd to config files repo
    cd "${SCRIPT_DIR}/../"

    # validate if all prerequisites are fulfilled
    validate

    # Get command
    if [ -z "$CMD" ]; then
      print_help
    fi

    # Run command
    case $CMD in
      apply)
        ask_yes_no "This will create minikube cluster and install obesrvability stack. Do you wish to proceed? [y/n]"
        minikube_create
        tf_apply
        setup_grafana_connection
      ;;
      destroy)
        ask_yes_no "This will delete minikube cluster and uninstall obesrvability stack. Do you wish to proceed? [y/n]"
        tf_destroy
        minikube_delete
      ;;
      *)
        print_help
      ;;
    esac 
}

main
