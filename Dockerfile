FROM ubuntu:14.04.3
MAINTAINER Christian Calloway <callowaylc@gmail.com>

# Main ##########################################

RUN true && \
  apt-get update && \
  apt-get install -y curl && \
  curl -Ls https://bootstrap.saltstack.com > /usr/local/bin/bootstrap-salt && \
  chmod +x /usr/local/bin/bootstrap-salt && \
  bootstrap-salt -X -d -M git v2016.3.1

# Volumes #######################################

VOLUME ["/etc/salt/pki", "/var/log/salt", "/etc/salt/master.d", "/srv/salt"]

# Ports #########################################

EXPOSE 4505 4506

# Run ###########################################

ENTRYPOINT [ "/usr/bin/salt-master" ]
CMD [ "-h" ]
