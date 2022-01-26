---
title: "How I've automated the setup of my virtual server"
date: 2022-01-21T05:57:22+01:00
tags: [ Automation, Infrastructure as Code, AWS, Terraform, Ansible, Github Actions]
description: ""
---
Lately I've been looking for a good way of hosting some personal projects. I wanted something relatively cheap which I could use to host multiple services. A colleague of mine have for a long time used a single virtual server (more specifically, an EC2 instance in AWS) where he runs multiple services inside docker containers. To enable access to each individual service, there's a nginx reverse proxy that forwards traffic to services. I decided to try the same approach.

![EC2 instance, with docker containers and nginx reverse proxy](/blog/ec2-docker.png)

The server accepts traffic on port 80 and 443. To decide which service that should receive a request, nginx inspects the hostname of the request and forwards traffic to respective service (docker container).

To accomplish this I will need a bunch of things. First of all I need an EC2 instance in AWS. Second, docker, and perhaps docker-compose will need to be installed in order to run services. Finally, the nginx reverse proxy must be configured and started in some way. One approach would be to manually create an EC2 instance in the AWS portal, SSH into the server, install and configure everything. But what if I would later accidently delete my server? Or AWS has an outage affecting my server? Then there's a risk I'll have to recreate my server and configure everything from scratch again, and when that happens, I probably won't remember how I've configured it in the first place.

This calls for automation! Steps I take to deploy and configure the server can be described in code and executed by software. This has a lot of advantages. There's no risk of me forgetting how I've deployed and configured the server (since I have it described in code), and if I for some reason need to repeat the whole process, I can simply execute the steps again.

In this post I will describe how I've automated this process. The automation runs in a [Github Actions](https://github.com/features/actions) workflow, where I use [Terraform](https://www.terraform.io/) and [Ansible](https://www.ansible.com/) to deploy and configure my server. Note that I will not go into detail on how to use the respective tools, but rather describe the general process of deploying and configuring my server with the tools.

# Deploy server

First of all, I need a virtual server. As described above I'll go for an EC2 instance hosted in AWS. To have it deployed to my AWS account I use Terraform.

Terraform is a great tool which lets you automate deployment of resources in different cloud environments (such as AWS, GCP, Azure). To use it, you describe what resources you need to create in templates with a language/syntax called HCL. Then, you use the Terraform CLI to *apply* these templates to your cloud environment. To apply means to create, update or delete resources in the cloud environment to reflect what you've described in your templates.

