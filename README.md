# Rishi's Homelab

The purpose of this repo is to document my journey and the processes I use through building my homelab and eventually turing it into a datacenter! This is a side project I actively maintain in my free time mostly in evenings or over weekends. 

# Servers

At present, I have 2 servers both of which I built from ordering the below parts:

## Server 1 - Proxmox Node
- CPU: Ryzen 5 4600G 
- RAM: 48GB 3200mhz (32 + 16)
- PSU: 600W EVGA
- Mobo: ASUS Prime B450-M II
- Storage: 512GB M.2+ 2TB SSD
  - The OS is installed on the M.2 and any LXCs and VMs will be stored on the 2TB SSD
  - Any media such as films/music/games will be stored on my NAS through SMB shares
- Chassis: 3U Case

## Server 2 - TrueNAS Scale 
- CPU: Ryzen 5 2600 
- RAM: Corsair Vengence 16GB 3200mhz (8 + 8)
- PSU: 700W Aerocool
- Mobo: Gigabyte B450M DS3H
- Storage: 512GB M.2+ x2 4TB SSD
  - The OS is installed on the M.2 and both 4TB SSDs are used in a RAID 1 Array for the NAS
- Chassis: 2U Case

All equipment sits in a 12U 19" rack all of which is cable managed using cable ties.

# Networking

## Hardware

- [Unifi Dream Machine Pro](https://eu.store.ui.com/eu/en/products/udm-pro)
- x2 [U6 Lites](https://eu.store.ui.com/eu/en/products/u6-lite)
- Standard ISP provided modem (in bridge mode)
- CAT 6 ethernet throughout

Note: I have assigned a "Trunk Port" to the Proxmox Server to allow for putting LXCs on other VLANs, this is esspecially useful when exposing services to the public and following the "Zero Trust" security model. 


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

- Virus and malware
  - Botcc
  - Worm
  - Trojan
  - Malware
  - Mobile Malware
- P2P
  - TOR
  - P2P
- Hacking
  - Exploits
  - Attack response
  - Scans
  - Shellcode
  - DoS
- Internet Traffic
  - SQL
  - User agents
  - DNS
- IPs with bad repuation
  - CI Army
  - Comprimsed
  - DSheild
- Network protocol
  - FTP
  - IMAP
  - SMTP
  - POP3
  - ICMP
  - TELNET
- Advanced Protocol
  - SNMP
  - VOIP 

While setting to the highest sensitivity I have not noticed any distruptions of services in my homelab! Further to my IPS I have enabled geo based blocking. 

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

Nginx Proxy Manager also allowed me to request new SSL certificates for each of the services I am running, this prevents any password sniffing over the network. 


## Authelia

To further enhance the security of my network and services I run I have incorporated [Authelia](https://www.authelia.com/) which allows me to setup MFA for any services that have web portals. 



This Readme is still a WIP...