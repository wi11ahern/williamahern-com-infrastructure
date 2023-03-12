output "admin_node_private_key" {
  value     = tls_private_key.admin_node_ssh_key.private_key_pem
  sensitive = true
}