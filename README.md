# Atlantic Project (WORK IN PROGESS...)

Atlantic is a Docker-based application designed to streamline and manage various services within a single Docker ecosystem. It encompasses several pre-configured Docker images for key applications, including reverse proxy, torrent management, media streaming, cloud storage, and VPN.

## Table of Contents

1. [Project Overview](#project-overview)
2. [Docker Images](#docker-images)
    - [Traefik (Reverse Proxy)](#traefik-reverse-proxy)
    - [rTorrent (Torrent Management)](#rtorrent-torrent-management)
    - [Jellyfin (Media Streaming)](#jellyfin-media-streaming)
    - [Nextcloud (Cloud Storage)](#nextcloud-cloud-storage)
    - [OpenVPN (VPN)](#openvpn-vpn)
3. [Getting Started](#getting-started)
4. [Configuration](#configuration)
5. [Deployment](#deployment)
6. [Contributing](#contributing)
7. [License](#license)

## Project Overview

Atlantic brings together multiple Docker images to create a comprehensive system for handling web services, torrent downloading, media streaming, cloud storage, and VPN. The project is aimed at providing a cohesive and easy-to-deploy solution for managing these services with minimal effort.

## Docker Images

### Traefik (Reverse Proxy)

Traefik is a modern HTTP reverse proxy and load balancer that makes deploying microservices easy. It supports automatic discovery of services and can dynamically update its configuration.

- **Image**: `traefik:latest`
- **Configuration**: Automatically discovers other services via Docker labels.

### rTorrent (Torrent Management)

rTorrent is a command line-based BitTorrent client. For a better user experience, it can be paired with ruTorrent, a web-based GUI for rTorrent.

- **Image**: `linuxserver/rutorrent:latest`
- **Configuration**: Accessible via Traefik with its own subdomain.

### Jellyfin (Media Streaming)

Jellyfin is a free software media system that puts you in control of managing and streaming your media.

- **Image**: `jellyfin/jellyfin:latest`
- **Configuration**: Accessible via Traefik with its own subdomain.

### Nextcloud (Cloud Storage)

Nextcloud is a suite of client-server software for creating and using file hosting services.

- **Image**: `nextcloud:latest`
- **Configuration**: Accessible via Traefik with its own subdomain.

### OpenVPN (VPN)

OpenVPN is a robust and highly flexible VPN daemon which allows you to securely connect to your network.

- **Image**: `kylemanna/openvpn:latest`
- **Configuration**: Requires initial setup to create server configuration and client keys.

## Getting Started

To get started with Atlantic, ensure you have Docker and Docker Compose installed on your system.

1. Clone the repository:
    ```bash
    git clone https://github.com/yourusername/atlantic.git
    cd atlantic
    ```

2. Create a `.env` file from the example and update it with your configuration:
    ```bash
    cp .env.example .env
    nano .env
    ```

3. Start the Docker services:
    ```bash
    docker-compose up -d
    ```

## Configuration

Configuration details for each service can be adjusted in the `docker-compose.yml` file and the `.env` file. Key configurations include network settings, service-specific settings, and Traefik labels for routing.

### OpenVPN Configuration

To set up OpenVPN, follow these steps:

1. Initialize the OpenVPN configuration:
    ```bash
    docker run -v $PWD/openvpn-data:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u udp://YOUR_DOMAIN
    docker run -v $PWD/openvpn-data:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki
    ```

2. Start the OpenVPN container:
    ```bash
    docker-compose up -d openvpn
    ```

3. Generate client certificates:
    ```bash
    docker run -v $PWD/openvpn-data:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full CLIENTNAME nopass
    docker run -v $PWD/openvpn-data:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient CLIENTNAME > CLIENTNAME.ovpn
    ```

## Deployment

Deploying Atlantic involves using Docker Compose to manage the multi-container setup. Ensure that your system meets the required specifications and that you have correctly configured the `.env` and `docker-compose.yml` files.

1. Build and start the containers:
    ```bash
    docker-compose up -d --build
    ```

2. Monitor the logs to ensure all services are running correctly:
    ```bash
    docker-compose logs -f
    ```

## Contributing

We welcome contributions to the Atlantic project. If you have any improvements or new features to suggest, please submit a pull request or open an issue on the GitHub repository.

## License

Atlantic is released under the MIT License. See the [LICENSE](LICENSE) file for more details.
