# -*- mode: ruby -*-
# vi: set ft=ruby :

# Configuration des VMs pour l'infrastructure Transcriber App
Vagrant.configure("2") do |config|
  
  # VM Master - Jenkins + Ansible Controller
  config.vm.define "master" do |master|
    master.vm.box = "ubuntu/focal64"
    master.vm.hostname = "master"
    master.vm.network "private_network", ip: "192.168.56.10"
    master.vm.network "forwarded_port", guest: 8080, host: 8080  # Jenkins
    master.vm.network "forwarded_port", guest: 80, host: 8000    # App via Nginx
    
    master.vm.provider "virtualbox" do |vb|
      vb.name = "transcriber-master"
      vb.memory = "2048"
      vb.cpus = 2
    end

    master.vm.provision "shell", path: "scripts/provision-master.sh"
  end

  # VM Worker - Application Docker
  config.vm.define "worker" do |worker|
    worker.vm.box = "ubuntu/focal64"
    worker.vm.hostname = "worker"
    worker.vm.network "private_network", ip: "192.168.56.11"
    worker.vm.network "forwarded_port", guest: 8501, host: 8501  # Streamlit
    worker.vm.network "forwarded_port", guest: 5432, host: 5433  # PostgreSQL
    
    worker.vm.provider "virtualbox" do |vb|
      vb.name = "transcriber-worker"
      vb.memory = "2048"
      vb.cpus = 2
    end

    worker.vm.provision "shell", path: "scripts/provision-worker.sh"
  end

  # VM Monitoring - Nagios
  config.vm.define "monitoring" do |monitoring|
    monitoring.vm.box = "ubuntu/focal64"
    monitoring.vm.hostname = "monitoring"
    monitoring.vm.network "private_network", ip: "192.168.56.12"
    monitoring.vm.network "forwarded_port", guest: 80, host: 8888  # Nagios Web
    
    monitoring.vm.provider "virtualbox" do |vb|
      vb.name = "transcriber-monitoring"
      vb.memory = "1024"
      vb.cpus = 1
    end

    monitoring.vm.provision "shell", path: "scripts/provision-monitoring.sh"
  end

end

