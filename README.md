# Rishi's Homelab

The purpose of this repo is to document my journey and the processes I use through building my homelab and eventually turing it into a datacenter! This is a side project I actively maintain in my free time mostly in evenings or over weekends. 

# Servers

Currently I have 2 servers both of which are custom built by myself. Below are the specs for each:

## Server 1 - Proxmox Node
- CPU: Ryzen 5 4600G 
- RAM: 48GB 3200mhz (32 + 16)
- PSU: 600W EVGA
- Mobo: ASUS Prime B450-M II
- Storage: 512GB M.2+ 2TB SSD
  - The OS is installed on the M.2 and any LXCs and VMs will be stored on the 2TB SSD
- Chassis: 3U Case

## Server 2 - TrueNAS Scale 
- CPU: Ryzen 5 2600 
- RAM: Corsair Vengence 16GB 3200mhz (8 + 8)
- PSU: 700W Aerocool
- Mobo: Gigabyte B450M DS3H
- Storage: 512GB M.2+ x2 4TB SSD
  - The OS is installed on the M.2 and both 4TB SSDs are used in a RAID 1 Array for the NAS
- Chassis: 2U Case


All equipment sits in a 12U 19" rack all cable using cable ties.

# Networking

## Hardware

- [Unifi Dream Machine Pro](https://eu.store.ui.com/eu/en/products/udm-pro)
- x2 [U6 Lites](https://eu.store.ui.com/eu/en/products/u6-lite)
- Modem (in bridge mode) provided by my ISP
- CAT 6 ethernet cables

Note: I have assigned a "Trunk Port" to my Proxmox Server to allow me to put LXCs I need on other VLANs, this is esspecially useful when exposing services to the public and following the "Zero Trust" security framework. 


## Software

With years of experience of setting up networks for various organisatons setting up my internal network was fairly easy. My entire network infrastructure is powered by Ubuquiti and their software "Unifi". 

I have create a VLAN for my homelab on `10.0.30.0/24` and I have set the VLAN ID to `30` for the sake of simplicity. I have not applied any "Content filtering" and DHCP is set to auto. Note I have not setup a WIFI network for my homelab as everything runs through ethernet. 

I have reserverd the following IP addresses as I access these very frequently:
- `10.0.30.2` - Proxmox server
- `10.0.30.3` - TrueNAS Scale

While I have setup local DNS through [Nginx Proxy Manager](https://nginxproxymanager.com/) I will still be able to access both the Proxmox and NAS servers if my reverse proxy goes down. More on Nginx Proxy Manager later. 

### Network Segmentation

Segregating my homelab is very important esspecially if I am exposing services to the public internet I have configured this on my firewall with the following config:

- Main network (`10.0.0.0/24`) can establish communications to my homelab network (`10.0.30.0/24`)
- Homelab network (`10.0.30.0/24`) can not establish communications to all other networks unless needed. For example, if a service required access to another service outside the homelab network I would only give access on a per IP basis. 

I am always looking to improve the security of my network and in the future I'll be looking into segregating my NAS from various containers and VMs. 

Note I have not setup a WIFI network for my homelab as everything runs through ethernet. When it comes to cameras, I have setup a separate VLAN for this on the `.20` subnet. 

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



