=================================
Secure your server
=================================

#begin in root, create sudo user
passwd
apt -y update
apt -y upgrade
adduser selkadmin
usermod -aG sudo selkadmin
su - selkadmin
sudo chmod -x /etc/update-motd.d/*
sudo chmod +x /etc/update-motd.d/50-landscape-sysinfo 
sudo chmod +x /etc/update-motd.d/90-updates-available 
sudo chmod +x /etc/update-motd.d/00-header 
sudo nano /etc/motd
================================================================
Welcome to the Ubuntu server single-node Secure Elk Stack
================================================================
All access to this server (and each server in this network) is
meticulously logged and monitored. Please be careful...
================================================================
sudo apt -y install ufw net-tools
sudo ufw allow in OpenSSH
sudo nano /etc/default/ufw
IPV6=no
sudo ufw enable
#y
sudo ufw status
mkdir /home/selkadmin/.ssh
#cat > .ssh/authorized_keys
#paste authorized-key here
#chmod 600 ~/.ssh/authorized_keys
cat > /home/selkadmin/.ssh/id_rsa.pub
#paste pubkey here, then ^D to end
chown selkadmin:selkadmin /home/selkadmin/.ssh/id_rsa.pub
chmod 600 /home/selkadmin/.ssh/id_rsa.pub
chmod 700 ~/.ssh
sudo nano /etc/ssh/sshd_config
# For internal servers we first disable all authentication, then 
# allow only PasswordAuthentication from the jumpbox IP using 
# the 'Match Address' line below
Include /etc/ssh/sshd_config.d/*.conf
PubkeyAuthentication no
PasswordAuthentication no
ChallengeResponseAuthentication no
# Eventually need to investigate PAM, according to https://vez.mrsk.me/freebsd-defaults.html
UsePAM yes
X11Forwarding no
PrintMotd no
PermitRootLogin without-password
#Banner none
# Allow client to pass locale environment variables
AcceptEnv LANG LC_*
# override default of no subsystems to allow SFTP
#Subsystem sftp /usr/lib/openssh/sftp-server
# Allow password-only access from a single IP, the jump server
# which itself is accessible only via pubkey. Note that Digital
# Ocean will default this to "no" when it takes a snapshot, which
# is a good default for external IP addresses
Match Address 10.0.0.10
    PasswordAuthentication yes
    PubkeyAuthentication yes 
    AuthenticationMethods "publickey,password"    
# Allow access for root with Pubkey, but only from Digital Ocean
# internal web console servers. Digital Ocean does not publish this 
# list, so it is created manually by reviewing auth.log connections.
# Note: These servers change from time to time so this list
# will need to be updated as needed; you can use the recovery console
# to see the IP of a failed SSH login and update this list
Match User root Address 198.211.111.194,162.243.190.66,162.243.188.66
    PubkeyAuthentication yes
#conclude your root session
exit
ip a
#capture your ip addresses for /etc/hosts file
sudo nano /etc/hosts
127.0.0.1 localhost
127.0.1.1 selk
10.0.0.11 selk.local
100.100.100.100 selk.mydomain.com
sudo shutdown -h -r now


=================================
Add 4G of Swap:
=================================

sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo nano /etc/fstab
/swapfile swap swap defaults 0 0
sudo swapon --show
sudo free -h
cat /proc/sys/vm/swappiness

sudo shutdown -h now

=================================
=======BASE SYSTEM IS DONE=======
=================================

=================================
This is a good time to take a snapshot, if you're working with a VM.
Hereafter, you will login from jump server with 'selkadmin'
=================================
