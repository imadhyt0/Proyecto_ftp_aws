output "IP_Publica_FTP" {
  value = aws_instance.srv_ftp.public_ip
}

output "IP_Privada_LDAP" {
  value = aws_instance.srv_ldap.private_ip
}

output "IP_Publica_Monitoring" {
  value = aws_instance.srv_monitoring.public_ip
}