---
title: "Managed Identities with RBAC is awesome!"
date: 2022-03-15T20:15:15+01:00
tags: []
featured_image: ""
description: ""
slug: "managed-identities-with-rbac-is-awesome"
author:
  - Rickard Andersson
---

In a project I work with we use [Azure App Service](https://docs.microsoft.com/en-us/azure/app-service/overview) for hosting an ASP.NET application. All external configuration used by the application is stored in an [Azure App Configuration](https://docs.microsoft.com/en-us/azure/azure-app-configuration/overview) store. To access configuration values, the application must authenticate to the Azure App Configuration store in some way. Up until recently we have used access keys, or connection strings for authentication. However, we now use a managed identity together with role based access control (RBAC) instead. It works great, and in this post I'll show you why.

Blabla, Microsoft show access key in documentation, it sucks, hurdlesome in CI/CD pipeline AND in local development environment.
This is the way that Microsoft shows in a lot of documentation (e.g. [here](https://docs.microsoft.com/en-us/azure/azure-app-configuration/quickstart-aspnet-core-app?tabs=core6x)).

Ok, what should you do instead?
 - Assign a system managed identity
 - Grant the managed identity the proper role

Ok, that works for the App Service, what about local development?
 - Grant developers the same role!
 - Use DefaultAzureCredential (same code, different authentication methods)

Show small code examples in terraform (any sensible person uses iac anyway) 
