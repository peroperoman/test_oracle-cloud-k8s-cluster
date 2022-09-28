variable "ad" {
  default = "xRCS:AP-TOKYO-1-AD-1"
}

variable "compar_id" {
  default = "{compar_id}"
}
variable "compar_desc" {
  default = "k8s-env"
}
variable "compar_name" {
  default = "k8s-cluster"
}


variable "vcn_cidr" {
  default = "10.1.3.0/24"
}

variable "vcn_dns_label" {
  default = "k8s"
}

variable "vcn_display_name" {
  default = "k8s-cluster"
}

variable "igw_display_name" {
  default = "k8s-cluster"
}

variable "public_route_table_name" {
  default = "k8s-cluster-public"
}

variable "mynetwork_allow" {
    type = map(string)
    default = {
        "my_network" = "{MY-NET}"
    }
}

variable "public_cidr_block" {
  default = "10.1.3.0/25"
}

variable "public_security_list_name" {
  default = "k8s-cluster"
}

variable "public_dns_label" {
  default = "k8spub"
}

variable "public_display_name" {
  default = "k8s-public"
}

# common
# variable "region" {
#     type = string
#     # default = "ap-tokyo-1"
# }

variable "instance_shape" {
  default = "VM.Standard.E4.Flex"
}

variable "mem_gb" {
    default = "16"
}

variable "cpu" {
    default = "8"
}

variable "third_octet" {
    default = "10.1.3."
}

variable "CentOS7" {
    type = map(string)
    default = {
        ap-tokyo-1 = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaam73mdzeiq25bc6psd5b2xklwwbak556atcrkykvuii22fxvq3vwa"
        ap-osaka-1 = "ocid1.image.oc1.ap-osaka-1.aaaaaaaa2pmn54xv2awwtrmmthvlhnt6fsmxzise6suxcvaa335q6evevnxq"
        }
}

variable "instance_ssh_public_key" {
    default = "{PUB_KEY}"
}

variable "instance_num" {
    type = number
    default = "3"
}

variable "instance_display_name" {
    default = "k8s1"
}
