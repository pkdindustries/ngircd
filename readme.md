# ngircd hub and spoke prefab

## what

an irc network using **ngircd** within containers. 

hub-and-spoke, ssl encrypted, etc

## files

 - *[ngircd.sh](ngircd.sh)*: docker entrypoint for configuring and starting **ngircd**.
 - *[Dockerfile](Dockerfile)*: defines a docker image for ngircd configurable with environment
 - *[certs/generate.sh](certs/generate.sh)*: script to generate ssl certificate.
 - *[compose.yml](compose.yml)*: docker compose file with example link

## setup

**generate ssl certificates**

   use **certs/generate.sh** to create the necessary ssl certificates for secure connections. ensure all certificates are properly generated and placed within the **certs/** directory.

   ```bash
   # Run the script to generate SSL certificates
   ./generate.sh
   ```

**build and run example containers**

```bash
# fire up both hub and spoke servers using compose
docker compose up --build
```


## env


- general:
  - `IRCD_NAME` `IRCD_NETWORK` `IRCD_MOTD`
    
- ports/ssl:
   - `IRCD_PORTS` `IRCD_SSL_PORTS` `IRCD_SSL_CERT_FILE` `IRCD_SSL_KEY_FILE` `IRCD_SSL_KEYFILE_PASSWORD`
    
- linking:
   - `IRCD_LINK_NAME` `IRCD_LINK_HOST` `IRCD_LINK_PORT` `IRCD_LINK_PASSWORD` `IRCD_LINK_PEER_PASSWORD` 
  
    
## configuration

configuration for **spoke-irc**, actively connects to the hub

```ini
    [Global]
    # Set the name of the IRC server
    Name = spoke-irc
    # Define the message of the day displayed to users upon connection
    MotdPhrase = an example irc network, spoke
    # Specify the network name this server belongs to
    Network = pkdnet
    # non-ssl listener ports
    Ports = 6668
    # server permissions
    ServerGID = nobody
    ServerUID = nobody
    [SSL]
    # path to the cert
    CertFile = /certs/irc-cert.pem
    # path to the key 
    KeyFile = /certs/irc-key.pem
    # password for the key 
    KeyFilePassword = secret
    # ssl listener ports
    Ports = 6669
    [Server]
    # the irc server to connect a link
    Name = hub-irc
    # the address of the server
    Host = hub-irc.local
    # set the port to connect to, ssl
    Port = 7669
    # set my link password
    MyPassword = linkpassword
    # set peer link pass
    PeerPassword = peerpassword
    # use SSL for the server link
    SSLConnect = yes
    # cert validation
    SSLVerify = no
    [Options]
    # for container dns
    DNS = yes
    PAM = no
```

paired configuration for **hub-irc**, passively waits for connections
```ini
    [Global]
    # Set the name of the IRC server
    Name = hub-irc
    # Define the message of the day displayed to users upon connection
    MotdPhrase = an example irc network, hub
    # Specify the network name this server belongs to
    Network = pkdnet
    # non-ssl listener ports
    Ports = 6669
    # server permissions
    ServerGID = nobody
    ServerUID = nobody
    [SSL]
    # path to the cert
    CertFile = /certs/irc-cert.pem
    # path to the key
    KeyFile = /certs/irc-key.pem  
    # password for the key
    KeyFilePassword = secret
    # ssl listener ports
    Ports = 7669
    [Server]
    # the irc server to accept a link from
    Name = spoke-irc 
    # set the port to accept the link on
    Port = 7669
    # link password expected from spoke
    MyPassword = peerpassword
    # link password to send to spoke  
    PeerPassword = linkpassword
    [Options]
    # for container dns
    DNS = yes
    PAM = no
```




