# Configure terraform and required providers
terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

# Configure the Docker provider
provider "docker" {
  host = "unix:///var/run/docker.sock"
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
  
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }
  
  restart = "unless-stopped"
}