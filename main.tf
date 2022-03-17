
##############################################################################
# VNF custom image
##############################################################################

# Generating random ID
resource "random_uuid" "test" { }

resource "ibm_is_image" "vnf_custom_image" {
  depends_on       = [random_uuid.test]
  href             = var.vnf_cos_image_url
  name             = "${var.vpc_name}-vnf-${substr(random_uuid.test.result,0,8)}"
  operating_system = "ubuntu-18-04-amd64"
  resource_group     = data.ibm_resource_group.group.id

  timeouts {
    create = "30m"
    delete = "10m"
  }
}
##############################################################################
# Default Linux image
##############################################################################
data "ibm_is_image" "image" {
  name = "ibm-ubuntu-18-04-1-minimal-amd64-2"
}

##############################################################################
# Default ssh key
##############################################################################
data "ibm_is_ssh_key" "sshkey" {
  name = var.ssh_keyname
}

##############################################################################
# Default resource group
##############################################################################
data "ibm_resource_group" "group" {
  name = var.resource_group_name
}

##############################################################################
# Default VPC
##############################################################################
resource "ibm_is_vpc" "vpc" {
  name           = var.vpc_name
  resource_group = data.ibm_resource_group.group.id
}
##############################################################################
# Management subets
##############################################################################
resource "ibm_is_subnet" "mgm_subnet" {
  count                    = 3
  name                     = "${var.vpc_name}-mgm-subnet-${count.index + 1}"
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = "${var.region}-${count.index + 1}"
  resource_group           = data.ibm_resource_group.group.id
  total_ipv4_address_count = "256"
}

##############################################################################
# on-prem subets
##############################################################################
resource "ibm_is_subnet" "onprem_subnet" {
  count                    = 3
  name                     = "${var.vpc_name}-onprem-subnet-${count.index + 1}"
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = "${var.region}-${count.index + 1}"
  resource_group           = data.ibm_resource_group.group.id
  total_ipv4_address_count = "256"
}

##############################################################################
# Web application internal subets
##############################################################################
resource "ibm_is_subnet" "web_subnet" {
  count                    = 3
  name                     = "${var.vpc_name}-web-subnet-${count.index + 1}"
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = "${var.region}-${count.index + 1}"
  resource_group           = data.ibm_resource_group.group.id
  total_ipv4_address_count = "256"
}


##############################################################################
# VNF Public facing subets
##############################################################################
resource "ibm_is_subnet" "vnf_subnet" {
  count                    = 3
  name                     = "${var.vpc_name}-vnf-subnet-${count.index + 1}"
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = "${var.region}-${count.index + 1}"
  resource_group           = data.ibm_resource_group.group.id
  total_ipv4_address_count = "256"
}
#output "first_ip_address" {
#  value = ("ibm_is_subnet.vnf_subnet[0].*.id")
#}
#output "first_ip_address" {
#  value = (ibm_is_subnet.vnf_subnet[0].*.id,ibm_is_subnet.web_subnet[0].*.id)
#}
##############################################################################
# Security Group for Public Load Balancer
##############################################################################

resource "ibm_is_security_group" "pub_alb_security_group" {
  name           = "${var.basename}-pub-alb-sg"
  vpc            = ibm_is_vpc.vpc.id
  resource_group = data.ibm_resource_group.group.id
}
resource "ibm_is_security_group_rule" "pub_alb_security_group_rule_tcp_443" {
  group     = ibm_is_security_group.pub_alb_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 443
    port_max = 443
  }
}
resource "ibm_is_security_group_rule" "pub_allb_security_group_rule_udp_443" {
  group     = ibm_is_security_group.pub_alb_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  udp {
    port_min = 443
    port_max = 443
  }
}

