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

ENV COUCHDB_VERSION 1.6.x

RUN sudo adduser --disabled-login --disabled-password --no-create-home --gecos "" couchdb

WORKDIR /root

RUN apt-get update -y && \
    apt-get install  -y --no-install-recommends \
    curl ca-certificates  build-essential autotools-dev autoconf automake \
    libicu-dev libmozjs185-dev libcurl4-openssl-dev git-core \
    libtool autoconf-archive && \
    git clone https://github.com/apache/couchdb.git && \
    cd couchdb && \
    git checkout ${COUCHDB_VERSION} && \
    /bin/sh bootstrap && \
    ./configure --with-erlang=/opt/erlang/lib/erlang/usr/include/ && \
    make && sudo make install && \
    cd .. && rm -rf couchdb && \
    apt-get purge -y \
    curl ca-certificates  build-essential autotools-dev autoconf automake \
    libicu-dev libmozjs185-dev libcurl4-openssl-dev git-core \
    libtool autoconf-archive && \
    apt-get autoremove -y && \
    apt-get install -y --no-install-recommends \
    libmozjs185-1.0 curl openssl libicu52 && \
    apt-get clean


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


