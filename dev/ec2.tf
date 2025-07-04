resource "aws_instance" "github_runner" {
  ami                    = "ami-020cba7c55df1f615"
  instance_type          = "t2.micro"
  key_name               = "orca"
  subnet_id              = "subnet-0e6e74cce606d5543"
  vpc_security_group_ids = ["sg-03ceef03176846b70"]

  tags = {
    Name = "github_runner"
  }
}
