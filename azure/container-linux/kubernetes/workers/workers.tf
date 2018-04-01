# TODO: Add Scale Sets implementation once support exists: https://github.com/kubernetes/kubernetes/issues/43287

# Workers Availability Set
resource "azurerm_availability_set" "workers" {
  name                = "${var.cluster_name}-workers"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  managed             = true

  tags {
    name = "${var.cluster_name}-worker"
  }
}

# Worker VM
resource "azurerm_virtual_machine" "worker" {
  count = "${var.worker_count}"

  name                  = "${var.cluster_name}-worker-${count.index}"
  location              = "${var.location}"
  availability_set_id   = "${azurerm_availability_set.workers.id}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${element(azurerm_network_interface.worker.*.id, count.index)}"]
  vm_size               = "${var.worker_type}"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "CoreOS"
    offer     = "CoreOS"
    sku       = "${var.os_channel}"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.cluster_name}-worker-${count.index}-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
    os_type           = "linux"
    disk_size_gb      = "${var.disk_size}"
  }

  os_profile {
    computer_name  = "${var.cluster_name}-worker-${count.index}"
    admin_username = "core"
    admin_password = ""
    custom_data    = "${data.ct_config.worker_ign.rendered}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/core/.ssh/authorized_keys"
      key_data = "${var.ssh_authorized_key}"
    }
  }

  tags {
    name = "${var.cluster_name}"
  }
}

# Worker NIC
resource "azurerm_network_interface" "worker" {
  count = "${var.worker_count}"

  name                = "${var.cluster_name}-worker-${count.index}-nic"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                                    = "workerIPConfig"
    subnet_id                               = "${azurerm_subnet.worker.id}"
    private_ip_address_allocation           = "dynamic"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.ingress.id}"]
  }

  tags {
    name = "${var.cluster_name}"
  }
}

# Worker Container Linux Config
data "template_file" "worker_config" {
  template = "${file("${path.module}/cl/worker.yaml.tmpl")}"

  vars = {
    kubeconfig            = "${indent(10, var.kubeconfig)}"
    ssh_authorized_key    = "${var.ssh_authorized_key}"
    k8s_dns_service_ip    = "${cidrhost(var.service_cidr, 10)}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"
  }
}

data "ct_config" "worker_ign" {
  content      = "${data.template_file.worker_config.rendered}"
  pretty_print = false
  snippets     = ["${var.clc_snippets}"]
}
