---
title: "The kubectl wait Command"
date: 2022-05-27T10:48:19+02:00
tags: [Kubernetes]
description: "How to use the kubectl wait command"
slug: "kubectl-wait-command"
author:
 - Fredrik Mile
---
Last week, while writing end-to-end tests for our Kubernetes application, we discovered a useful Kubernetes command. Namely, the `kubectl wait` command. We managed to stabilize our test using this command, and we will explain how we did it in this post.

We have written our end-to-end tests in bash,  and they deploy and manage different Kubernetes resources. Bash scripts execute commands sequentially, waiting for the first to finish before executing the next one. Consider the following script, where we first deploy an Nginx instance and then read its logs.

```bash
#!/bin/bash

# Deploy a simple nginx pod
kubectl apply -f https://k8s.io/examples/pods/simple-pod.yaml
# Read logs from nginx
kubectl logs nginx
```

This script will fail with the following error message: `Error from server (BadRequest): container "nginx" in pod "nginx" is waiting to start: ContainerCreating`, meaning that we tried to read the logs before the pod is up and running. We need to wait for the pod to reach its ready state before reading the logs, which we achieve with the kubectl wait command.

```bash
#!/bin/bash

# Deploy a simple nginx pod
kubectl apply -f https://k8s.io/examples/pods/simple-pod.yaml
# Wait until the pod is ready
kubectl wait --namespace default \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=nginx \
# Read nginx logs
kubectl logs nginx
```

The `kubectl wait` command takes a condition that needs to be met before the wait is over.

See the [official documentation](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#wait) of `kubectl wait` for more detailed information and examples.