resource "ibm_is_security_group_rule" "pub_alb_security_group_rule_tcp_22" {
  group     = ibm_is_security_group.pub_alb_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 22
    port_max = 22
  }
}
resource "ibm_is_security_group_rule" "pub_alb_security_group_rule_tcp_80" {
  group     = ibm_is_security_group.pub_alb_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 80
    port_max = 80
  }
}
resource "ibm_is_security_group_rule" "pub_alb_security_group_rule_icmp" {
  group     = ibm_is_security_group.pub_alb_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  icmp {
    type = 8
  }
}
resource "ibm_is_security_group_rule" "pub_alb_security_group_rule_tcp_80_outbound" {
  group     = ibm_is_security_group.pub_alb_security_group.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 80
    port_max = 80
  }
}
resource "ibm_is_security_group_rule" "pub_alb_security_group_rule_tcp_443_outbound" {
  group     = ibm_is_security_group.pub_alb_security_group.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 443
    port_max = 443
  }
}
resource "ibm_is_security_group_rule" "pub_alb_security_group_rule_tcp_22_outbound" {
  group     = ibm_is_security_group.pub_alb_security_group.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 22
    port_max = 22
  }
}

##############################################################################
# Security Group for Web Load Balancer
##############################################################################

resource "ibm_is_security_group" "web_security_group" {
  name           = "${var.basename}-web-alb-sg"
  vpc            = ibm_is_vpc.vpc.id
  resource_group = data.ibm_resource_group.group.id
}
resource "ibm_is_security_group_rule" "web_security_group_rule_udp_outbound" {
  group     = ibm_is_security_group.web_security_group.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  udp {
    port_min = 53
    port_max = 53
  }
}
resource "ibm_is_security_group_rule" "web_security_group_rule_tcp_outbound" {
  group     = ibm_is_security_group.web_security_group.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 53
    port_max = 53
  }
}
resource "ibm_is_security_group_rule" "web_security_group_rule_tcp_outbound_80" {
  group     = ibm_is_security_group.web_security_group.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "web_security_group_rule_tcp_outbound_443" {
  group     = ibm_is_security_group.web_security_group.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 443
    port_max = 443
  }
}
resource "ibm_is_security_group_rule" "web_security_group_rule_tcp_22" {
  group     = ibm_is_security_group.web_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 22
    port_max = 22
  }
}
resource "ibm_is_security_group_rule" "web_security_group_rule_udp_inbound" {
  group     = ibm_is_security_group.web_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  udp {
    port_min = 53
    port_max = 53
  }
}
resource "ibm_is_security_group_rule" "web_security_group_rule_tcp_inbound" {
  group     = ibm_is_security_group.web_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 53
    port_max = 53
  }
}
resource "ibm_is_security_group_rule" "web_security_group_rule_tcp_inbound_80" {
  group     = ibm_is_security_group.web_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "web_security_group_rule_tcp_inbound_443" {
  group     = ibm_is_security_group.web_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 443
    port_max = 443
  }
}

##############################################################################
# Public Load Balancer
##############################################################################

resource "ibm_is_lb" "pub_alb" {
  name            = "${var.vpc_name}-vnf-alb"
  subnets         = ibm_is_subnet.vnf_subnet[0].*.id
  resource_group  = data.ibm_resource_group.group.id
  security_groups = [ibm_is_security_group.pub_alb_security_group.id]
}

resource "ibm_is_lb_pool" "pub_alb_pool" {
  lb                 = ibm_is_lb.pub_alb.id
  name               = "${var.vpc_name}-pub-alb-pool"
  protocol           = var.enable_end_to_end_encryption ? "https" : "http"
  algorithm          = "round_robin"
  health_delay       = "15"
  health_retries     = "2"
  health_timeout     = "5"
  health_type        = var.enable_end_to_end_encryption ? "https" : "tcp"
  health_monitor_url = "/"
  health_monitor_port = "22"
  #depends_on = [time_sleep.wait_30_seconds-1]
}

