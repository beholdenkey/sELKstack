# sELKstack</p

### *"Expertish Level" install of a <br> Single-Node SELK stack (Secured ELK) on a fresh Ubuntu 20.04 (NO docker!)*

The core ELK stack installation here came from the excellent Digital Ocean documentation at https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elastic-stack-on-ubuntu-20-04, so go there if you need help.

The secured ELK stack install content came from the excellent Elastic documentation at https://www.elastic.co/blog/configuring-ssl-tls-and-https-to-secure-elasticsearch-kibana-beats-and-logstash

Any differences from the approach used in these two documents have been tested numerous times in the process of getting this all working smoothly.

If you know of better practices than are used here, please feel free to comment and make this better for all.

## Assumptions:

1. You have installed ELK stack at least once before and you want a quick cheatsheet, or else you're quite comfortable with Linux and can figure out cryptic notes. This version is extremely concise, and you will need familiarity with the process to figure out certain steps.
1. If you have never installed it before, you will find it easier to use https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elastic-stack-on-ubuntu-20-04 and https://kifarunix.com/install-elastic-elk-stack-on-ubuntu-20-04/ for the basic ELK installation, and then https://www.elastic.co/blog/configuring-ssl-tls-and-https-to-secure-elasticsearch-kibana-beats-and-logstash for the secured portion, referring back to these instructions for tips here and there.
1. You know how jump servers work and have one in your network.
1. You specifically want a single-node cluster. If you have multiple nodes, several config items are different; the links above and "helpful links" below go into more detail on multi-node installation.
1. You already know which filebeat modules you want to install. Search/replace "system nginx mysql elasticsearch" with your own modules. Just use "system" if you don't know.
1. This is designed around an entry-level **4GB Memory 80Gb Disk Ubuntu 20.04 LTS** (a basic option within Digital Ocean). Adjust accordingly. For example, if your server has more memory, you may be able to skip the SWAP steps below.
1. For security reasons, access from the jump server to this server requires a password, but access to the jump server requires pubkey. This provides two layers of security. In case for some reason your pubkey is compromised, someone would need your server's SSH password as well, and the only way to get in to the server is via the jump box.

## Other helpful links:

https://kifarunix.com/easy-way-to-configure-filebeat-logstash-ssl-tls-connection/
https://www.elastic.co/guide/en/elasticsearch/reference/7.13/security-minimal-setup.html
https://www.elastic.co/guide/en/elasticsearch/reference/7.13/security-basic-setup.html
https://www.elastic.co/guide/en/elasticsearch/reference/7.13/security-basic-setup-https.html
https://www.elastic.co/guide/en/beats/filebeat/current/securing-filebeat.html
https://www.elastic.co/guide/en/beats/filebeat/current/configuring-ssl-logstash.html
https://sleeplessbeastie.eu/2020/02/29/how-to-prevent-systemd-service-start-operation-from-timing-out/

## Before you begin:

Copy/paste these instructions to a new text editor window. 

You will do multiple search/replace substitutions and it is good practice to do all this before you start, not as you go, so there are fewer copy/paste errors. You will also do a few additional copy/paste substitutions later, for example when adding keys and generating passwords. It is a good idea to keep a copy of this information in a single, secure place.

## Ready to begin? 

*Before you start, gather the following information and do the following steps in your local-editor copy of these [instructions](https://github.com/jaredatobe/sELKstack/blob/main/instructions.txt):*

1. Search/replace "selk.mydomain.com" in the instructions with your FQDN.
1. Search/replace "selk.local" in the instructions with your local server hostname.local.
1. Search/replace "selk" in the instructions with your local server hostname.
1. Search/replace "10.0.0.11" in the instructions with the internal IP of your ELK server local IP.
1. Search/replace "10.0.0.10" in the instructions with the internal IP of your jump server, or if no jump server, your laptop which you alone use to access this system.
1. Search/replace "selkadmin" in the instructions with a unique username, and be prepared to enter its password when requested. We will give this account sudo privileges.
