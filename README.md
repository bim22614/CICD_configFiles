
# Preparing CI/CD(Jenkins) to Java projects

Preparation and configuration of instructions for quicker and simpler starting project


## Acknowledgements

 - [CI/CD and automation systems](https://www.youtube.com/@ADV-IT)
 

## Preparation of servers

You need at least one machine to run Ansible playbooks and Terraform, one to run Jenkins and last one 
for Tomcat service(or other java builder)



## Clone github repositiry to your machine

Create repositiry to put git project in
```bash
  mkdir configuration_files
  cd configuration_files
```

Clone repository with config files
```bash
  git clone https://github.com/bim22614/CICD_configFiles.git
```

Go to directory
```bash
  cd configuration_files
```


## Terraform - creating instances (AWS)

Go to Terraform directory

```bash
   cd Terraform
```
Connect AWS keys
```bash
   nano main.tf
```

Input region you want to built instances; AccessKey and SecretKey of your user
```bash
provider "aws" {
  access_key = ""
  secret_key = ""
  region = ""
}
```

Init Terraform
```bash
   terraform init
```

Run Terraform
```bash
   terraform apply
```

You will get outputing with public ip of instances  
Save this addresses for Ansible configuration

```
   Output:

instance_public_ip_jenkins = "3.86.116.52"
instance_public_ip_tomcat = "3.93.234.157"
```

It will create tfkey file - private key   
Move this file to Key directory and change its permisions

```bash
   mv tfkey ../Key
   chmod 400 ../Key/tfkey
```

## Ansible - installing instruments

Move to Ansible directory
```bash
   cd ../Ansible
```

Open hosts.txt file  
You need take ip addresses that was created by AWS and input it in file

```bash
[jenkins_main]
3.86.116.52

[tomcat]
3.93.234.157
```

Checking connection to instances

```bash
   ansible all -m ping
```

Run playbook for installing Tomcat - tomcat instance
```bash
   ansible-playbook playbook_tomcat
```

Run playbook for installing Docker - jenkins instance
```bash
   ansible-playbook playbook_docker
```


## Tomcat - configuration

Connect to server
```bash
   cd ../Key
   ssh ubuntu@3.93.234.157 -i tfkey
```

Location of JAVA
```bash
   sudo update-java-alternatives -l
```

```bash
Output:
 java-1.11.0-openjdk-amd64      1111       /usr/lib/jvm/java-1.11.0-openjdk-amd64
```

Create the systemd service file and put way JAVA to JAVA_HOME
```bash
   sudo nano /etc/systemd/system/tomcat.service
```

```bash
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64/jre   #<--------------------
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
```

Reload daemon and start Tomcat
```bash
   sudo systemctl daemon-reload
   sudo systemctl start tomcat
```

## Jenkins - run through Docker

Connect to server
```bash
   ssh ubuntu@3.86.116.52 -i tfkey
```

Run Docker  
- port 8080  - for Jenkins  
- port 50000 - for WebHooks
```bash
   sudo docker run -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts
```

In output you find these rows  
Save this password (Jenkins autorotation)
```bash
Jenkins initial setup is required. An admin user has been created and a password generated.
Please use the following password to proceed to installation:

7444ff4ecbd1495f84993487955c38cb     <-------------------------------------

This may also be found at: /var/jenkins_home/secrets/initialAdminPassword
```

Connect to Jenkins:  
Open browser and put your ip:8080
```bash
   3.86.116.52:8080
```

 Put password (Jenkins autorotation) and put starting of configure jenkins by defoult
 Install
 - Maven Plugin
 - Deploy to container Plugin

### Create your items and pipelines)
