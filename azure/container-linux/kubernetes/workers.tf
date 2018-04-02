module "workers" {
  source = "workers"
  name   = "${var.cluster_name}"

  # Azure
  location       = "${var.location}"
  resource_group = "${azurerm_resource_group.rg.name}"
  dns_zone       = "${var.dns_zone}"
  dns_zone_rg    = "${var.dns_zone_rg}"
  subnet_id      = "${azurerm_subnet.worker.id}"

  #vpc_id          = "${aws_vpc.network.id}"
  #security_groups = ["${aws_security_group.worker.id}"]
  count = "${var.worker_count}"

  instance_type = "${var.worker_type}"
  os_channel    = "${var.os_channel}"
  disk_size     = "${var.disk_size}"

  # configuration
  kubeconfig            = "${module.bootkube.kubeconfig}"
  ssh_authorized_key    = "${var.ssh_authorized_key}"
  service_cidr          = "${var.service_cidr}"
  cluster_domain_suffix = "${var.cluster_domain_suffix}"
  clc_snippets          = "${var.worker_clc_snippets}"
}
