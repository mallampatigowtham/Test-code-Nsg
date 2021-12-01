data "azurerm_resource_group" "rg" {
  name = var.rgname
  #location = var.location
}
data"azurerm_virtual_machine" "linuxvm"{
     
     name =var.virtual_machine
     
     resource_group_name = data.azurerm_resource_group.rg.name
     #network_interface_ids = [azurerm_network_interface.web_Nic_card.id]

     #location = azurerm_resource_group.rg1.location
    #size = "Standard_B1ms"
    #admin_username = var.username
    #admin_password = var.password 
    #disable_password_authentication = false
    #network_interface_ids = [azurerm_network_interface.web_Nic_card.id]
    #os_disk {
     #   caching = "ReadWrite"
     #   storage_account_type = "Premium_LRS"
    #}
    #source_image_reference {
      #  publisher = "Canonical"
      #  offer = "UbuntuServer"
      #  sku       = "18.04-LTS"
      #  version   = "latest"
    
    #}
  

}
/*data "azurerm_public_ip" "web_linuxVM_PubIP" {
  name =var.webpublicipname
  resource_group_name = data.azurerm_resource_group.rg.name
 # location = azurerm_resource_group.rg1.location
  allocation_method = "Static" 
  sku ="Standard"
  
}

data "azurerm_subnet" "subnet" {
    name = var.subnetname
    resource_group_name=azurerm_resource_group.GSK_Web_RG.name
    virtual_network_name = azurerm_virtual_network.vnet1_web.name
    address_prefixes = var.subnetaddress_MGMT
}*/

data "azurerm_network_interface" "web_Nic_card" {
    name =var.web_linux_nic_card
    resource_group_name = data.azurerm_resource_group.rg.name
    #location =  azurerm_resource_group.rg1.location

   /* ip_configuration {
     name = "Web_linuxvm-1"
     subnet_id = azurerm_subnet.subnet.id
     private_ip_address_allocation = "Dynamic"
     public_ip_address_id = azurerm_public_ip.web_linuxVM_PubIP.id
    }*/

}
output "nic" {
  value = data.azurerm_network_interface.web_Nic_card.id
}

data "azurerm_network_security_group" "nsg" {
  name                = var.nsg
  #location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

output "mynsg" {
  value = data.azurerm_network_security_group.nsg.id
}

# Resource: Create NSG Rules
## Locals Block for Security Rules
locals {
  web_vmnic_inbound_ports_map = {
    "100" : "80", # If the key starts with a number, you must use the colon syntax ":" instead of "="
    "110" : "443",
    "120" : "22"
  } 
}
## NSG Inbound Rule for WebTier Subnets
resource "azurerm_network_security_rule" "web_vmnic_nsg_rule_inbound" {
  for_each = local.web_vmnic_inbound_ports_map
  name                        = "Rule-Port-${each.value}"
  priority                    = each.key
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value 
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name =data.azurerm_network_security_group.nsg.name
}


resource "azurerm_network_interface_security_group_association" "name" {
    #depends_on = [azurerm_network_security_rule.web_vmnic_nsg_rule_inbound] 
    network_interface_id = data.azurerm_network_interface.web_Nic_card.id
    network_security_group_id = data.azurerm_network_security_group.nsg.id
    
  
}