resource "ibm_is_lb_listener" "pub_alb_listner" {
  lb                   = ibm_is_lb.pub_alb.id
  port                 = var.certificate_crn == "" ? "80" : "443"
  protocol             = var.certificate_crn == "" ? "http" : "https"
  default_pool         = element(split("/", ibm_is_lb_pool.pub_alb_pool.id), 1)
  certificate_instance = var.certificate_crn == "" ? "" : var.certificate_crn
}
##############################################################################
# VNF Instance 1
##############################################################################
resource "ibm_is_instance" "pa-ha1" {
  name    = "pa-ha-instanca1"
  image   = ibm_is_image.vnf_custom_image.id
  profile        = "bx2-8x32"
  resource_group =  data.ibm_resource_group.group.id
  vpc       = ibm_is_vpc.vpc.id
  zone      = "${var.region}-1"
  keys      = [data.ibm_is_ssh_key.sshkey.id]

  primary_network_interface {
    subnet          = ibm_is_subnet.mgm_subnet[0].id
    security_groups = [ibm_is_security_group.pub_alb_security_group.id]
    allow_ip_spoofing = true
  }
 network_interfaces {
    name   = "eth1"
    security_groups = [ibm_is_security_group.pub_alb_security_group.id]
    subnet = ibm_is_subnet.vnf_subnet[0].id
    allow_ip_spoofing = true
  }
 network_interfaces {
    name   = "eth2"
    security_groups = [ibm_is_security_group.pub_alb_security_group.id]
    subnet = ibm_is_subnet.onprem_subnet[0].id
    allow_ip_spoofing = true
  }
 network_interfaces {
    name   = "eth3"
    security_groups = [ibm_is_security_group.pub_alb_security_group.id]
    subnet = ibm_is_subnet.web_subnet[0].id
    allow_ip_spoofing = true
  }
    

  //User can configure timeouts
  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}
resource "ibm_is_floating_ip" "pa-ha1-fip" {
  name   = "pa-ha1-floating-ip"
  target = ibm_is_instance.pa-ha1.primary_network_interface[0].id
}
resource "time_sleep" "wait_30_seconds" {
  depends_on = [ibm_is_lb.pub_alb]
 destroy_duration = "60s"
}
resource "ibm_is_lb_pool_member" "pub_alb_member1" {
  count = 1
  lb = "${ibm_is_lb.pub_alb.id}"
  pool ="${ibm_is_lb_pool.pub_alb_pool.id}"
  port  = 80
  target_address = "${ibm_is_instance.pa-ha1.network_interfaces[0].primary_ipv4_address}"
}
##############################################################################
# VNF Instance 2
##############################################################################
resource "ibm_is_instance" "pa-ha2" {
  name    = "pa-ha-instanca2"
  image   = ibm_is_image.vnf_custom_image.id
  profile        = "bx2-8x32"
  resource_group =  data.ibm_resource_group.group.id
  vpc       = ibm_is_vpc.vpc.id
  zone      = "${var.region}-1"
  keys      = [data.ibm_is_ssh_key.sshkey.id]
  primary_network_interface {
    subnet          = ibm_is_subnet.mgm_subnet[0].id
    security_groups = [ibm_is_security_group.pub_alb_security_group.id]
    allow_ip_spoofing = true
  }
 network_interfaces {
    name   = "eth1"
    security_groups = [ibm_is_security_group.pub_alb_security_group.id]
    subnet = ibm_is_subnet.vnf_subnet[0].id
    allow_ip_spoofing = true
  }
 network_interfaces {
    name   = "eth2"
    security_groups = [ibm_is_security_group.pub_alb_security_group.id]
    subnet = ibm_is_subnet.onprem_subnet[0].id
    allow_ip_spoofing = true
  }
 network_interfaces {
    name   = "eth3"
    security_groups = [ibm_is_security_group.pub_alb_security_group.id]
    subnet = ibm_is_subnet.web_subnet[0].id
    allow_ip_spoofing = true
  }
    

  //User can configure timeouts
  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}
resource "ibm_is_floating_ip" "pa-ha2-fip" {
  name   = "pa-ha2-floating-ip"
  target = ibm_is_instance.pa-ha2.primary_network_interface[0].id
}
resource "time_sleep" "wait_30_seconds-2" {
  depends_on = [ibm_is_lb.pub_alb]
  destroy_duration = "60s"
}
resource "ibm_is_lb_pool_member" "pub_alb_member2" {
  count = 1
  lb = "${ibm_is_lb.pub_alb.id}"
  pool ="${ibm_is_lb_pool.pub_alb_pool.id}"
  port  = 80
  target_address = "${ibm_is_instance.pa-ha2.network_interfaces[0].primary_ipv4_address}"
}
#output "IP" {
#  value = ibm_is_instance.pa-ha1.network_interfaces[0].primary_ipv4_address
#}
##############################################################################
# Private Web Load Balancer
##############################################################################

