# Rishi's Homelab

The purpose of this repo is to document my journey and the processes I use through building my homelab and eventually turing it into a datacenter! This is a side project I actively maintain in my free time mostly in evenings or over weekends. 

![Alt text](/archive/images/homelab.png)

# <img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Hammer%20and%20Wrench.png" alt="Hammer and Wrench" width="25" height="25" /> Servers

At present, I have 2 servers both of which I built from ordering the below parts:

## <img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Pager.png" alt="Pager" width="25" height="25" /> Server 1 - Proxmox Node
- CPU: Ryzen 5 4600G 
- RAM: 48GB 3200mhz (32 + 16)
- PSU: 600W EVGA
- Mobo: ASUS Prime B450-M II
- Storage: 512GB M.2+ 2TB SSD
  - The OS is installed on the M.2 and any LXCs and VMs will be stored on the 2TB SSD
  - Any media such as films/music/games will be stored on my NAS through SMB shares
- Chassis: 3U Case

## <img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Pager.png" alt="Pager" width="25" height="25" /> Server 2 - TrueNAS Scale 
- CPU: Ryzen 5 2600 
- RAM: Corsair Vengence 16GB 3200mhz (8 + 8)
- PSU: 700W Aerocool
- Mobo: Gigabyte B450M DS3H
- Storage: 512GB M.2 + x4 4TB SSD (RAID 1 array)
  - The OS is installed on the M.2 and both 4TB SSDs are used in a RAID 1 Array for the NAS
- Chassis: 2U Case

All equipment sits in a 12U 19" rack all of which is cable managed using cable ties.

# <img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Wireless.png" alt="Wireless" width="25" height="25" /> Networking

## Hardware

