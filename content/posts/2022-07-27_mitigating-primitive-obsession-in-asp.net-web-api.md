---
title: "Mitigating Primitive Obsession in ASP.NET Web Api"
date: 2022-07-27T15:20:58+02:00
tags: [ "ASP.NET", ".NET", "code smells" ]
featured_image: ""
description: ""
slug: "mitigating-primitive-obsession-in-asp.net-web-api"
author:
 - Carina Fernandes
 - Rickard Andersson
 - Johan Hage
---

 - Introduction to problem
   - Concept central to domain that is represented as a primitive
   - Duplicated validation
   - Readability

 - Conversion for Entity Framework (ValueConverter)
 - Conversion for JSON serialize/deserialize (JsonConverter)
 - Model binding (controller routes, etc)
 - Swashbuckle

 - Summary med bra grejer
   - Centralized validation
   - När vi ser ToothIdentifier så vet vi att den är giltig, type safety, typ
   - Smäller i "API-ytan"
   - Tydligare API-dokumentation
