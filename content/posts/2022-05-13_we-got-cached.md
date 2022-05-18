---
title: "We Got Cached 😱"
date: 2022-05-13T13:29:31+02:00
tags: [docker, azure, build, ci, cd, pipeline, firefox]
featured_image: ""
description: "A Tip for Troubleshooting Docker Build Problems in Azure"
author:
  - Sarosh Nasir
  - Ömer Simsek
slug: "we-got-cached"
---

For the past couple of weeks, we've been working on a React app from scratch. Additionally, we've added pipelines in Azure as an attempt to achieve <span style="font-family:Arial;color:#00c0ff;">MAXIMUM EFFICIENCY</span> when it comes to deployment and integration. So there we are. It's a lovely morning. The sun is shining, the coffee is warm, and we're ready to drop some lines of code! 😎

Last week we built and deployed a version of our React app that had a slightly faulty CSS attributes that made the header of the app take up the whole screen. Thus our first and foremost task was to fix it so that it only takes up a small area at the top of the screen. We used the Inspection feature in Firefox Developer Edition to pinpoint the faulty CSS and determine the issue, which we managed to do. The next step was to apply that fix in our code to see what would happen. The fix worked locally by running the React app using `yarn start` as well as deploying a Docker image. Great, the fix is ready to be deployed using our Azure pipelines!

Except there was no change. Any fix we attempted to do worked locally but never appeared in the dev environment. We asked our colleagues and no one could pinpoint why this was happening. Alas, we went back to basics and changed the header text. If not CSS, a text change should definitely be shown, right? <span style="font-family:Arial;font-weight:bold;color:#ff2200;">WRONG!</span>🙅‍♂️

We were totally confounded of why this was happening. Maybe it wasn't our code that was the problem, perhaps the issue lies with Docker and how the Docker image is being built. Lo and behold, we see the following piece of code:

```text
Step x/z : COPY . /app
---> 123abc456
Step y/z : RUN yarn build
---> Using cache
---> abc123def
```

`Using cache`? We know that Docker [uses cache for efficiency](https://docs.semaphoreci.com/ci-cd-environment/docker-layer-caching/), and only uses cache when there's no change in the Docker Layers. However, we have clearly made changes to our code, so why aren't those changes not being shown? Upon further reading, we realized something. When `RUN yarn build` is being run, the files are being updated in the container itself, which apparently doesn't trigger a cache check. <span style="font-family:Arial;font-weight:bold;color:#ff9900;">OMG, WE'VE BEEN CACHED!</span>😱

Luckily, we can pass Docker arguments to our Docker task in our `azure-pipelines.yaml` to not include cache:

```yaml
- task: Docker@2
    inputs:
      containerRegistry: ...
      repository: ...
      command: build
      Dockerfile: ...
      arguments: --no-cache
    displayName: "Build"

  - task: Docker@2
    inputs:
      containerRegistry: ...
      repository: ...
      command: push
    displayName: "Push"
```

Notice that we don't use the existing Docker pipeline command `buildAndPush`. This is according to Azure documentation which states that arguments are ignored when using the `buildAndPush` command:

> The arguments input is evaluated for all commands except `buildAndPush`. As `buildAndPush` is a convenience command (`build` followed by `push`), arguments input is ignored for this command.

Now it works! 🚀 🙌

## Key learnings:

- Docker won't cache check when `RUN` command is being run, for example `RUN yarn build` or even `RUN apt-get -y update`.
- When you're stuck, consider going back to basics and making minimal obvious changes to your code to make sure that your changes are being applied!
- Consult your closest documentation when stuck!
