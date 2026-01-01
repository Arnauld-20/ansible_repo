variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
  default     = "ami-068c0051b15cdb816"
}

variable "ami_id_1" {
  description = "The AMI ID for the windows target instance"
  type        = string
  default     = "ami-06777e7ef7441deff"
}

# variable "instance_type" {
#   description = "The type of instance to use"
#   type        = string
#   default     = "t2.micro"
# }



variable "key_name" {
  description = "The name of the SSH key pair"
  type        = string
  default     = "ansible_keys"
}