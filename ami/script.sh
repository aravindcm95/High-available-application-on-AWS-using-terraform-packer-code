#!/bin/bash

# Update SSH configuration and restart the service
echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config && systemctl restart sshd.service

# Install required packages
yum install -y httpd php git

# Clone the repository
git clone https://github.com/Fujikomalan/aws-elb-site.git /var/website/

# Copy the contents of the repository to the web server directory
rsync -av /var/website/ /var/www/html/

# Set ownership of the web files to the Apache user
chown -R apache:apache /var/www/html/

# Restart services
systemctl restart php-fpm.service httpd.service
systemctl enable php-fpm.service httpd.service