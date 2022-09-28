# compartment作成
resource "oci_identity_compartment" "compartment" {
    compartment_id = var.compar_id
    description = var.compar_desc
    name = var.compar_name
}

# vcn 作成
resource "oci_core_virtual_network" "vcn" {
    cidr_block     = var.vcn_cidr
    compartment_id = oci_identity_compartment.compartment.id
    dns_label = var.vcn_dns_label
    display_name = var.vcn_display_name
}

# internet gw 作成
resource "oci_core_internet_gateway" "igw" {
    compartment_id = oci_identity_compartment.compartment.id
    vcn_id = oci_core_virtual_network.vcn.id
    display_name = var.igw_display_name
    enabled = true
}

# route table
resource "oci_core_route_table" "route_table" {
    compartment_id = oci_identity_compartment.compartment.id
    route_rules {
        network_entity_id = oci_core_internet_gateway.igw.id
        destination = "0.0.0.0/0"
    }
    vcn_id = oci_core_virtual_network.vcn.id
    display_name = var.public_route_table_name
}

# security_list
resource "oci_core_security_list" "security_list" {
    compartment_id = oci_identity_compartment.compartment.id
    egress_security_rules {
        destination = "0.0.0.0/0"
        protocol = "6"
        stateless = false
        }

    dynamic "ingress_security_rules" {
        for_each = var.mynetwork_allow
        content {
            source = ingress_security_rules.value
            protocol = "6"
            stateless = false
            description = ingress_security_rules.key
        }
    }

    ingress_security_rules {
        source = var.vcn_cidr
        protocol = "6"
        stateless = false
        description = "internal"
        }
    vcn_id = oci_core_virtual_network.vcn.id
    display_name = var.public_security_list_name
}


# public subnet
resource "oci_core_subnet" "subnet" {
    availability_domain = var.ad
    cidr_block = var.public_cidr_block
    compartment_id = oci_identity_compartment.compartment.id
    security_list_ids = ["${oci_core_security_list.security_list.id}"]
    vcn_id = oci_core_virtual_network.vcn.id
    dns_label = var.public_dns_label
    prohibit_public_ip_on_vnic = "false"
    route_table_id = oci_core_route_table.route_table.id
    display_name = var.public_display_name
}

data "template_file" "init-server" {
    template = file("./scripts/init.sh")
}

resource "oci_core_instance" "instance" {
    count = var.instance_num
    availability_domain = var.ad
    compartment_id = oci_identity_compartment.compartment.id
    shape = var.instance_shape
    display_name = "${format("${var.instance_display_name}%02d", count.index + 1)}"
    create_vnic_details {
        display_name = "${format("${var.instance_display_name}%02d", count.index + 1)}"
        subnet_id = oci_core_subnet.subnet.id
        assign_public_ip = "true"
        private_ip = "${format("${var.third_octet}%d", count.index + 2)}"
    }
    shape_config {
        memory_in_gbs = var.mem_gb
        ocpus = var.cpu
    }
    source_details {
        source_id = lookup(var.CentOS7, "ap-tokyo-1")
        source_type = "image"
    }
    metadata = {
        ssh_authorized_keys = "${var.instance_ssh_public_key}"
        user_data = base64encode(join("\n", tolist([
            "#!/usr/bin/env bash",
            "set -x",
            (data.template_file.init-server.rendered)],
        )))
    }
}
