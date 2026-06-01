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
  description = "SSH command, if you provided a key pair and allowed your IP in ssh_allowed_cidrs."
  value       = var.key_name != "" ? "ssh ec2-user@${aws_eip.minecraft.public_ip}" : "Set key_name and ssh_allowed_cidrs to enable SSH."
}
