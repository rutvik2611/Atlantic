# Use a base image that includes docker-compose and any necessary dependencies
FROM docker/compose:latest

# Set the working directory inside the container
WORKDIR /app

# Copy .env and docker-compose.yml into the container's /app directory
COPY .env .
COPY docker-compose.yml .

# Entry point to run docker-compose up when the container starts
ENTRYPOINT ["docker-compose", "up"]
