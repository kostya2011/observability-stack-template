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
GITHUB_TOKEN=${GITHUB_TOKEN:?"Specify GH PAT. https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens"}

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
  if ! command_exists minikube || ! command_exists helm || ! command_exists terraform; then
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
  terraform apply -input=false -auto-approve -compact-warnings

  print_success "Applied terraform config."
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
        minikube_create
        tf_apply
        setup_grafana_connection
      ;;
      destroy)
        tf_destroy
        minikube_delete
      ;;
      *)
        print_help
      ;;
    esac 
}

main
