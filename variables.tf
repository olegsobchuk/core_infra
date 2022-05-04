variable "region" {
  description = "Default degion code"
  type        = string
  default     = "us-west-2"
}

variable "min_instance_type" {
  description = "Minimal free instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI 20.04-arm64"
  type        = string
  default     = "ami-036d46416a34a611c"
}
