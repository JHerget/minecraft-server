# minecraft-server

Docker Compose and Terraform setup for a Minecraft Java Edition server on AWS.

The Compose stack uses `itzg/minecraft-server:latest`. The container downloads the latest stable vanilla Minecraft server at startup, and `VERSION: "LATEST"` keeps that intent explicit.

## Prerequisites

- Docker with Docker Compose v2 for local runs.
- Terraform `>= 1.6.0` for AWS deployment.
- AWS credentials configured locally, for example with `aws configure` or environment variables.

## Repository Layout

- [docker-compose.yml](docker-compose.yml) defines the Minecraft server container.
- [terraform/](terraform/) defines the AWS infrastructure and EC2 bootstrap script.
- `data/` is created at runtime and stores world data. It is intentionally ignored by Git.

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

Update the server container image:

```sh
docker compose pull
docker compose up -d
```

View logs:

```sh
docker compose logs -f minecraft
```

## AWS Deploy

Terraform creates:

- An EC2 instance using the latest Amazon Linux 2023 AMI in `us-west-2`.
- An EC2 key pair named `minecraft-server`.
- A local SSH private key at `terraform/minecraft-server.pem`.
- A security group allowing Minecraft TCP traffic on `25565`.
- An Elastic IP attached to the instance.
- A systemd service that starts the Docker Compose Minecraft server on boot.

Prepare variables:

```sh
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`. If you want SSH access, add your public IP as a `/32` in `ssh_allowed_cidrs`.

Example:

```hcl
ssh_allowed_cidrs       = ["203.0.113.10/32"]
minecraft_allowed_cidrs = ["0.0.0.0/0"]

instance_type       = "t3.xlarge"
root_volume_size_gb = 40
```

Deploy:

```sh
terraform init
terraform apply
```

After apply completes, use the `minecraft_server_address` output in Minecraft Java Edition.

Show outputs again later:

```sh
terraform output
```

SSH to the instance, if enabled:

```sh
ssh -i minecraft-server.pem ec2-user@$(terraform output -raw elastic_ip)
```

On the instance, the Compose project lives in `/opt/minecraft-server`.

Useful instance commands:

```sh
sudo systemctl status minecraft-compose.service
cd /opt/minecraft-server
sudo docker compose logs -f minecraft
sudo docker compose pull
sudo systemctl restart minecraft-compose.service
```

Destroy the AWS resources when you are done:

```sh
terraform destroy
```

## Server Settings

The server settings are in [docker-compose.yml](docker-compose.yml). The EC2 instance gets an equivalent Compose file through Terraform user data in [terraform/user_data.sh.tftpl](terraform/user_data.sh.tftpl).

If you change server settings, update both files so local and AWS behavior stay aligned. Terraform will replace the EC2 instance when `user_data.sh.tftpl` changes.

## Notes

- The Minecraft EULA is accepted with `EULA: "TRUE"` in the Compose environment.
- Port `25565/tcp` is opened for Minecraft Java Edition.
- The default server name is `Hergetron's Server`.
- The default view distance is `32` chunks.
- The default EC2 instance type is `t3.xlarge`.
- The default Minecraft memory allocation is `12G`.
- Do not commit `data/`, `terraform.tfvars`, `minecraft-server.pem`, or Terraform state files.
