---
title: "How I've automated the setup of my virtual server"
date: 2022-01-21T05:57:22+01:00
tags: [ Automation, Infrastructure as Code, AWS, Terraform, Ansible, Github Actions]
description: ""
---
Lately I've been looking for a good way of hosting some personal projects. I wanted some non-serverless way (mostly to avoid cold starts) to host primarily APIs and websites. A colleague of mine has for a long time used a single virtual server (more specifically, an EC2 instance in AWS) where he runs multiple services inside docker containers. To enable access to each individual service, there is an nginx reverse proxy that forwards traffic to services. I decided to try the same approach.

![EC2 instance, with docker containers and nginx reverse proxy](/ec2-docker.png)

The server accepts traffic on port 80 and 443. To decide which service that should receive a request, nginx inspects the hostname of the request and forwards traffic to respective service (docker container).

To accomplish this setup I will need a bunch of things. First of all I need an EC2 instance in AWS. Second, docker, and perhaps docker-compose will need to be installed in order to run services. Finally, the nginx reverse proxy must be configured and started in some way. One approach would be to manually create an EC2 instance in the AWS portal, SSH into the server, install and configure everything. But what if I would later accidently delete my server? Or AWS has an outage affecting my service? Then there's a risk I'll have to recreate my server and configure everything from scratch again, and when that happens, I probably won't remember how I've configured it in the first place.

This calls for automation! Steps I take to deploy and configure my server can be described in code and executed by software. This has a lot of advantages. There's no risk of me forgetting how I've deployed and configured my server (since I have it described in code), and if I for some reason need to repeat the whole process, I can simply execute the steps again.

In this post I will describe how I've automated this process. The automation will run in a [Github Actions](https://github.com/features/actions) workflow, where I use tools such as [Terraform](https://www.terraform.io/) and [Ansible](https://www.ansible.com/) to deploy and configure my server.

# Deploy server

# Configure server

# Deploy services