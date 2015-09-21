# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

FROM ivlis/docker-erlang:OTP-17

MAINTAINER ivlis

ENV COUCHDB_VERSION 1.6.1

RUN sudo adduser --disabled-login --disabled-password --no-create-home --gecos "" couchdb

WORKDIR /root

RUN sudo apt-get update -y && \
    sudo apt-get install  -y --no-install-recommends \
    ca-certificates  build-essential libicu-dev libmozjs185-dev libcurl4-openssl-dev wget git-core

RUN wget http://mirrors.advancedhosters.com/apache/couchdb/source/${COUCHDB_VERSION}/apache-couchdb-${COUCHDB_VERSION}.tar.gz &&\
    tar -zxvf apache-couchdb-*.tar.gz && \
    cd apache* && \
    ./configure --with-erlang=/opt/erlang/lib/erlang/usr/include/ && \
    make && sudo make install

RUN sudo chown -R couchdb:couchdb /usr/local/var/lib/couchdb &&\
    sudo chown -R couchdb:couchdb /usr/local/var/log/couchdb &&\
    sudo chown -R couchdb:couchdb /usr/local/var/run/couchdb &&\
    sudo chown -R couchdb:couchdb /usr/local/etc/couchdb &&\
    sudo chmod 0770 /usr/local/var/lib/couchdb/ &&\
    sudo chmod 0770 /usr/local/var/log/couchdb/ &&\
    sudo chmod 0770 /usr/local/var/run/couchdb/ &&\
    sudo chmod 0770 /usr/local/etc/couchdb/*.ini &&\
    sudo chmod 0770 /usr/local/etc/couchdb/*.d


# Expose to the outside
RUN sed -e 's/^bind_address = .*$/bind_address = 0.0.0.0/' -i /usr/local/etc/couchdb/default.ini

COPY ./docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 5984
WORKDIR /var/lib/couchdb

ENTRYPOINT ["/entrypoint.sh"]
CMD ["couchdb"]

#sudo ln -s /usr/local/etc/logrotate.d/couchdb /etc/logrotate.d/couchdb
#sudo ln -s /usr/local/etc/init.d/couchdb /etc/init.d
#sudo update-rc.d couchdb defaults# BOOM, we're done!# Another way to accomplish this: https://github.com/pixelpark/ppnet/wiki/Install-CouchDB-1.6.1-on-Ubuntu-14.04



## download dependencies, compile and install couchdb
#RUN apt-get update -y \
  #&& apt-get install -y --no-install-recommends \
    #build-essential ca-certificates curl \
    #libmozjs185-dev libmozjs185-1.0 libnspr4 libnspr4-0d libnspr4-dev libcurl4-openssl-dev libicu-dev \
  #&& curl -sSL https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb -o esl.deb && dpkg -i esl.deb && apt-get update \
  #&& apt-get install -y --no-install-recommends erlang-nox=1:17.5.3 erlang-dev=1:17.5.3 \
  #&& curl -sSL http://apache.openmirror.de/couchdb/source/$COUCHDB_VERSION/apache-couchdb-$COUCHDB_VERSION.tar.gz -o couchdb.tar.gz \
  #&& curl -sSL https://www.apache.org/dist/couchdb/source/$COUCHDB_VERSION/apache-couchdb-$COUCHDB_VERSION.tar.gz.asc -o couchdb.tar.gz.asc \
  #&& curl -sSL https://www.apache.org/dist/couchdb/KEYS -o KEYS \
  #&& gpg --import KEYS && gpg --verify couchdb.tar.gz.asc \
  #&& mkdir -p /usr/src/couchdb \
  #&& tar -xzf couchdb.tar.gz -C /usr/src/couchdb --strip-components=1 \
  #&& cd /usr/src/couchdb \
  #&& ./configure --with-js-lib=/usr/lib --with-js-include=/usr/include/mozjs \
  #&& make && make install \
  #&& apt-get purge -y perl binutils cpp make build-essential libnspr4-dev libcurl4-openssl-dev libicu-dev \
  #&& apt-get autoremove -y \
  #&& apt-get update && apt-get install -y libicu48 --no-install-recommends \
  #&& rm -rf /var/lib/apt/lists/* /usr/src/couchdb /couchdb.tar.gz* /KEYS /esl.deb

## grab gosu for easy step-down from root
#RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  #&& curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
  #&& curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
  #&& gpg --verify /usr/local/bin/gosu.asc \
  #&& rm /usr/local/bin/gosu.asc \
  #&& chmod +x /usr/local/bin/gosu

## permissions
#RUN chown -R couchdb:couchdb \
    #/usr/local/lib/couchdb /usr/local/etc/couchdb \
    #/usr/local/var/lib/couchdb /usr/local/var/log/couchdb /usr/local/var/run/couchdb \
  #&& chmod -R g+rw \
    #/usr/local/lib/couchdb /usr/local/etc/couchdb \
    #/usr/local/var/lib/couchdb /usr/local/var/log/couchdb /usr/local/var/run/couchdb \
  #&& mkdir -p /var/lib/couchdb

## Expose to the outside
#RUN sed -e 's/^bind_address = .*$/bind_address = 0.0.0.0/' -i /usr/local/etc/couchdb/default.ini

#COPY ./docker-entrypoint.sh /entrypoint.sh
#RUN chmod +x /entrypoint.sh

## Define mountable directories.
##VOLUME ["/usr/local/var/log/couchdb", "/usr/local/var/lib/couchdb", "/usr/local/etc/couchdb"]

#EXPOSE 5984
#WORKDIR /var/lib/couchdb

#ENTRYPOINT ["/entrypoint.sh"]
#CMD ["couchdb"]
