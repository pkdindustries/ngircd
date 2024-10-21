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

### [global] 
| Setting                 | hub-irc Value       | spoke-irc Value     | Explanation / Relationship                                                                                                      |
|-------------------------|---------------------|---------------------|---------------------------------------------------------------------------------------------------------------------------------|
| IRCD_NAME               | hub-irc             | spoke-irc           | The unique name of each IRC server. These names are used to identify the servers within the network and are referenced in the [Server] section for linking.          |
| IRCD_NETWORK            | pkdnet              | pkdnet              | The network name both servers belong to. Must be the same for all servers in the network to ensure they are recognized as part of the same IRC network.              |
| IRCD_MOTD               | an example irc network, hub | an example irc network, spoke | The Message of the Day displayed to users upon connection. While not critical for inter-server communication, it provides context to users about each server.         |
| IRCD_PORTS              | 6669                | 6668                | Non-SSL listener ports for client connections. Different ports prevent conflicts and allow clients to choose which server to connect to based on the port number.     |

### [ssl] 
| Setting                 | hub-irc Value       | spoke-irc Value     | Explanation / Relationship                                                                                                      |
|-------------------------|---------------------|---------------------|---------------------------------------------------------------------------------------------------------------------------------|
| IRCD_SSL_PORTS          | 7669                | 6669                | SSL listener ports for client connections. Each server listens on different SSL ports to distinguish between them and avoid port conflicts.                         |
| IRCD_SSL_CERT_FILE      | /certs/irc-cert.pem | /certs/irc-cert.pem | Path to the SSL certificate file. Both servers can use the same certificate for simplicity in this example, but in practice, they may have individual certificates.   |
| IRCD_SSL_KEY_FILE       | /certs/irc-key.pem  | /certs/irc-key.pem  | Path to the SSL key file corresponding to the SSL certificate. As above, both servers are using the same key file in this example.                                    |
| IRCD_SSL_KEYFILE_PASSWORD | secret             | secret              | Password for the SSL key file if it is encrypted. Both servers use the same password to decrypt their SSL key files.                                                   |


### [server] 
| Setting        | hub-irc Value      | spoke-irc Value    | Explanation / Relationship |
|----------------|--------------------|--------------------|----------------------------|
| IRCD_LINK_NAME      | spoke-irc          | hub-irc            | The name of the server to link with. Each server specifies the other's name to establish the link. |
| IRCD_LINK_HOST     | *(Not specified)*  | hub-irc.local      | `hub-irc` accepts connections and doesn't specify `Host`. `spoke-irc` specifies `Host` to connect to `hub-irc`. |
| IRCD_LINK_PORT      | 7669               | 7669               | Both servers use the same port number for the server link. This port must be open on `hub-irc` for `spoke-irc` to connect. |
| IRCD_LINK_PASSWORD| peerpassword       | linkpassword       | Passwords used for authentication. `hub-irc`'s `MyPassword` matches `spoke-irc`'s `PeerPassword`, and vice versa, to authenticate the link. |
| IRCD_LINK_PEER_PASSWORD| linkpassword     | peerpassword       | See above. Passwords are exchanged to authenticate the servers to each other. |


 
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




