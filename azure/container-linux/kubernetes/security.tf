# Security Groups (instance firewalls)

# Controller security group

resource "azurerm_network_security_group" "controller" {
  name                = "${var.cluster_name}-controller"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  tags {
    name = "${var.cluster_name}-controller"
  }
}

resource "azurerm_network_security_rule" "controller-egress" {
  name                        = "controller-egress"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.controller.name}"
}

resource "azurerm_network_security_rule" "controller-ssh" {
  name                        = "controller-ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.controller.name}"
}

resource "azurerm_network_security_rule" "controller-apiserver" {
  name                        = "controller-apiserver"
  priority                    = 150
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "${var.controller_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.controller.name}"
}

resource "azurerm_network_security_rule" "controller-etcd" {
  name                        = "controller-etcd"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "2379-2380"
  source_address_prefix       = "${var.controller_cidr}"
  destination_address_prefix  = "${var.controller_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.controller.name}"
}

resource "azurerm_network_security_rule" "controller-flannel" {
  name                        = "controller-flannel"
  priority                    = 250
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "UDP"
  source_port_range           = "*"
  destination_port_range      = "8472"
  source_address_prefix       = "${var.worker_cidr}"
  destination_address_prefix  = "${var.controller_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.controller.name}"
}

resource "azurerm_network_security_rule" "controller-flannel-self" {
  name                        = "controller-flannel-self"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "UDP"
  source_port_range           = "*"
  destination_port_range      = "8472"
  source_address_prefix       = "${var.controller_cidr}"
  destination_address_prefix  = "${var.controller_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.controller.name}"
}

resource "azurerm_network_security_rule" "controller-node-exporter" {
  name                        = "controller-node-exporter"
  priority                    = 350
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "9100"
  source_address_prefix       = "${var.worker_cidr}"
  destination_address_prefix  = "${var.controller_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.controller.name}"
}

resource "azurerm_network_security_rule" "controller-kubelet" {
  name                        = "controller-kubelet"
  priority                    = 400
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "10250"
  source_address_prefix       = "${var.controller_cidr}"
  destination_address_prefix  = "${var.controller_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.controller.name}"
}

resource "azurerm_network_security_rule" "controller-kubelet-read" {
  name                        = "controller-kubelet-read"
  priority                    = 450
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "10255"
  source_address_prefix       = "${var.worker_cidr}"
  destination_address_prefix  = "${var.controller_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.controller.name}"
}

resource "azurerm_network_security_rule" "controller-kubelet-read-self" {
  name                        = "controller-kubelet-read-self"
  priority                    = 500
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "10255"
  source_address_prefix       = "${var.controller_cidr}"
  destination_address_prefix  = "${var.controller_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.controller.name}"
}

resource "azurerm_network_security_rule" "controller-bgp" {
  name                        = "controller-bgp"
  priority                    = 550
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "179"
  source_address_prefix       = "${var.worker_cidr}"
  destination_address_prefix  = "${var.controller_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.controller.name}"
}

resource "azurerm_network_security_rule" "controller-bgp-self" {
  name                        = "controller-bgp-self"
  priority                    = 600
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "179"
  source_address_prefix       = "${var.controller_cidr}"
  destination_address_prefix  = "${var.controller_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.controller.name}"
}

# Worker security group

resource "azurerm_network_security_group" "worker" {
  name                = "${var.cluster_name}-worker"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  tags {
    name = "${var.cluster_name}-worker"
  }
}

resource "azurerm_network_security_rule" "worker-egress" {
  name                        = "worker-egress"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker-ssh" {
  name                        = "worker-ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker-http" {
  name                        = "worker-http"
  priority                    = 150
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker-https" {
  name                        = "worker-https"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker-flannel" {
  name                        = "worker-flannel"
  priority                    = 250
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "UDP"
  source_port_range           = "*"
  destination_port_range      = "8472"
  source_address_prefix       = "${var.controller_cidr}"
  destination_address_prefix  = "${var.worker_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker-flannel-self" {
  name                        = "worker-flannel-self"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "UDP"
  source_port_range           = "*"
  destination_port_range      = "8472"
  source_address_prefix       = "${var.worker_cidr}"
  destination_address_prefix  = "${var.worker_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker-node-exporter" {
  name                        = "worker-node-exporter"
  priority                    = 350
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "9100"
  source_address_prefix       = "${var.worker_cidr}"
  destination_address_prefix  = "${var.worker_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker-kubelet" {
  name                        = "worker-kubelet"
  priority                    = 400
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "10250"
  source_address_prefix       = "${var.controller_cidr}"
  destination_address_prefix  = "${var.worker_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker-kubelet-self" {
  name                        = "worker-kubelet-self"
  priority                    = 450
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "10250"
  source_address_prefix       = "${var.worker_cidr}"
  destination_address_prefix  = "${var.worker_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker-kubelet-read" {
  name                        = "worker-kubelet-read"
  priority                    = 500
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "10255"
  source_address_prefix       = "${var.controller_cidr}"
  destination_address_prefix  = "${var.worker_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker-kubelet-read-self" {
  name                        = "worker-kubelet-read-self"
  priority                    = 550
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "10255"
  source_address_prefix       = "${var.worker_cidr}"
  destination_address_prefix  = "${var.worker_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "ingress-health-self" {
  name                        = "ingress-health-self"
  priority                    = 600
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "10254"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "${var.worker_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker-bgp" {
  name                        = "worker-bgp"
  priority                    = 650
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "179"
  source_address_prefix       = "${var.controller_cidr}"
  destination_address_prefix  = "${var.worker_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker-bgp-self" {
  name                        = "worker-bgp-self"
  priority                    = 700
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "179"
  source_address_prefix       = "${var.worker_cidr}"
  destination_address_prefix  = "${var.worker_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}
