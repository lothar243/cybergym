variable "aws_access_key" {
  type = string
  sensitive = false
}

variable "aws_secret_access_key" {
  type = string
  sensitive = true
}

variable "project_name" {
  description = "A short name used to tag resources."
  type        = string
  default     = "ctfd"
}

variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-west-2"
}

variable "domain_name" {
  description = "Your root domain hosted in Route53 (e.g., example.com)."
  type        = string
}

variable "hosted_zone_id" {
  description = "Route53 Hosted Zone ID for the root domain."
  type        = string
}

variable "subdomain" {
  description = "Subdomain to use for CTFd (left side only)."
  type        = string
  default     = "ctfd"
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to SSH to the instance (e.g., your office/home IP)."
  type        = string
  default     = "0.0.0.0/0"
}

variable "instance_type" {
  description = "EC2 instance type for the CTFd host."
  type        = string
  default     = "t2.small"
}

variable "public_key" {
  description = "Your SSH public key (contents of ~/.ssh/id_rsa.pub or ed25519.pub)."
  type        = string
}

variable "ctfd_image" {
  description = "Docker image for CTFd."
  type        = string
  default     = "ctfd/ctfd:latest"
}

variable "ec2_disk_gb" {
  description = "Root EBS volume size (GiB)."
  type        = number
  default     = 20
}
