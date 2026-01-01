resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = "t3.medium"
  key_name      = var.key_name
  tags = {
    Name = "my_ansible_instance"
  }
}

resource "aws_instance" "linux_target" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_name
  tags = {
    Name = "my_worker1_instance"
  }
}

resource "aws_instance" "windows_target" {
  ami           = var.ami_id_1
  instance_type = "t3.micro"
  key_name      = var.key_name
  tags = {
    Name = "my_worker2_instance"
  }
}
