# instant-etcd-grafana
This docker image will deploy a Prometheus and Grafana setup preconfigured for the local etcd node of the host that it is deployed on.  This image has only been tested with an RKE deployed cluster.  If you plan on building this docker image yourself, you'll need to build it on an RKE host as the initial setup requires a working etcd server.
###Build command
```bash
docker build  --no-cache -t patrick0057/instant-etcd-grafana .
```
If you only plan on running this image, then you only need the following command
```bash
docker run -p 9090:9090 -p 3000:3000 -v /etc/kubernetes:/etc/kubernetes --name instant-etcd-grafana $(docker exec -ti etcd env | grep \/kubernetes | awk '{print "-e", $1}' | paste -s -) -d patrick0057/instant-etcd-grafana
```
Once you have started the image, browse to `https://<etcd-node-ip:3000/` and use admin/admin to login.
