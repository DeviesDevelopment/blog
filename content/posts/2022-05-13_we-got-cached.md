---
title: "We Got Cached 😱"
date: 2022-05-13T13:29:31+02:00
tags: [docker, azure, build, ci, cd, pipeline]
featured_image: ""
description: "A Tip for Troubleshooting Docker Build Problems in Azure"
author:
  - Sarosh Nasir
  - Ömer Simsek
slug: "we-got-cached"
---

For the past couple of weeks, we've been working on a React app from scratch. Additionally, we've added pipelines in Azure as an attempt to achieve <span style="font-family:Roboto;color:#00c0ff;">MAXIMUM EFFICIENCY</span> when it comes to deployment and integration. So there we are. It's a lovely morning. The sun is shining bright, the coffee is warm, and we're ready to drop some lines of code on this MF. Little do we know we're about get <span style="font-family:Roboto;color:#ff2200;">CACHED</span>!

- Prev week docker build messed up the website
  - WE GON FIX IT!
- Use inspection tools to check CSS stuff
- Tried Docker with NGINX
- Local docker build was not showing any errors
- React was not showing any errors when running either
- Asked around for helped, spent a lot of time trying to fix this issue.
- Something was not adding up. No change we caused showed up in the build.
- So we went back to basics and simply changed a text to something else.
  - NO CHANGE AGAIN, WHAT!?
- What's going? Check the docker logs. it's copying over a cached build of the react app.. CACHED?? WAHT??!??!?!?
- That explained why our changes were never showing up. But that's very weird Docker behavior.
- Either way, Docker has a command you can add when you're building a Docker image. `--no-cache`
- We added this change to our `azure-pipeline.yaml` file and pushed the changes.
  - Note that this argument won't be accounted for in a `buildAndPush` task.
  - Split it up into `build` task that has that argument, and a `push` task to push the image into your Azure Registry.
- It works!
