variable "region" {
  default = "us-east-1"
}

variable "key_name" {
  description = "Nombre de tu llave .pem de AWS"
  default     = "vockey" # Cambia esto por el nombre de tu llave
}

variable "empresa_name" {
  default = "imadSL"
}