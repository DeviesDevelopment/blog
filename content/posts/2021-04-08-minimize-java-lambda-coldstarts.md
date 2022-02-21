---
categories:
  - Implementation
tags:
  - AWS
  - Java
date: "2021-04-08T09:25:58Z"
title: Minimize Java Lambda Cold Start Times
slug: "implementation/aws/2021/04/08/minimize-java-lambda-coldstarts.html"
author:
  - Gustav Sundin
  - Rickard Andersson
---

If you have ever run Java inside a lambda function on AWS, you will have noticed the quite significant cold start times that comes with spinning up the JVM environment. In this post, I will discuss some different tricks you can use to minimize these cold start times.

The problem with cold starts arises when there are no "warm" lambda available to handle an incoming request, which usually happens whenever an endpoint experiences a large and sudden spike in traffic. The most commonly occurring scenario when this happens is probably when an endpoint goes from no traffic at all in a while (and thus having no warm lambdas ready) to suddenly having one or more incoming requests to serve.

In practice, this means that the issue with cold starts will become much less problematic the more traffic your service gets, especially if the traffic is somewhat evenly distributed across time. For an endpoint with frequent traffic, a few cold starts here and there will probably not impact your P99 latency in a significant way. That being said, if your use case does not allow for a few requests in a while getting response times of at least a couple of seconds or more, then you should probably not use Java at all.

## Minimizing cold start times

Assuming you are fine with some cold starts with noticeable delays, what can be done in order to minimize the time these cold starts consume as much as possible? Here is a list of things to do to minimize the cold starts for your serverless application.

### Increase runtime memory

The more memory you assign to your lambda function, the faster it will spin up because it also gets access to more CPU power. Note that increasing the memory size will often in fact result in a _lower_ runtime cost (since the cost is calculated as function execution time times available memory). There's a sweet spot at 1,5GB according to [this article](https://github.com/alexcasalboni/aws-lambda-power-tuning) from 2020.

### Reduce application size

The more classes you squeeze into your application, the longer it will take to initialize. I wouldn't say that you should go so far as to avoid introducing new classes to your codebase wherever it makes the code more readable and maintainable, but there are two other approaches you should follow which gives a much larger payoff:

- Get rid of unnecessary dependencies. Lean towards using Java native functions instead of bringing in Apache commons (for example, use the native Java 11 HTTP client instead of Apache). Try to replace AWS v1 clients with their v2 counterparts. Less is faster.
- Get rid of unreferenced classed using [Proguard](https://github.com/Guardsquare/proguard).

### Leverage boosted CPU access

During the initialization phase, AWS actually gives you access to much more CPU power than the capped limit you will have during your normal lambda execution. You can leverage this by initializing heavy-to-load clients (such as any AWS clients) in the constructor or as static variables, so that they will be initialized when the lambda has access to the boosted CPU power. This holds whenever you have to initialize clients that will be needed during most lambda executions. On the other hand, if you have clients that will normally not be used except for a few corner cases, it could make more sense to only initialize them when they are actually needed. You will have to use your common sense here.

### Run lambdas outside of VPC

Launching a lambda function inside a VPC adds a lot of time to your cold starts. Therefore you should investigate if you can have an architecture where you do not need to have your lambdas running inside a VPC.

## Conclusion

As described in this blog post, there are a few methods that can be used in order to minimize the cold start times for your Java lambdas. For more details, have a look at [this great talk](https://youtu.be/ddg1u5HLwg8) from re:Invent. However, you will not be able to get rid of the cold start times completely this way. If you are running a performance critical service, you should instead consider switching to another programming language than Java (i.e. Node.js, Go or Python) or another hosting method than AWS Lambda (i.e. containerized application).

By Gustav Sundin & Rickard Andersson
