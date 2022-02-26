variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
  description = "prefix must be given in CIDR notation, as defined in RFC 4632 section 3.1."
}

variable "newbits_for_subnet_cidr" {
  default = 8
  description = "newbits is the number of additional bits with which to extend the prefix. For example, if given a prefix ending in /16 and a newbits value of 4, the resulting subnet address will have length /20"
}
