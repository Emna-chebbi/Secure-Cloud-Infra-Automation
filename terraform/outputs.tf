output "web_public_ip" {
  description = "Public IP of the web server"
  value       = azurerm_public_ip.web.ip_address
}

output "db_public_ip" {
  description = "Public IP of the database server"
  value       = azurerm_public_ip.db.ip_address
}

output "web_private_ip" {
  description = "Private IP of the web server"
  value       = azurerm_network_interface.web.private_ip_address
}

output "db_private_ip" {
  description = "Private IP of the database server"
  value       = azurerm_network_interface.db.private_ip_address
}

output "admin_username" {
  value = var.admin_username
}

output "ssh_private_key_path" {
  value = local_file.private_key.filename
}
