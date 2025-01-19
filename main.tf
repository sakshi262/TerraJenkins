terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "docker" {
  host = "npipe:////.//pipe//docker_engine"
}

# Create custom network
resource "docker_network" "web_network" {
  name = "web_network"
}

# Create Nginx container
resource "docker_container" "nginx" {
  name  = "webapp"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = 8080
  }

  networks_advanced {
    name = docker_network.web_network.name
  }

  volumes {
    host_path      = "${abspath(path.root)}/app"
    container_path = "/usr/share/nginx/html"
    read_only      = true
  }
}

# Pull Nginx image
resource "docker_image" "nginx" {
  name = "nginx:latest"
}