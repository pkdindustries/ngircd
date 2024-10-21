FROM alpine 
RUN apk add gettext ngircd

WORKDIR /
COPY ngircd.sh /
COPY certs/ /certs/

RUN chown -R ngircd:ngircd /certs
CMD ["/ngircd.sh"]
