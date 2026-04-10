output "username" {
  value = "razumovsky_r"
}

output "blue_public_ip" {
  value = module.blue_slot.public_ip
}

output "green_public_ip" {
  value = module.green_slot.public_ip
}

output "blue_http" {
  value = "http://${module.blue_slot.public_ip}"
}

output "green_http" {
  value = "http://${module.green_slot.public_ip}"
}

output "blue_ssh" {
  value = "ssh razumovsky_r@${module.blue_slot.public_ip}"
}

output "green_ssh" {
  value = "ssh razumovsky_r@${module.green_slot.public_ip}"
}

output "copy_command_blue" {
  value = "ssh razumovsky_r@${module.blue_slot.public_ip} \"sudo cp /tmp/blue.html /var/www/html/index.nginx-debian.html && sudo systemctl restart nginx\""
}

output "scp_command_blue" {
  value = "scp ./html/blue.html razumovsky_r@${module.blue_slot.public_ip}:/tmp/blue.html"
}

output "copy_command_green" {
  value = "ssh razumovsky_r@${module.green_slot.public_ip} \"sudo cp /tmp/green.html /var/www/html/index.nginx-debian.html && sudo systemctl restart nginx\""
}

output "scp_command_green" {
  value = "scp ./html/green.html razumovsky_r@${module.green_slot.public_ip}:/tmp/green.html"
}


