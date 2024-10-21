# readme for ngircd hub and spoke prefab

## overview

this setup creates an irc network using **ngircd** within docker containers. it employs a hub-and-spoke topology and supports ssl-secured connections to ensure security.

## project structure

- **ngircd.sh**: docker entrypoint for configuring and starting **ngircd**.
- **Dockerfile**: defines the docker image for **ngircd**.
- **certs/**: directory containing ssl certificate.
- **certs/generate.sh**: script to generate ssl certificate.
- **compose.yml**: docker compose file with example hub and spoke configuration.

## prerequisites

- **docker** and **docker compose** installed.
- **openssl** to generate ssl certificates.

## setup instructions

**generate ssl certificates**

   use **certs/generate.sh** to create the necessary ssl certificates for secure connections. ensure all certificates are properly generated and placed within the **certs/** directory.

   ```bash
   # Run the script to generate SSL certificates
   ./generate.sh
   ```

**build and run example containers**

use **docker-compose up** to start the example with these configurations. 

```bash
# fire up both hub and spoke servers using compose
docker-compose up --build
```

## example configuration and topology

this docker compose example creates a hub-and-spoke irc network topology with two irc servers:

- **hub-irc**: the central server that other servers (spokes) connect to.
- **spoke-irc**: a server that connects to the hub, extending the network.

## configuration details

- **hub-irc** and **spoke-irc** are defined as separate services in **compose.yml**.
- each service is built from the current directory (`build: .`) using the **Dockerfile** to create the ngircd container.
- both servers use ssl for secure communication, with ssl certificates specified in the environment variables.
- the **hub-irc** service listens on ports **6669** (regular) and **7669** (ssl).
- the **spoke-irc** service listens on ports **6668** (regular) and **7668** (ssl).

## environment variables and linking

the environment variables defined for each service are used to configure ngircd, such as the server name, network, motd, and ssl settings.

- **hub-irc** and **spoke-irc** are linked together using **IRCD\_LINK** variables, specifying the link name, host, port, and passwords for secure connection.
- **depends\_on** is used to ensure that **spoke-irc** waits for **hub-irc** to be ready before starting.
- both services are part of the same docker network (`PKDNET_IRC_BACKBONE`) to facilitate communication between them.

this configuration allows **hub-irc** to act as the main node, while **spoke-irc** extends the network by linking to the hub. clients can connect to either server and communicate across the entire network.

## environment variables

defined in **compose.yml**:

- general configuration:
  - `IRCD_NAME` 
  - `IRCD_NETWORK`
  - `IRCD_MOTD`
    
- ports and ssl:
    - `IRCD_PORTS` 
    - `IRCD_SSL_PORTS` 
    - `IRCD_SSL_CERT_FILE` 
    - `IRCD_SSL_KEY_FILE`
    - `IRCD_SSL_KEYFILE_PASSWORD`
    
- linking servers:
    - `IRCD_LINK_NAME` 
    - `IRCD_LINK_HOST` 
    - `IRCD_LINK_PORT`
    - `IRCD_LINK_PASSWORD` 
    - `IRCD_LINK_PEER_PASSWORD` 
  
    

these environment variables are used to create the **ngircd.conf** file via **envsubst**.

## example configuration for ngircd

below is an example configuration for **spoke-irc**, demonstrating how to set up the irc server using the ngircd configuration file:

```ini
    [Global]
    # Set the name of the IRC server
    Name = spoke-irc
    # Define the message of the day displayed to users upon connection
    MotdPhrase = an example irc network, spoke
    # Specify the network name this server belongs to
    Network = pkdnet
    # Set the maximum number of simultaneous connection attempts
    MaxConnections = 500
    # Define the maximum number of channels a user can join
    MaxJoins = 30
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
```

below is an example configuration for **hub-irc**, demonstrating how to set up the irc server using the ngircd configuration file:
```ini
    [Global]
    # Set the name of the IRC server
    Name = hub-irc
    # Define the message of the day displayed to users upon connection
    MotdPhrase = an example irc network, hub
    # Specify the network name this server belongs to
    Network = pkdnet
    # Set the maximum number of simultaneous connection attempts  
    MaxConnections = 1000
    # Define the maximum number of channels a user can join
    MaxJoins = 50
    # non-ssl listener ports
    Ports = 6669
    # server permissions
    ServerGID = nobody
    ServerUID = nobody
    [SSL]
    # path to the cert
    CertFile = /certs/hub-cert.pem
    # path to the key
    KeyFile = /certs/hub-key.pem  
    # password for the key
    KeyFilePassword = secret
    # ssl listener ports
    Ports = 7669
    [Server]
    # the irc server to accept a link from
    Name = spoke-irc 
    # set the port to accept the link on
    Port = 7669
    # set link password expected from spoke
    MyPassword = peerpassword
    # set link password to send to spoke  
    PeerPassword = linkpassword
```
   these configuration files illustrate how **spoke-irc** is linked to **hub-irc**, specifying ssl settings, server name, ports, and passwords for secure connections.

## ssl and server link configuration

the **ngircd.sh** script dynamically builds the ssl and server link configuration by substituting the values from environment variables into the **ngircd.conf.tmpl** template.

## troubleshooting

- **test configuration**: run ngircd with the `-t` flag to test the configuration before launching.
- **logs**: to view logs for troubleshooting, you can use `docker logs <container_name>`.

## notes

- make sure that **ngircd** is correctly installed in the **alpine** image as specified in the **Dockerfile**.
- adjust the environment variables in **compose.yml** to match your specific requirements (e.g., port numbers, server names).

## license

this project is open-source and freely modifiable. contributions are welcome.

## contact and support

if you encounter issues or have questions, please open an issue in the repository for further assistance.

---

enjoy building and running your secure irc network with ngircd!

