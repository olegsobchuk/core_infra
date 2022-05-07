variable "region" {
  type = string
}

variable "vpc_id" {
  description = "used VPC id"
  type        = string
}

variable "instance_type" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "is_public_ip" {
  description = "Is public IP allowed"
  type        = bool
  default     = false
}