resource "ibm_is_lb" "web_alb" {
  name            = "${var.vpc_name}-web-alb"
  subnets         = [ibm_is_subnet.web_subnet[0].id,ibm_is_subnet.web_subnet[1].id]
  resource_group  = data.ibm_resource_group.group.id
  security_groups = [ibm_is_security_group.pub_alb_security_group.id]
  type		  = "private"
}

resource "ibm_is_lb_pool" "web_alb_pool" {
  lb                 = ibm_is_lb.web_alb.id
  name               = "${var.vpc_name}-web-alb-pool"
  protocol           = var.enable_end_to_end_encryption ? "https" : "http"
  algorithm          = "round_robin"
  health_delay       = "15"
  health_retries     = "2"
  health_timeout     = "5"
  health_type        = var.enable_end_to_end_encryption ? "https" : "http"
  health_monitor_url = "/"
#  depends_on = [time_sleep.wait_30_seconds]
}

resource "ibm_is_lb_listener" "web_alb_listener" {
  lb                   = ibm_is_lb.web_alb.id
  port                 = var.certificate_crn == "" ? "80" : "443"
  protocol             = var.certificate_crn == "" ? "http" : "https"
  default_pool         = element(split("/", ibm_is_lb_pool.web_alb_pool.id), 1)
  certificate_instance = var.certificate_crn == "" ? "" : var.certificate_crn
}
output "web_alb" {
  value =ibm_is_lb.web_alb
}
##############################################################################
# Web App  Auto Scale pool
##############################################################################

resource "ibm_is_instance_template" "web_instance_template" {
  name           = "web-instance-template"
  image          = data.ibm_is_image.image.id
  profile        = "cx2-2x4"
  resource_group = data.ibm_resource_group.group.id

  primary_network_interface {
    subnet          = ibm_is_subnet.web_subnet[0].id
    security_groups = [ibm_is_security_group.web_security_group.id]
    allow_ip_spoofing = true
  }

  vpc       = ibm_is_vpc.vpc.id
  zone      = "${var.region}-1"
  keys      = [data.ibm_is_ssh_key.sshkey.id]
  user_data = var.enable_end_to_end_encryption ? file("./scripts/install-software-ssl.sh") : file("./scripts/install-software.sh")
}
#
resource "ibm_is_instance_group" "web_instance_group" {
  name               = "${var.basename}-web-instance"
  instance_template  = ibm_is_instance_template.web_instance_template.id
  instance_count     = 1
  subnets            = ibm_is_subnet.web_subnet[0].*.id
  load_balancer      = ibm_is_lb.web_alb.id
  load_balancer_pool = element(split("/", ibm_is_lb_pool.web_alb_pool.id), 1)
  application_port   = var.enable_end_to_end_encryption ? 443 : 80
  resource_group     = data.ibm_resource_group.group.id

  depends_on = [ibm_is_lb_listener.web_alb_listener, ibm_is_lb_pool.web_alb_pool, ibm_is_lb.web_alb]
}

resource "ibm_is_instance_group_manager" "web_instance_group_manager" {
  name                 = "${var.basename}-web-instance-group-manager"
  aggregation_window   = 90
  instance_group       = ibm_is_instance_group.web_instance_group.id
  cooldown             = 120
  manager_type         = "autoscale"
  enable_manager       = true
  min_membership_count = 1
  max_membership_count = 2
}

resource "ibm_is_instance_group_manager_policy" "webcpuPolicy" {
  instance_group         = ibm_is_instance_group.web_instance_group.id
  instance_group_manager = ibm_is_instance_group_manager.web_instance_group_manager.manager_id
  metric_type            = "cpu"
  metric_value           = 10
  policy_type            = "target"
  name                   = "${var.basename}-web-instance-group-manager-policy"
}

resource "time_sleep" "webwait_30_seconds" {
  depends_on = [ibm_is_lb.pub_alb]
  destroy_duration = "60s"
}
