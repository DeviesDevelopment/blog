---
title: "Creating a Postman Collection From Swagger"
date: 2023-05-04T13:20:14+02:00
tags: ["swagger"]
featured_image: ""
description: "Importing swagger configuration to postman"
slug: "creating-a-postman-collection-from-swagger"
author:
 - Robert (@gadapunkfun) M
---

# Background

This is probably not news to anyone that has been working as developer consultant.
Large existing code base; in our case it's an application that has existed for about 2,5 years and during that time it has developed 
several services and therefore has many endpoints.

Therefore when me and my colleagues had to start developing new features it was hard to know what was available and what wasn't with over 50 different endpoints to hit.

# Solution

We know and love [Postman ©](https://www.postman.com/) so we wanted to find a way to use that to share an equal standing ground consisting of shared knowledge.
After frantically pressing buttons and looking around the [Postman ©](https://www.postman.com/) application we found the convenient button labeled `Import` and that's when me and my colleague said aha! 💡 </br>
After opening that menu option we saw that importing data from Swagger was possible and the project we were working with had that one requirement.

# Action

So here's a quick and easy guide on how to create a new collection in [Postman ©](https://www.postman.com/) through Swagger; quick and easy no doubt thanks to the amazing team of developers over at [Postman ©](https://www.postman.com/)!

1. Open Postman
> ![open postman](/blog/swagger-to-postman/start.png)
2. Click Import
> ![location of the import button](/blog/swagger-to-postman/import.png)
3. Paste link or drag n drop the swagger json file
> ![import window](/blog/swagger-to-postman/importing.png)

> ![link added to postman import window](/blog/swagger-to-postman/link.png)
4. Voilá!
> ![postman with new collection](/blog/swagger-to-postman/imported.png)

# Final Notes

This is a fantastic feature to keep in mind not only for scenarios similar to this it's also good if you want to use other tools that [Postman ©](https://www.postman.com/) offers.
As an example you can create simple JavaScript scripts to set authentication token for your requests, something you clearly can't do in Swagger, making local development environment that much easier and looking more professional. (thanks @BunnyFiscuit for showing me that trick).
