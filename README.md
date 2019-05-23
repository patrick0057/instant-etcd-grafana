# instant-etcd-grafana
This docker image will deploy a Prometheus and Grafana setup preconfigured for the local etcd node of the host that it is deployed on.  This image has only been tested with an RKE deployed cluster.  If you plan on building this docker image yourself, you'll need to build it on an RKE host as the initial setup requires a working etcd server.
### Build command
```bash
docker build  --no-cache -t patrick0057/instant-etcd-grafana .
```
If you are only planning on running this image, then you only need the following command
### Run command (must be run on an rke deployed etcd node)
```bash
docker run -p 9090:9090 -p 3000:3000 -v /etc/kubernetes:/etc/kubernetes --name instant-etcd-grafana -e PENDPOINTIP=$(docker inspect etcd | grep -m1 advertise-client-urls | sed -r 's,^.*advertise-client-urls=[^ /]*\/\/([^:]*).*,\1,g') $(docker exec -ti etcd env | grep \/kubernetes | awk '{print "-e", $1}' | paste -s -) -d patrick0057/instant-etcd-grafana
```
1. Once you have started the image, browse to `http://$etcd-node-ip:3000/` and use admin/admin to login.
2. Set a new password if you like when prompted
3. Mouse over the four square icon below the plus sign on the left hand side of your screen then click manage.
4. Click "Etcd by Prometheus" to view your etcd metrics
5. Allow some time for metrics to build.
