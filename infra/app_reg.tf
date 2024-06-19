# Commented out because SPN does not have permissions to create
###
### # Chat Backend App Rgeistration
### resource "random_uuid" "chat_web_api_read_write_scope_id" {}
###
### resource "azuread_service_principal" "chat_api_sp" {
###   count                        = var.entra_id.can_create_app_reg ? 1 : 0
###   client_id                    = azuread_application.chat_api[0].client_id
###   app_role_assignment_required = false
###   owners                       = [data.azurerm_client_config.current.object_id]
###
###   feature_tags {
###     enterprise = true
###     gallery    = true
###   }
### }
###
### resource "azuread_application" "chat_api" {
###   count            = var.entra_id.can_create_app_reg ? 1 : 0
###   display_name     = var.chat_settings.webapi_webapp_name
###   owners           = [data.azurerm_client_config.current.object_id]
###   sign_in_audience = "AzureADMyOrg"
###
###   identifier_uris = ["api://aiutility-web-api"]
###
###   api {
###     mapped_claims_enabled          = true
###     requested_access_token_version = 1 # TODO change to 2 but need to update audience as well
###
###     oauth2_permission_scope {
###       admin_consent_description  = "Read and write users conversations"
###       admin_consent_display_name = "Read and write users conversations"
###       enabled                    = true
###       id                         = random_uuid.chat_web_api_read_write_scope_id.result
###       value                      = "Read.Write.All"
###       type                       = "User"
###       user_consent_description   = "Read and write your conversations"
###       user_consent_display_name  = "Read and write your conversations"
###     }
###   }
### }
###
###
### resource "azuread_application_pre_authorized" "chat_web_to_api_authorization" {
###
###   count                = var.entra_id.can_grant_consent ? 1 : 0
###   application_id       = azuread_application.chat_api[0].id
###   authorized_client_id = azuread_application.static_chat[0].client_id
###   permission_ids       = [random_uuid.chat_web_api_read_write_scope_id.result]
### }
###
###
### # used as source for the rest of the resources to not depend on app reg resource in case we don't have rights to create app reg
### data "azuread_application" "chat_api_data" {
###   display_name = var.chat_settings.webapi_webapp_name
### }
###
###
### # Static Web App App Registration
###
### resource "azuread_service_principal" "static_chat_sp" {
###   count                        = var.entra_id.can_create_app_reg ? 1 : 0
###   client_id                    = azuread_application.static_chat[0].client_id
###   app_role_assignment_required = false
###   owners                       = [data.azurerm_client_config.current.object_id]
###
###   feature_tags {
###     enterprise = true
###     gallery    = true
###   }
### }
###
###
### resource "azuread_application" "static_chat" {
###   count            = var.entra_id.can_create_app_reg ? 1 : 0
###   display_name     = var.chat_settings.frontend_name
###   owners           = [data.azurerm_client_config.current.object_id]
###   sign_in_audience = "AzureADMyOrg"
###
###   single_page_application {
###     redirect_uris = ["https://${azurerm_static_web_app.static_chat.default_host_name}/home", "https://${var.chat_settings.frontend_public_fqdn}/home"]
###   }
###
###   required_resource_access {
###     resource_app_id = azuread_application.chat_api[0].client_id
###     resource_access {
###       id   = random_uuid.chat_web_api_read_write_scope_id.result
###       type = "Scope"
###     }
###   }
###
###   required_resource_access {
###     resource_app_id = azuread_service_principal.msgraph.client_id # Microsoft Graph
###     resource_access {
###       id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["User.Read"]
###       type = "Scope"
###     }
###     resource_access {
###       id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["openid"]
###       type = "Scope"
###     }
###     resource_access {
###       id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["profile"]
###       type = "Scope"
###     }
###     resource_access {
###       id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["offline_access"]
###       type = "Scope"
###     }
###   }
### }
###
### # used as source for the rest of the resources to not depend on app reg resource in case we don't have rights to create app reg
### data "azuread_application" "static_chat_data" {
###   display_name = var.chat_settings.frontend_name
###   depends_on   = [azuread_application.static_chat]
### }
###
###
### output "chat_static_webapp_client_id" {
###   value       = data.azuread_application.static_chat_data.client_id
###   description = "The client id of the aiutility chat web application."
### }