- [Unifi Dream Machine Pro](https://eu.store.ui.com/eu/en/products/udm-pro)
- x2 [U6 Lites](https://eu.store.ui.com/eu/en/products/u6-lite)
- Standard ISP provided modem (in bridge mode)
- CAT 6 ethernet throughout

Notes: 
- I have assigned a "Trunk Port" to the Proxmox Server to allow for putting LXCs on other VLANs, this is esspecially useful when exposing services to the public and following the "Zero Trust" security model. 
- 1 access point is connected via ethernet and the other is connected using `wireless uplinking`.


## Software

My entire network infrastructure is powered by Ubiquiti hardware and their software "Unifi".

I have created a VLAN for my homelab on the `10.0.30.0/24` subnet and I have set the VLAN ID to `30` for the sake of simplicity and ease of management. This network does not have any `content filtering` applied and DHCP is set to `auto`. Note I have not setup a WIFI network for my homelab as everything runs through ethernet.

The following IP addresses have been reserved due to me frequently accessing them:
- `10.0.30.2` - Proxmox server
- `10.0.30.3` - TrueNAS Scale server

While I have setup local DNS through [Nginx Proxy Manager](https://nginxproxymanager.com/) I will still be able to access both the Proxmox and NAS servers if my reverse proxy goes down. (More on Nginx Proxy Manager later). My firewall offers the option of setting local DNS however I have not found this to be reliable. 

### Network Segmentation

Segregating my homelab is very important esspecially if I am exposing services to the public internet, I have configured network segmentation on my firewall with the following config:

- Main network (`10.0.0.0/24`) can establish communications to my homelab network (`10.0.30.0/24`)
- Homelab network (`10.0.30.0/24`) can not establish communications to all other networks unless needed. For example, if a service required access to another service outside the homelab network I would only give access on a per IP basis. 

I am always looking to improve the security of my network and in the future I'll be looking into segregating my NAS from all LXCs/VMs unless specified. 

When it comes to my cameras, I have setup a separate VLAN for this on the `.20` subnet.

### Intrusion Prevention System

When choosing my firewall I wanted to ensure it supports an IDS or an IPS due to the services I'll be running and exposing. Currently I have enabled and set my IPS to the highest sensitivity available so it will detect and block the following:

![Alt text](/archive/images/ips.png)

While setting to the highest sensitivity I have fortunately not noticed any distruptions of services in my homelab! Further to enforcing an IPS I have enabled geo based blocking. 

# <img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Locked.png" alt="Locked" width="25" height="25" />   Security 

## Nginx Proxy Manager

Nginx Proxy Manager allows me to easily access services internally using my domain name (`alph4.xyz`). When it comes to exposing services to the internet I would use Cloudflare Tunnels. Nginx Proxy Manager is running on my Proxmox node inside an LXC container using Docker compose:

```
version: '3.8'
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '80:80'
      - '81:81'
      - '443:443'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
networks:
  default:
    external: true
    name: nginx-rp
```

To ensure all containers are up to date across my homelab I use a service called [Watchtower](https://github.com/containrrr/watchtower). 

When it comes to configuring Nginx PM I would give a service its own subdomain under my domain, for example, `ansible` would be `ansible.alph4.xyz`, with my domain being mamaged on Cloudflare it was quite easy to configure. I setup an A record (DNS only - reserved IP) with the IP of my LXC container as well as creating an API key. With this, the configuration was quite easy when it came to the Nginx dashboard. 

![Alt text](/archive/images/nginxpm.png)

Nginx Proxy Manager also allows me to request new SSL certificates for each of the services I am running, this prevents any password sniffing over the network as traffic is all encrypted.

![Alt text](/archive/images/ssl.png)

## <img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Old%20Key.png" alt="Old Key" width="25" height="25" /> Authelia

To further enhance the security of my network and services I run I have incorporated [Authelia](https://www.authelia.com/) which allows me to setup MFA for any services that have web portals.

Configuration for Authelia is done through Nginx Proxy Manager and I have attached the config I use in the `docker-compose-files/authelia/` directory of this repo. 

![Alt text](/archive/images/image2.png)

# Automation through Ansible

I utilise Ansible as one of the main tools for automation in my homelab. I've created a number of scripts [here](https://github.com/rxerium/ansible) that I use to streamline tasks, such as provisioning servers or configuring containers. For instance, when creating a new LXC container in my Proxmox cluster, I like to follow security best practices by running an Ansible script that configures SSH keys and disables password authentication. This ensures that my containers are secure from the outset.

![Alt text](/archive/images/ansible-tasks.png)


Ansible Semaphore relies on an inventory of hosts (host list) to determine which scripts to run on. To populate this inventory, I've created a [GitHub Action script](https://github.com/rxerium/ansible/blob/main/.github/workflows/online-hosts.yaml) that scans for online hosts on the 10.0.30.0/24 subnet in my infrastructure and outputs the results to a file. This file is then read by Ansible to determine which hosts are available for automation. The script runs on a weekly basis, ensuring that my inventory stays up-to-date and accurate.

![Alt text](/archive/images/ansible-dash.png)

Ansible has revolutionised my homelab by enabling me to automate routine tasks, freeing up time for other projects. With Ansible, I can quickly deploy and manage multiple nodes, ensure consistent configurations across my infrastructure, and even orchestrate complex workflows. Additionally, Ansible's agentless architecture means I don't need to install additional software on each server/VM/CT, making it a lightweight and highly effective automation solution that has greatly simplified my homelab management.

---

**THIS README IS STILL A WORK IN PROGRESS**

Things to add to this readme:
- [x] Networking
  - [ ] Internet speeds
  - [ ] Traffic routing and proxying 
- [x] Hardware
- [x] Software running on bare metal
- [x] Proxy Manager
- [x] Web app authentication
- [x] Orchestration software I use for automation
- [ ] AI and local LLMs
- [ ] Monitoring of servers/containers/VMs
- [ ] Incident Response
- [ ] Admin
  - [ ] Costs & aintenance
  - [ ] Documentation
  - [ ] Task / project management
- [ ] Future projects/ideas