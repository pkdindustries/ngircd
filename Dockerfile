FROM alpine 
RUN apk add gettext ngircd ngircd-doc

WORKDIR /
COPY ngircd.sh /
COPY ngircd.conf.tmpl /
COPY certs/ /certs/
# chown certs
RUN chown -R ngircd:ngircd /certs
CMD ["/ngircd.sh"]
