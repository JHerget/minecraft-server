output "elastic_ip" {
  description = "Elastic IP address for the Minecraft server."
  value       = aws_eip.minecraft.public_ip
}

output "minecraft_server_address" {
  description = "Address to use from Minecraft Java Edition."
  value       = "${aws_eip.minecraft.public_ip}:25565"
}

output "instance_id" {
  description = "EC2 instance ID."
  value       = aws_instance.minecraft.id
}

output "ssh_command" {
  description = "SSH command, if you allowed your IP in ssh_allowed_cidrs."
  value       = "ssh -i ${path.module}/minecraft-server.pem ec2-user@${aws_eip.minecraft.public_ip}"
}

output "private_key_path" {
  description = "Local path to the generated EC2 SSH private key."
  value       = local_sensitive_file.minecraft_private_key.filename
}
