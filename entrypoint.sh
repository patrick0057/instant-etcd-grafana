#!/bin/bash
#export PENDPOINTIP=$(env | grep \/kubernetes | grep key | sed -e 's/.*etcd-\(.*\)-key.pem/\1/g' | sed -e 's/-/\./g')
sed -i 's,cert_file: .*,cert_file: '${ETCDCTL_CERT%$'\r'}',g' "/tmp/test-etcd.yaml"
sed -i 's,key_file: .*,key_file: '${ETCDCTL_KEY%$'\r'}',g' "/tmp/test-etcd.yaml"
sed -i "s,- targets: .*,- targets: \[\'${PENDPOINTIP%$'\r'}:2379\'\],g"  "/tmp/test-etcd.yaml"
service grafana-server start
nohup /tmp/prometheus     -config.file /tmp/test-etcd.yaml     -web.listen-address ":9090"     -storage.local.path "test-etcd.data" >> /tmp/test-etcd.log  2>&1
