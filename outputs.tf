
output "minio_creds" {
  value = {
    name     = "root"
    password = random_string.minio_password.result
  }
}
