#!/bin/bash

# Update SSH configuration and restart the service
echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config && systemctl restart sshd.service