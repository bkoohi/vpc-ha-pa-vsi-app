variable "ibmcloud_api_key" {
  description = "Your IBM Cloud IAM API key"
  default     = " "
}

variable "ibmcloud_timeout" {
  description = "Timeout for API operations in seconds."
  default     = 900
}

variable "resource_group_name" {
  description = "Your resource group name"
  default     = "Default"
}

variable "vpc_name" {
  description = "Unique name to your VPC"
  default     = "auto-scale-vpc"
}

variable "basename" {
  description = "Prefix used for all resource names"
  default     = "auto-scale"
}

variable "region" {
  description = "The region in which you want to provision your VPC and its resources"
  default     = "us-south"
}

variable "ssh_keyname" {
  description = "Name of the SSH key to use"
  default     = ""
}

variable "certificate_crn" {
  description = "certificate instance CRN if you wish SSL offloading or End-to-end encryption"
  type        = string
  default     = ""
}

variable "enable_end_to_end_encryption" {
  description = "Set it to true if you wish to enable End-to-end encryption"
  type        = bool
  default     = false
}

##############################################################################
# vnf_cos_image_url - Vendor provided VM-Series qcow2 Image COS url.
##############################################################################
 variable "vnf_cos_image_url" {
   default     = "cos://us-east/vnf-palo-alto/PA-VM-KVM-10.0.6.qcow2"
  description = "The COS image object SQL URL for VM-Series qcow2 image."
}
##############################################################################
# image_name - The name of the Palo Alto VM-Series (PanOS) image . Valid values are "pa-vm-kvm-9-1-3-1"
##############################################################################
 variable "image_name" {
   default     = "pa-vm-kvm-10-0-6"
   description = "The name of the VM-series image to be installed. Valid values are pa-vm-kvm-9-1-3-1 and pa-vm-kvm-10-0-6"
 }

