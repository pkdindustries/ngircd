FROM alpine 
RUN apk add gettext ngircd ngircd-doc

WORKDIR /
COPY ngircd.sh /
COPY ngircd.conf.tmpl /

CMD ["/ngircd.sh"]
