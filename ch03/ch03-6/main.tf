variable "string" {
  type = string
  description = "var String"
  default = "myString"
}

variable "number" {
  type = number
  default = 123
}

variable "boolean" {
  default = true    
}

variable "list" {
  default = [
    "google",
    "vmware",
    "amazon",
    "microsoft"
  ]
}

output "list_index_0" {
  value = var.list.0
}

output "list_all" {
  value = [
    for name in var.list :
        upper(name)
  ]
}

variable "map" {  # Sorting
  default = {
    aws = "amazon",
    azure = "microsoft",
    gcp = "google"
  }
}

variable "set" {  # Sorting
  type = set(string)
  default = [
    "google",
    "vmware",
    "amazon",
    "microsoft"
  ]
}

variable "object" {
  type = object({name = string, age = number})
  default = {
    name = "abc"
    age = 12
  }
}

variable "tuple" {
  type = tuple([string, number, bool])
  default = ["abc", 123, true]
}

variable "ingress_rules" {  # optional ( >= terraform 1.3.0)
  type = list(object({
    port = number,
    description = optional(string),
    protocol = optional(string, "tcp"),
  }))
  default = [
    { port = 80, description = "web" },
    { port = 53, protocol = "udp" }
  ]
}

variable "region" {
  default = "ap-northeast-2"
}

resource "aws_instance" "aws-5-web" {
  region = var.region
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  availability_zone =  "${var.region}a"
  key_name = aws05-key.pem
  vpc_security_group_ids = data.aws_security_group.sg-5-web.id
}