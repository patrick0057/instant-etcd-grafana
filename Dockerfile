FROM ubuntu
MAINTAINER patrick0057
ENV TERM xterm
RUN apt-get update && apt-get install -y apt-transport-https iproute2 vim wget curl xxd adduser libfontconfig1 net-tools jq && \
rm -rf /var/lib/apt/lists/*
COPY setusup.sh /root
COPY entrypoint.sh /root
RUN wget https://github.com/prometheus/prometheus/releases/download/v1.3.1/prometheus-1.3.1.linux-amd64.tar.gz -O /root/prometheus-1.3.1.linux-amd64.tar.gz
RUN wget https://dl.grafana.com/oss/release/grafana_6.1.6_amd64.deb -O /root/grafana_6.1.6_amd64.deb
WORKDIR /root
RUN chmod +x /root/setusup.sh
RUN chmod +x /root/entrypoint.sh
RUN /root/setusup.sh
CMD ["/root/entrypoint.sh"]
