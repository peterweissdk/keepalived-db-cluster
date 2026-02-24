# 💾 Keepalived container with Galera check-script

[![Static Badge](https://img.shields.io/badge/Docker-Container-white?style=flat&logo=docker&logoColor=white&logoSize=auto&labelColor=black)](https://docker.com/)
[![Static Badge](https://img.shields.io/badge/Alpine-V3.22-white?style=flat&logo=alpinelinux&logoColor=white&logoSize=auto&labelColor=black)](https://www.alpinelinux.org/)
[![Static Badge](https://img.shields.io/badge/KeepAliveD-V2.3.2-white?style=flat&logoColor=white&labelColor=black)](https://keepalived.org/)
[![Static Badge](https://img.shields.io/badge/GPL-V3-white?style=flat&logo=gnu&logoColor=white&logoSize=auto&labelColor=black)](https://www.gnu.org/licenses/gpl-3.0.en.html/)

A lightweight, Alpine-based Docker container for running Keepalived with VRRP (Virtual Router Redundancy Protocol) support and MariaDB Galera cluster state monitoring.

**💡 This container is a slightly modified version of [peterweissdk/keepalived](https://github.com/peterweissdk/keepalived/), with an added check script for monitoring the state of a MariaDB Galera cluster. It is designed to be used in conjunction with [peterweissdk/galera-compose](https://github.com/peterweissdk/galera-compose), which sets up and runs a MariaDB Galera cluster.**


## ✨ Features

- **Alpine-based**: Lightweight and secure base image
- **VRRP support**: High availability with Virtual Router Redundancy Protocol (VRRP)
- **Easy Configuration**: Configure Keepalived using environment variables, and service check-scripts
- **Health Checks**: Monitor service health with built-in Docker health checks

## 🚀 Quick Start

Run the container:
```bash
# Pull the image
docker pull peterweissdk/keepalived

# Run with custom configuration
docker run -d \
  --name keepalived \
  --restart=unless-stopped \
  --cap-add=NET_ADMIN \
  --cap-add=NET_BROADCAST \
  --cap-add=NET_RAW \
  --net=host \
  --env-file .env \
  keepalived:latest

# Run the container using the provided Docker Compose and .env file
docker compose up -d
```

## 🔧 Configuration

### Environment Variables

| Variable         | Description                                 | Example           |
|------------------|---------------------------------------------|-------------------|
| `TZ`             | Container timezone                          | Europe/Copenhagen |
| `VRRP_INSTANCE`  | VRRP instance name                          | VI_1              |
| `INTERFACE`      | Network interface                           | eth0              |
| `STATE`          | Node state (MASTER/BACKUP)                  | MASTER            |
| `PRIORITY`       | Node priority (1-255)                       | 100               |
| `ROUTER_ID`      | Unique router ID                            | 52                |
| `VIRTUAL_IPS`    | Virtual IP address with subnet mask         | 192.168.1.100/24  |
| `UNICAST_SRC_IP` | Source IP for unicast communication         | 192.168.1.101     |
| `UNICAST_PEERS`  | Peer IP addresses for unicast communication | 192.168.1.102     |
| `WEIGHT`         | Weight for tracked scripts                  | 50                |
| `FALL`           | Number of failures before transition        | 2                 |
| `RISE`           | Number of successes before transition       | 2                 |

### Required Capabilities

- NET_ADMIN: For network interface configuration
- NET_BROADCAST: For VRRP advertisements
- NET_RAW: For raw socket access

### Service Check-Script

Create a script to run at regular intervals to check the state of your service. Create a bind mount and copy the script into it
- Name of script: check-script.sh
- Bind mount point: /usr/local/scripts/
- Runs at regular intervals: 2 seconds

## 🏗️ Building from Source

```bash
# Clone the repository
git clone https://github.com/peterweissdk/keepalived-db-cluster.git
cd keepalived-db-cluster

# Build the image
docker build -t keepalived:latest .
```

## 📝 Directory Structure

```bash
keepalived-db-cluster/
├── check-script
│   └── check-script.sh
├── conf/
│   └── keepalived.conf_tpl
├── scripts/
│   └── check_and_run.sh
├── .env
├── Dockerfile
├── docker-entrypoint.sh
├── healthcheck.sh
├── docker-compose.yml
├── LICENSE
└── README.md
```

## 🔍 Health Check

The container includes a comprehensive health check system that monitors:

1. Keepalived Process Status
   - Verifies the keepalived daemon is running

2. Virtual IP environment variable
   - Verifies the VIRTUAL_IPS environment variable is set

View health status:
```bash
docker inspect --format='{{.State.Health.Status}}' keepalived
```
View detailed health check history:
```bash
docker inspect --format='{{json .State.Health}}' keepalived | jq
```
Watch health status in real-time:
```bash
watch -n 5 'docker inspect --format="{{.State.Health.Status}}" keepalived'
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 🆘 Support

If you encounter any issues or need support, please file an issue on the GitHub repository.

## 📄 License

This project is licensed under the GNU GENERAL PUBLIC LICENSE v3.0 - see the [LICENSE](LICENSE) file for details.