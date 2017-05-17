#create a docker image from the DMTF RedFish Interface Emulator
FROM python:2-alpine
RUN apk update && apk add git build-base openssl-dev libffi-dev linux-headers
WORKDIR /usr/local/src/
RUN git clone -b stable/ocata  https://git.openstack.org/openstack/keystone.git
RUN sed -i 's/>=/==/g' /usr/local/src/keystone/requirements.txt && pip install -r /usr/local/src/keystone/requirements.txt
RUN pip install /usr/local/src/keystone/
RUN pip install uwsgi
RUN apk del git build-base openssl-dev linux-headers
RUN mkdir -p /etc/keystone/fernet-keys
RUN cp /usr/local/src/keystone/etc/keystone-paste.ini /etc/keystone && cp /usr/local/src/keystone/etc/keystone.conf.sample /etc/keystone/keystone.conf
RUN keystone-manage fernet_setup --keystone-user root --keystone-group root
RUN keystone-manage db_sync && keystone-manage bootstrap --bootstrap-password password --bootstrap-username admin --bootstrap-project-name admin --bootstrap-role-name admin --bootstrap-service-name keystone --bootstrap-region-id RegionOne --bootstrap-admin-url http://localhost:35357 --bootstrap-public-url http://localhost:5000 --bootstrap-internal-url http://localhost:5000
EXPOSE 35357
CMD uwsgi --http localhost:35357 --wsgi-file /usr/local/bin/keystone-wsgi-admin
