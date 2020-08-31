
# Enables you to manage Private DNS zone Virtual Network Links. 
# These Links enable DNS resolution and registration inside Azure Virtual Networks using Azure Private DNS.
resource "azurerm_private_dns_zone" "dns_zone" {
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = var.resource_group_name
}

# Enables you to manage Private DNS zone Virtual Network Links. 
# These Links enable DNS resolution and registration inside Azure Virtual Networks using Azure Private DNS.
resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_vnet" {
  name                  = "dns-${var.names.product_name}-${var.names.environment}-mysql${var.db_id}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

# Azure Private Endpoint is a network interface that connects you privately and securely to a service powered by Azure Private Link. 
# Private Endpoint uses a private IP address from your VNet, effectively bringing the service into your VNet. The service could be an Azure service such as Azure Storage, SQL, etc. or your own Private Link Service.
resource "azurerm_private_endpoint" "mysql_endpoint" {
  name                = "mysql-endpoint-${var.names.product_name}-${var.names.environment}-mysql${var.db_id}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.snet_endpoint.id

  private_service_connection {
    name                           = "prv-serv-conn-${var.names.product_name}-${var.names.environment}-mysql${var.db_id}"
    private_connection_resource_id = azurerm_mysql_server.primary.id
    subresource_names              = ["mysqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = azurerm_mysql_server.primary.name
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_zone.id]
  }

   tags = var.tags
}
