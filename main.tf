# Configure terraform and required providers
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.0"
    }
  }
}

# Configure the Docker provider
provider "docker" {
  host = "npipe:////.//pipe//docker_engine"
}

# Create a Docker volume for persistent Jenkins data
resource "docker_volume" "jenkins_home" {
  name = "jenkins_home"
  driver = "local"
}

# Pull the Jenkins Docker image
resource "docker_image" "jenkins" {
  name = "jenkins/jenkins:lts"
  keep_locally = true
}

# Create the Jenkins container
resource "docker_container" "jenkins" {
  name  = "jenkins"
  image = docker_image.jenkins.image_id
  
  ports {
    internal = 8080
    external = 8080
  }
  
  ports {
    internal = 50000
    external = 50000
  }
  
  volumes {
    volume_name    = docker_volume.jenkins_home.name
    container_path = "/var/jenkins_home"
  }
  
  restart = "unless-stopped"
}

# Output important information
output "jenkins_url" {
  value = "http://localhost:8080"
  description = "The URL to access Jenkins"
}

output "jenkins_container_id" {
  value = docker_container.jenkins.id
  description = "The ID of the Jenkins container"
}