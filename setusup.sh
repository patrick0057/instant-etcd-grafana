#!/bin/bash
#export PENDPOINTIP=$(env | grep \/kubernetes | grep key | sed -e 's/.*etcd-\(.*\)-key.pem/\1/g' | sed -e 's/-/\./g')
tar -xvzf /root/prometheus-1.3.1.linux-amd64.tar.gz --directory /tmp/ --strip-components=1

cat > /tmp/test-etcd.yaml <<EOF
global:
  scrape_interval: 10s
scrape_configs:
  - job_name: test-etcd
    tls_config:
      ca_file: /etc/kubernetes/ssl/kube-ca.pem
      cert_file: /etc/kubernetes/ssl/kube-etcd-18-220-86-186.pem
      key_file: /etc/kubernetes/ssl/kube-etcd-18-220-86-186-key.pem
      insecure_skip_verify: true
    scheme: https
    static_configs:
    - targets: ['18.220.86.186:2379','18.220.86.186:2379','18.220.86.186:2379']
EOF

sed -i 's,cert_file: .*,cert_file: '${ETCDCTL_CERT%$'\r'}',g' "/tmp/test-etcd.yaml"
sed -i 's,key_file: .*,key_file: '${ETCDCTL_KEY%$'\r'}',g' "/tmp/test-etcd.yaml"
sed -i "s,- targets: .*,- targets: \[\'${PENDPOINTIP%$'\r'}:2379\'\],g"  "/tmp/test-etcd.yaml"

nohup /tmp/prometheus     -config.file /tmp/test-etcd.yaml     -web.listen-address ":9090"     -storage.local.path "test-etcd.data" >> /tmp/test-etcd.log  2>&1 &

dpkg -i /root/grafana_6.1.6_amd64.deb 
service grafana-server start

export CURLRETRY='--connect-timeout 5 --retry-connrefuse  --max-time 10  --retry 5 --retry-delay 0 --retry-max-time 40'

echo SLEEPING 15 SECONDS
sleep 15

echo STARTING PROMETHEUS SETUP
curl $CURLRETRY \
-X POST \
-H 'Accept: application/json' \
-H 'Content-Type: application/json' \
-d '{ "name":"test-etcd",
  "type":"prometheus",
  "url":"http://localhost:9090",
  "access":"proxy",
  "isDefault":true,
  "basicAuth":false }' \
http://admin:admin@localhost:3000/api/datasources

echo STARTING GRAFANA SETUP
grafana_host="http://localhost:3000"
grafana_cred="admin:admin"
grafana_datasource="test-etcd"
ds=(3070);
for d in "${ds[@]}"; do
  echo -n "Processing $d: "
  j=$(curl $CURLRETRY -s -k -u "$grafana_cred" $grafana_host/api/gnet/dashboards/$d | jq .json)
  curl $CURLRETRY -s -k -u "$grafana_cred" -XPOST -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d "{\"dashboard\":$j,\"overwrite\":true, \
        \"inputs\":[{\"name\":\"DS_PROMETHEUS\",\"type\":\"datasource\", \
        \"pluginId\":\"prometheus\",\"value\":\"$grafana_datasource\"}]}" \
    $grafana_host/api/dashboards/import; echo ""
done
