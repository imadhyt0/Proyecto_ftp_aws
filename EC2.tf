resource "aws_instance" "srv_ftp" {
  ami           = "ami-0ec10929233384c7f" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.sub_pub_ftp.id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.sg_ftp.id]
  

  iam_instance_profile = "LabInstanceProfile"

  user_data = file("FTP.sh")

  tags = { Name = "Servidor-FTP-Ubuntu" }
}

resource "aws_instance" "srv_ldap" {
  ami           = "ami-098e39bafa7e7303d" 
  instance_type = "t2.micro"
  private_ip    = "10.1.1.50"
  subnet_id     = aws_subnet.sub_priv_ldap.id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.sg_ldap.id]

  user_data = file("LDAP.sh")

  tags = { Name = "Servidor-LDAP-Privado" }
}