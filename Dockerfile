FROM multiarch/alpine-linux:armhf-edge

ARG ARCH=amd64

EXPOSE 8080 8140

ENV \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8\

ENV \
    PUPPET_MIRROR=https://downloads.puppetlabs.com \
    PUPPET_AGENT_VERSION=4.8.0 \
    PUPPETSERVER_VERSION=2.6.0 \
    PUPPETDB_VERSION=4.3.0 \
    RUBY_GPG_VERSION=0.3.2 \
    HIERA_EYAML_GPG_VERSION=0.5.0 \
    PUPPET_BASEDIR=/opt/puppetlabs

# Update to latest packages and install community
RUN printf "http://nl.alpinelinux.org/alpine/edge/community/\n" >> /etc/apk/repositories
RUN apk update && apk upgrade
# Install prereqs
RUN apk add bash curl gnupg openjdk8-jre-base ruby ruby-dev ruby-irb ruby-json ruby-rake make
# Install dependent Ruby libraries
RUN gem install -N facter hiera rgen
# Download and position puppet software
RUN mkdir -p ${PUPPET_BASEDIR} && \
        curl -L ${PUPPET_MIRROR}/puppet/puppetserver-${PUPPETSERVER_VERSION}.tar.gz | tar -zxC /tmp && \
	     install -d -m 755 /etc/puppetlabs/puppetserver/services.d && \
	     make -C /tmp/puppetserver-${PUPPETSERVER_VERSION} prefix=${PUPPET_BASEDIR} && \
	     rm -rf /tmp/puppetserver-${PUPPETSERVER_VERSION} && \
    	curl -L ${PUPPET_MIRROR}/puppet/puppet-${PUPPET_AGENT_VERSION}.tar.gz | tar -zxC ${PUPPET_BASEDIR} && \
	     ln -s ${PUPPET_BASEDIR}/puppet-${PUPPET_AGENT_VERSION} ${PUPPET_BASEDIR}/puppet  && \
	curl -L ${PUPPET_MIRROR}/puppetdb/puppetdb-${PUPPETDB_VERSION}.tar.gz | tar -zxC ${PUPPET_BASEDIR} && \
	     ln -s ${PUPPET_BASEDIR}/puppetdb-${PUPPETDB_VERISON} ${PUPPET_BASEDIR}/puppetdb

# Establish entrypoint scripts and runtimes
COPY entrypoint.sh /
COPY /entrypoint.d/* /entrypoint.d/
#ENTRYPOINT ["/entrypointsh"]
#CMD ["puppetserver", "foreground"]