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
   In one of the projects we work with in Devies, the dental notation (ISO 3950) is wide used to refer too teeth. 
   Every tooth have an unique identifier that consits of two characters.
   The first character represent the quadrant, one of four areas in the mouth.
   The second characters is an identifiers that refers to one of the eight teeth in that area.

   In the early on the project we represented the tooth identifier as a string, for example `"42"`
   As the project grow we stared to use this tooth identifier in many different places in the project.
   In every place where the identifier was used we had to make sure the tooth identifier was properly validated.
   
   This is a clear example of [primitive obsession]('insert-link').
   In this post we will describe how we mitigated this problem in the context of ASP.Net Webb API where we use Entity Framework.



   - Duplicated validation
   - Readability

 - Conversion for Entity Framework (ValueConverter)
 - Conversion for JSON serialize/deserialize (JsonConverter)
 - Model binding (controller routes, etc)
 - Swashbuckle

 - Summary med bra och dåliga grejer
   - (+) Centralized validation
   - (+) När vi ser ToothIdentifier så vet vi att den är giltig, type safety, typ
   - (+) Smäller i "API-ytan"
   - (+) Tydligare API-dokumentation
   - (-) Mycket kod
