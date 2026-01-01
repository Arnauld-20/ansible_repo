resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  tags = {
    Name = "my_ansible_instance"
  }
}

resource "aws_instance" "linux_target" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  tags = {
    Name = "my_worker1_instance"
  }
}

resource "aws_instance" "windows_target" {
  ami           = var.ami_id_1
  instance_type = var.instance_type
  key_name      = var.key_name
  tags = {
    Name = "my_worker2_instance"
  }
}
