variable "aws_region" {
  type        = string
  default     = "us-east-1" # You can change this to your preferred AWS region
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
}
