---
title: "Trick your local web server using the Host header"
date: 2022-05-20T14:56:30+02:00
tags: [ nginx, DNS ]
featured_image: ""
description: ""
slug: "trick-local-web-server-using-host-header"
author:
 - Rickard Andersson
---

**TLDR**: If you need to "trick" a local web server that you're making requests to a certain domain, but do not want (or have permissions) to modify `/etc/hosts` - Set the intended domain in the `Host` request header instead.

---

We are currently working on a project where we have an nginx instance that is redirecting traffic for many different domains. In our case, the nginx is an ingress controller in a kubernetes cluster, but you might use a similar approach if you're hosting multiple websites on the same webserver.

During development we often need to make requests to an nginx that runs locally, but have it behave as if a request was made to e.g. *my-domain.com*. A common approach to accomplish this is to modify the [`/etc/hosts`](https://en.wikipedia.org/wiki/Hosts_(file)) file so that *my-domain.com* resolves to *localhost*. However, this might not always be feasible or possible. If you need to change the domain often, it can be cumbersome to make file changes in between, or perhaps you need to do this on a machine where you don't have permissions to modify the file (e.g. a build agent).

In cases like this, you can instead set the `Host` request header to the intended domain. For example, to make a request to *localhost* but have the web server behave as if the request was made to *my-domain.com*:

```bash
curl localhost -H Host:my-domain.com
```

For the project I mentioned above we use this approach when running end-to-end tests in our CI pipeline.
