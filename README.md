# minecraft-server

Docker Compose and Terraform setup for a Minecraft Java Edition server on AWS.

The Compose stack uses `itzg/minecraft-server:latest`. The container downloads the latest stable vanilla Minecraft server at startup, and `VERSION: "LATEST"` keeps that intent explicit.

## Local Docker Compose

Start the server locally:

```sh
docker compose up -d
```

World data is stored in `./data`, which is ignored by Git.

Stop the server:

```sh
docker compose down
```

## AWS Deploy

Terraform creates:

- An EC2 instance using the latest Amazon Linux 2023 AMI in the selected region.
- A security group allowing Minecraft TCP traffic on `25565`.
- An Elastic IP attached to the instance.
- A systemd service that starts the Docker Compose Minecraft server on boot.

Prepare variables:

```sh
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`. If you want SSH access, set an existing EC2 `key_name` and add your public IP as a `/32` in `ssh_allowed_cidrs`.

Deploy:

```sh
terraform init
terraform apply
```

After apply completes, use the `minecraft_server_address` output in Minecraft Java Edition.

Destroy the AWS resources when you are done:

```sh
terraform destroy
```

## Server Settings

The server settings are in [docker-compose.yml](docker-compose.yml). The EC2 instance gets an equivalent Compose file through Terraform user data in [terraform/user_data.sh.tftpl](terraform/user_data.sh.tftpl).