Below is a subset of the template containing resources I need for my server. Apart from that the template also includes a bunch of network-related resources and domain names. You can see the full template [here](https://github.com/Dunklas/app-server/tree/main/iac).

```hcl
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer.id
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]
  subnet_id              = aws_subnet.subnet.id
}

resource "aws_eip" "ip" {
  instance = aws_instance.app_server.id
  vpc      = true
}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_pair_name
  public_key = var.key_pair_public_key
}

output "server_ip" {
  value = aws_eip.ip.public_ip
}
```
The resource of type `aws_instance` describes the actual EC2 instance. It's of type `t2.micro` and uses an ubuntu image. To deploy these resources I run a [github actions workflow](https://github.com/Dunklas/app-server/blob/main/.github/workflows/main.yml) where I use the Terraform CLI to have these resources created in my AWS account.

So, I now have a virtual server that runs Ubuntu, but there's still stuff left to do. I need to install docker and configure the nginx reverse proxy. In order to do this automatically in a github actions workflow I need to: (1) have knowledge about what IP address the new server have; (2) be able to access the new server via SSH.

In above terraform template you can see that I've used an `aws_eip` resource to assign an [elastic IP address](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html) to the EC2 instance. Further, I expose the actual IP adress as an output. By doing this, I can query what IP address that has been assigned to the new server with the Terraform CLI by running the following command: `terraform output -raw server_ip`.

To enable access to the server via SSH I have associated a `aws_key_pair` resource to the EC2 instance. Prior to applying the terraform template I've generated an SSH key pair and included the public key in the `public_key` property. This means that I will be able to use the private key of the key pair to authenticate to the server via SSH. I've added the private key as a repository secret in order to access it from my github actions workflow.

# Configure server

Now I have a server running Ubuntu. I also have knowledge about what IP address the server have, and I have a private key which I can access from my github actions workflow in order to authenticate to the server. To actually do things (such as installing applications) on the server I use [Ansible](https://www.ansible.com).

With Ansible you write *playbooks* that contains a sequence of *tasks*, and each task describes a desired state (e.g. application X is installed, or user Y is member of group Z). Then you can run these playbooks on a remote machine (or many) to get the desired state. By default Ansible uses SSH in order to execute commands on a remote machine.

Below are some of the tasks from my playbook that are responsible for making sure that docker is installed. You can see the full sequence of tasks for installing docker and docker-compose [here](https://github.com/Dunklas/app-server/blob/main/playbooks/docker-install.yml).

```yaml
- name: Set up the stable repository
  apt_repository:
    repo: deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable
    state: present
    update_cache: yes
- name: Update apt packages
  apt:
    update_cache: yes
- name: Install docker
  apt:
    name: docker-ce
    state: present
    update_cache: yes
```

To tell Ansible what remote machine(s) to run a playbook on you provide an inventory file. This file can have many [different formats](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html), but the essence of it is that it describes what machines to run on, and optionally how Ansible should interact with the machine(s).

To enable Ansible to authenticate to the server, I found it easiest to start an ssh-agent and use `ssh-add` to add the private key mentioned in the previous section.

Below is a part of my github actions workflow (full version available [here](https://github.com/Dunklas/app-server/blob/main/.github/workflows/main.yml)) where I create an inventory file, start an ssh-agent and then runs my ansible playbook on the new server.

```yaml
steps:
  - uses: actions/checkout@v2
  - run: echo ${{ env.SERVER_IP }} >> inventory.ansible
  - name: Setup SSH key
    run: |
      ssh-agent -a $SSH_AUTH_SOCK > /dev/null
      ssh-add - <<< $(echo "${{ secrets.SSH_PRIVATE_KEY }}" | base64 -d)
  - name: Add server to known hosts
    run: mkdir ~/.ssh && ssh-keyscan -H ${{ env.SERVER_IP }} >> ~/.ssh/known_hosts
  - name: Configure server
    run: |
      ansible-playbook \
        --inventory inventory.ansible \
        --user ubuntu \
        main.yml
```

So, by running Ansible in my github actions workflow I can make sure that certain applications are installed on the new server after it has been created. Apart from installing docker and docker compose, I also need to have a reverse proxy up and running.

## Reverse proxy

As reverse proxy I use [Frontman](https://github.com/DeviesDevelopment/frontman). Frontman launches an nginx instance that redirects traffic to one of many locally running Docker containers based on the base URL of the incoming requests, which is exactly what we want to do.

To use Frontman, you need to create a configuration file that declares what domain names it should redirect traffic for. For each domain name, you also specify an upstream port that traffic will be redirected to. With the configuration file in place, you can launch Frontman by running `make start`.

Now, how do I make sure that Frontman is automatically started on the new server? Above I used Ansible to ensure that certain applications are installed. However, you can use Ansible for much more than that.

Each Ansible task uses a *[module](https://docs.ansible.com/ansible/latest/user_guide/modules_intro.html)*. To install docker I used modules such as [apt-repository](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_repository_module.html) and [apt](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_module.html). To make sure Frontman is started I instead use the modules [git](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/git_module.html), [copy](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html) and [make](https://docs.ansible.com/ansible/2.9/modules/make_module.html) in order to: (1) Clone the Frontman repository; (2) Copy configuration file to server; (3) Run `make start` to launch Frontman. You can see the full sequence of tasks [here](https://github.com/Dunklas/app-server/blob/main/playbooks/configure-proxy.yml).

# Final thoughts

I really enjoy infrastructure as code and automation in general. Since everything is described in code, I have a complete understanding of how I've configured my server, and of what resources I use in my AWS account. If the need should arise, I can tear down my server and recreate it from scratch just by running my github actions workflow. This gives me both comfort and confidence.

I did not cover how I deploy services (docker containers) to the server in this post. There's actually a few different ways you could do this, which I might cover in a future post.

If you're interested, everything I've described in this post is available in [this repository](https://github.com/Dunklas/app-server).
