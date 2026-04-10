data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

#################################################################################################################
# LOCALS
#################################################################################################################

locals {
  vnet_cidr           = ["10.10.0.0/24"]
  vm_subnet_cidr      = ["10.10.0.0/26"]
  fw_subnet_cidr      = ["10.10.0.64/26"]
  bastion_subnet_cidr = ["10.10.0.128/26"]
}

#################################################################################################################
# RESOURCE GROUP
#################################################################################################################

resource "azurerm_resource_group" "public" {
  location = var.location
  name     = "rg-trafficmgr-${var.prefix}"
  tags     = var.tags
}

#################################################################################################################
# VNET AND SUBNET
#################################################################################################################

resource "azurerm_virtual_network" "public" {
  name                = "vnet-${var.prefix}"
  address_space       = local.vnet_cidr
  location            = azurerm_resource_group.public.location
  resource_group_name = azurerm_resource_group.public.name
}

resource "azurerm_subnet" "vm" {
  name                 = "snet-vm-${var.prefix}"
  resource_group_name  = azurerm_resource_group.public.name
  virtual_network_name = azurerm_virtual_network.public.name
  address_prefixes     = local.vm_subnet_cidr
}

#################################################################################################################
# BLUE SLOT
#################################################################################################################

module "blue_slot" {
  source                           = "./modules/ubuntu-vm-key-auth-custom-image"
  custom_image_resource_group_name = "rg-packer-images-linux"
  custom_image_sku                 = "ubuntu2204-v1"
  ip_configuration_name            = "ipc-blue-slot-${var.prefix}"
  network_interface_name           = "nic-blue-slot-${var.prefix}"
  os_profile_admin_public_key      = file("${path.root}/id_ed25519.pub")
  os_profile_admin_username        = "razumovsky_r"
  os_profile_computer_name         = "vm-blue-slot-${var.prefix}"
  public_ip_name                   = "pip-blue-slot-${var.prefix}"
  resource_group_location          = azurerm_resource_group.public.location
  resource_group_name              = azurerm_resource_group.public.name
  storage_os_disk_name             = "osdisk-blue-slot-${var.prefix}"
  subnet_id                        = azurerm_subnet.vm.id
  vm_name                          = "vm-blue-slot-${var.prefix}"
  network_security_group_id        = azurerm_network_security_group.public.id

  domain_name_label = "blue-slot-fqdn-${var.prefix}"
}

#################################################################################################################
# GREEN SLOT
#################################################################################################################

module "green_slot" {
  source                           = "./modules/ubuntu-vm-key-auth-custom-image"
  custom_image_resource_group_name = "rg-packer-images-linux"
  custom_image_sku                 = "ubuntu2204-v1"
  ip_configuration_name            = "ipc-green-slot-${var.prefix}"
  network_interface_name           = "nic-green-slot-${var.prefix}"
  os_profile_admin_public_key      = file("${path.root}/id_ed25519.pub")
  os_profile_admin_username        = "razumovsky_r"
  os_profile_computer_name         = "vm-green-slot-${var.prefix}"
  public_ip_name                   = "pip-green-slot-${var.prefix}"
  resource_group_location          = azurerm_resource_group.public.location
  resource_group_name              = azurerm_resource_group.public.name
  storage_os_disk_name             = "osdisk-green-slot-${var.prefix}"
  subnet_id                        = azurerm_subnet.vm.id
  vm_name                          = "vm-green-slot-${var.prefix}"
  network_security_group_id        = azurerm_network_security_group.public.id

  domain_name_label = "green-slot-fqdn-${var.prefix}"
}

#################################################################################################################
# TRAFFIC MANAGER PROFILE
#################################################################################################################

module "traffic_manager_profile" {
  source              = "./modules/traffic-manager-profile"
  profile_name        = "tm-profile-${var.prefix}"
  relative_name       = "tmprofile${var.prefix}"
  resource_group_name = azurerm_resource_group.public.name
}

#################################################################################################################
# BLUE ENDPOINT
#################################################################################################################

module "traffic_manager_endpoint_blue" {
  source                                      = "./modules/traffic-manager-endpoint"
  traffic_manager_endpoint_name               = "blue-endpoint-${var.prefix}"
  traffic_manager_endpoint_target_resource_id = module.blue_slot.public_ip_id
  traffic_manager_endpoint_weight             = 500
  traffic_manager_profile_id                  = module.traffic_manager_profile.id

  depends_on = [
    module.traffic_manager_profile,
    module.blue_slot
  ]
}

#################################################################################################################
# GREEN ENDPOINT
#################################################################################################################

module "traffic_manager_endpoint_green" {
  source                                      = "./modules/traffic-manager-endpoint"
  traffic_manager_endpoint_name               = "green-endpoint-${var.prefix}"
  traffic_manager_endpoint_target_resource_id = module.green_slot.public_ip_id
  traffic_manager_endpoint_weight             = 500
  traffic_manager_profile_id                  = module.traffic_manager_profile.id

  depends_on = [
    module.traffic_manager_profile,
    module.green_slot
  ]
}
