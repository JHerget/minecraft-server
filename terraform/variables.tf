variable "aws_region" {
  description = "AWS region where the Minecraft server will run."
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Name prefix for AWS resources."
  type        = string
  default     = "minecraft-server"
}

variable "instance_type" {
  description = "EC2 instance type. Increase this for larger worlds or more players."
  type        = string
  default     = "t3.large"
}

variable "key_name" {
  description = "Optional existing EC2 key pair name for SSH access."
  type        = string
  default     = ""
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed to SSH to the server."
  type        = list(string)
  default     = []
}

variable "minecraft_allowed_cidrs" {
  description = "CIDR blocks allowed to connect to the Minecraft server."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "root_volume_size_gb" {
  description = "Root EBS volume size in GB. This stores Docker and Minecraft world data."
  type        = number
  default     = 40
}
