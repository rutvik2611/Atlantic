# Use a base image that includes docker-compose and any necessary dependencies
FROM docker/compose:latest

# Set the working directory inside the container
WORKDIR /app

# Copy .env and docker-compose.yml into the container's /app directory
COPY .env .
COPY docker-compose.yml .

# Entry point to run docker-compose up when the container starts
ENTRYPOINT ["docker-compose", "up"]
# Use an Ubuntu base image that we can customize
# Use an Ubuntu base image that we can customize
#FROM ubuntu:latest
#
## Install dependencies including Docker, Python, and pip
#RUN apt-get update && apt-get install -y \
#    docker.io \
#    python3 \
#    python3-pip \
#    curl \
#    jq \
#    && rm -rf /var/lib/apt/lists/*
#
## Install docker-compose using the official release URL for the correct architecture
#RUN curl -s https://api.github.com/repos/docker/compose/releases/latest \
#    | jq -r '.tag_name' \
#    | xargs -I {} curl -L "https://github.com/docker/compose/releases/download/{}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
#    && chmod +x /usr/local/bin/docker-compose
#
## Set the working directory inside the container
#WORKDIR /app
#
## Copy .env, ClipSync, and docker-compose.yml into the container's /app directory
#COPY .env .
#COPY docker-compose.yml .
#
## Install Python dependencies if any (optional)
## COPY requirements.txt .
## RUN pip install -r requirements.txt
#
## Entry point to run docker-compose up when the container starts
#ENTRYPOINT ["docker-compose", "up"]
