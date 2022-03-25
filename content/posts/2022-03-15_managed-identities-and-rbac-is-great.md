---
title: "Managed Identities and RBAC is great"
date: 2022-03-15T20:15:15+01:00
tags: []
featured_image: ""
description: ""
slug: "managed-identities-and-rbac-is-great"
author:
  - Rickard Andersson
---

In a project I work with we use [Azure App Service](https://docs.microsoft.com/en-us/azure/app-service/overview) for hosting an ASP.NET application. All external configuration used by the application is stored in an [Azure App Configuration](https://docs.microsoft.com/en-us/azure/azure-app-configuration/overview) store. I recently updated how the application authenticates toward the App Configuration store and think it worked out pretty well.

Prior to the change we used connection strings (i.e. a string containing endpoint, username and password) for authentication. The main drawback with this is that we have to manage the credentials ourselves. We must provide the connection string to the application in some way (e.g. set it in a CI/CD pipeline after deploying our application). If our connection string is compromised, we must regenerate it and make sure that the application is provided with the new one.

Additionally, when running our application locally the connection string must be accessible. It'd be super bad to store the connection string in source control, so each developer need to obtain the connection string and store it locally in some way, e.g. with [dotnet user-secrets](https://docs.microsoft.com/en-us/aspnet/core/security/app-secrets?view=aspnetcore-6.0&tabs=linux)).

___

Instead of connection strings, we now use a [managed identity](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview) together with role-based access control (RBAC). This means that the App Service has an identity in Azure Active Directory, completely managed by Azure. We don't need to care about any credentials, the authentication just works. To manage what services/resources the managed identity can access, we assign roles to the managed identity, with a proper scope.

If you're using terraform, the relevant changes you need to make will look something like below.

```hcl
resource "azurerm_app_service" "example" {
  name = "my-app-service"
  ...
  identity {
    type = SystemAssigned
  }
}

resource "azurerm_app_configuration" "example" {
  name                = "my-app-config"
  ...
}

resource "azurerm_role_assignment" "example" {
  scope                = azurerm_app_configuration.example.id
  role_definition_name = "App Configuration Data Reader"
  principal_id         = azurerm_app_service.example.identity[0].principal_id
}
```

By adding a `identity` block of type `SystemAssigned` a managed identity will be generated for the App Service. The principal_id of the managed identity is exposed in the `.identity[0].principal_id` attribute of the App Service. We must use this id to assign roles to the newly created managed identity (see the `azurerm_role_assignment` resource).

___

What about running our application locally? As I mentioned above, with connection strings you must make sure you have the connection string available locally in some way. Turns out this is way simpler when using RBAC. The key to it all is the `DefaultAzureCredential` class provided by the [Azure.Identity](https://www.nuget.org/packages/Azure.Identity/) library.

```csharp
builder.Host.ConfigureAppConfiguration(builder =>
{
    builder.AddAzureAppConfiguration(options =>
        options.Connect(new Uri("APP-CONFIG-URL"), new DefaultAzureCredential()));
});
```

By using `DefaultAzureCredential`, our code will attempt to use several different credential providers. So, while the application is running in Azure App Service, it'll use the `ManagedIdentityCredential`, while it can fall back to something like `AzureCliCredential` or `VisualStudioCodeCredential` while we run the application locally. All we need to do to make this work is to ensure that all personal developer accounts has the proper Azure AD roles (e.g. `App Configuration Data Reader`).

___

With managed identities and RBAC we rid ourselves of the need to manage credentials. It's more secure to let Azure handle concerns like this for us. Additionally, we gain a better developer experience by removing manual steps needed to have the developer environment up and running.

Note that managed identities and RBAC is in no way limited to Azure App Config. You can use this authentication/authorization mechanism for a lot of Azure resources. It's still in preview for some though.
