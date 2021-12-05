# sELKstack

## *Single-Node SELK stack (Secured ELK) on a fresh Ubuntu 20.04 (without using docker)*

Eventually, this will be a more detailed How-To, with notes in-between steps to explain what's happening, but for now, it's pretty dense. The eventual goal is to get this all working on Debian someday for better security, but for now, it's Ubuntu.

The core ELK stack installation here came from the excellent Digital Ocean documentation at <https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elastic-stack-on-ubuntu-20-04>, so go there if you need help.

The secured ELK stack install content came from the excellent Elastic documentation at <https://www.elastic.co/blog/configuring-ssl-tls-and-https-to-secure-elasticsearch-kibana-beats-and-logstash>, so go there if you need help.

Although more compact, these instructions fill in some gaps in those how-tos. Any differences from the approach used in these two documents have been tested numerous times to get this all working smoothly. For example, the clever solution to allow Logstash to listen on 127.0.0.1:10514, which is redirected under the hood by iptables from port 0.0.0.0:514 is too rare -- more people should be using this method to listen to ports below 1024 without accessing root privileges; it took hours to find by prowling the dark recesses of Stack Exchange, but here it is for you to enjoy.

If you know of better practices used here, please feel free to comment and make this better for all.

Note, the following ports are opened externally by these install instructions, along with other internal ports opened by various ELK components:

- OpenSSH (port 22)
- Nginx Full (port 80 redirecting to 443, reverse proxied to internal kibana 5601)
- 514 (syslog unencrypted redirecting to internal 10514)
- 5044 (logstash encrypted)
- 9201 (encrypted connection to internal elasticsearch 9200 via nginx reverse proxy)

## Assumptions for this version

1. You have installed an ELK stack at least once before and you want a quick cheat sheet, or else you're comfortable with Linux and can figure out cryptic notes like these. This version is extremely concise, and you will need familiarity with the process to figure out certain steps.
2. If you have never installed ELK before, you will find it easier to use <https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elastic-stack-on-ubuntu-20-04> and <https://kifarunix.com/install-elastic-elk-stack-on-ubuntu-20-04/> for the basic ELK installation, and then <https://www.elastic.co/blog/configuring-ssl-tls-and-https-to-secure-elasticsearch-kibana-beats-and-logstash> for the secured portion, referring back to these instructions for tips here and there.
3. You know how jump servers work and have one in your network; we configure SSH access in a secure manner coming in from a jump server.
4. You specifically want a single-node cluster. If you have multiple nodes, several config items are different; the links above and "helpful links" below go into more detail on multi-node installation.
5. You already know which filebeat modules you want to install. Search/replace "system nginx mysql elasticsearch" with your own modules. Just use "system" for a safe default if you don't know.
6. This is designed around an entry-level **4GB Memory 80Gb Disk Ubuntu 20.04 LTS** (a basic option within Digital Ocean). Adjust accordingly. For example, if your server has more memory, you may be able to skip the SWAP steps below.
7. For security reasons, access from the jump server to this server requires a password and a pubkey, but access to the jump server requires pubkey only. This approach provides two layers of security. If for some reason your pubkey is compromised, someone would still need your server's SSH password, and by using these instructions, the only way to get in to the server is via the jump box.
8. You're familiar with how to use LetsEncrypt, as we use their certificates in several places

## Other helpful links

- <https://kifarunix.com/easy-way-to-configure-filebeat-logstash-ssl-tls-connection/>
- <https://www.elastic.co/guide/en/elasticsearch/reference/7.13/security-minimal-setup.html>
- <https://www.elastic.co/guide/en/elasticsearch/reference/7.13/security-basic-setup.html>
- <https://www.elastic.co/guide/en/elasticsearch/reference/7.13/security-basic-setup-https.html>
- <https://www.elastic.co/guide/en/beats/filebeat/current/securing-filebeat.html>
- <https://www.elastic.co/guide/en/beats/filebeat/current/configuring-ssl-logstash.html>
- <https://sleeplessbeastie.eu/2020/02/29/how-to-prevent-systemd-service-start-operation-from-timing-out/>

## Before you begin

Copy/paste these instructions (both files) to a new text editor window, one right after the other. (You will do multiple search/replace substitutions). Do this once before you start, not as you go, so there are fewer copy/paste errors. Note, you will also do a few additional copy/paste substitutions later, for example when adding keys and generating passwords.

## Ready to begin?

*Before you start, gather the following information and do the following steps in your local-editor copies of the [base server install instructions](https://github.com/jaredatobe/sELKstack/blob/main/base_server_install_instructions.txt) and [selk install instructions](https://github.com/jaredatobe/sELKstack/blob/main/selk_install_instructions.txt):*

1. Search/replace "selk.mydomain.com" in the instructions with your FQDN.
1. Search/replace "selk.local" in the instructions with your local server hostname.local.
1. Search/replace "selkadmin" in the instructions with a unique username, and be prepared to enter its password later when requested. We will give this account sudo privileges.
1. Search/replace any remaining "selk" in the instructions with your local server hostname.
1. Search/replace "10.0.0.11" in the instructions with the internal IP of your ELK server local IP.
1. Search/replace "100.100.100.100" in the instructions with the external IP of your ELK server.
1. Search/replace "10.0.0.10" in the instructions with the internal IP of your jump server (or if no jump server, external IP of your laptop which you alone use to access this system).
1. Be ready with a password vault to generate new passwords and store generated passwords throughout this process, there are nearly a dozen involved.

## To-Do List

- [ ] Convert instructions to interactive shell script
- [ ] Create Step By Step Instructions
- [ ] Create ci pipeline for testing new configurations
- [ ] Add ssh-keygen instructions and commands to script

## References

- [Generate ssh keys on linux](https://linuxhint.com/generate-ssh-keys-on-linux)
