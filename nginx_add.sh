#! /bin/bash
sudo useradd -m -d /home/teacher -s /bin/bash -G wheel,adm teacher
sudo mkdir /home/teacher/.ssh
sudo echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCkBIEsfJD6d0J4tqTnVq4z3Ve0bop71b+27j75gncRsLdAHLVg/InhJdrtnVszNGzPIPTXM8jsb/cc0e0JDD7Teoqz0YxJH+ZhY5Y6iy5n8Vx+CCWr5Rra5IpfJclvDPbH+okiUqGyt1fmvS+VkoBWxOFiAOsfdSdTwJWyGs0kplZouOh93cRc/9mp16mNcR5B86+ORLrMZCq3ZGVj2F3YjlhXb1/aUz7Mi1E6Ze9UQQe2oKqf4w8wXIiSejCcrsZ9CT6SX28Kqw2Ilb+7cr84vXIQDKxZySupztn8qMFlDvtoeK4b+RvEtpRmJaC/no9yjTeDTnBYVsV+vQvxiaaeLzkbPRhd0Ovlayoz/gXqI4DOCaQTfISHxG7X+NLfpW6Hmvgf+2i9OStUMJatDx6y1BAj5cjBKo1JRS73U2o5wYYTAlq6jaDAUzWE8Ili7cZ2Qx2dz5uFq6S8NteIt9yR6LsfaHYKG/5WmaA3LOnYAqV+S7nq2WQVQ2Z5bzpJC9s= andrey@MBP-Andrey' >> /home/teacher/.ssh/authorized_keys
sudo chmod 600 /home/teacher/.ssh/authorized_keys
sudo chmod 700 /home/teacher/.ssh
sudo chown -R teacher:teacher /home/teacher
sudo echo "teacher ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/90-cloud-init-users

# sudo amazon-linux-extras install nginx1
sudo cp /etc/nginx /etc/nginx.old
# sudo mkdir /etc/nginx
sudo echo -e "events{}\n http {\n server {\n listen 8888;\n root /usr/share/nginx/html;\n location / {\n  index index.html; \n }\n }\n}" > /etc/nginx/nginx.conf

IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
REGION=$(curl http://169.254.169.254/latest/meta-data//placement/region)
AZ=$(curl http://169.254.169.254/latest/meta-data//placement/availability-zone)

sudo echo -e "<center><h2>IP: $IP</h2><br><h2>REGION: $REGION</h2><br><h2>AZ: $AZ</h2></center>" > /usr/share/nginx/html/index.html
sudo systemctl restart nginx 
