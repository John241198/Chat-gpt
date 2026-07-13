#!/bin/bash
# sudo apt update
# sudo apt install -y wget gnupg software-properties-common
# wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo apt-key add -
# sudo add-apt-repository --yes https://packages.adoptium.net/artifactory/deb
# sudo apt update
# sudo apt install temurin-21-jdk -y
# /usr/bin/java --version

# #install jenkins
# curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
# echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
# sudo apt-get update -y
# sudo apt-get install jenkins -y
# sudo systemctl start jenkins
# sudo systemctl status jenkins

# #install docker
# sudo apt-get update
# sudo apt-get install docker.io -y
# sudo usermod -aG docker ubuntu
# sudo usermod -aG docker jenkins
# newgrp docker
# sudo chmod 777 /var/run/docker.sock
# sudo systemctl restart jenkins
# docker run -d --name sonar -p 9000:9000 sonarqube:community

# # install trivy
# sudo apt-get install wget apt-transport-https gnupg lsb-release -y
# wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
# echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
# sudo apt-get update
# sudo apt-get install trivy -y

# # Install AWS CLI 
# curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# sudo apt-get install unzip -y
# unzip awscliv2.zip
# sudo ./aws/install

# # Install Node.js 16 and npm
# curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/nodesource-archive-keyring.gpg
# echo "deb [signed-by=/usr/share/keyrings/nodesource-archive-keyring.gpg] https://deb.nodesource.com/node_16.x focal main" | sudo tee /etc/apt/sources.list.d/nodesource.list
# sudo apt update
# sudo apt install -y nodejs

# # Install Terraform
# wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
# echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
# sudo apt update && sudo apt install terraform -y
# terraform --version

# # Install kubectl
# sudo apt update
# sudo apt install curl -y
# curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
# sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
# kubectl version --client

# New test image check to install packagers by default

# Redirect all output to a log file for debugging
exec > /var/log/user-data.log 2>&1
set -x

# Wait for apt lock to be released (unattended-upgrades holds it on first boot)
echo "Waiting for apt lock to be released..."
while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do
  sleep 5
done

sudo apt-get update -y
sudo apt-get install -y wget gnupg software-properties-common curl unzip lsb-release apt-transport-https

# Install Java 21 (Temurin) for Jenkins and build tooling
wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | sudo tee /usr/share/keyrings/adoptium.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/adoptium.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y temurin-21-jdk
/usr/bin/java --version

# Install Jenkins
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install jenkins -y

# Install Docker
sudo apt-get update -y
sudo apt-get install -y docker.io
sudo usermod -aG docker ubuntu
sudo usermod -aG docker jenkins
# Remove newgrp (not suitable for non-interactive scripts; socket permission below handles access)
sudo chmod 666 /var/run/docker.sock
sudo systemctl restart jenkins
docker run -d --name sonar -p 9000:9000 sonarqube:community

# Install Trivy
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/trivy.list
sudo apt-get update -y
sudo apt-get install -y trivy

# Install AWS CLI
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -o awscliv2.zip
sudo ./aws/install --update
aws --version

# Install Node.js 18 (LTS) and npm
# Note: node_16.x is EOL and removed; using node_18.x instead
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/nodesource.gpg
echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_18.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt-get update -y
sudo apt-get install -y nodejs
node --version
npm --version

# Install Terraform
wget -qO - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update -y
sudo apt-get install -y terraform
terraform --version

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client

echo "All packages installed successfully."

