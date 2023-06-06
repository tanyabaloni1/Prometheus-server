#!/bin/bash
# Install Prometheus 
cd /tmp
curl -LO https://github.com/prometheus/prometheus/releases/download/v2.44.0-rc.0/prometheus-2.44.0-rc.0.linux-amd64.tar.gz
tar -xvf prometheus-2.44.0-rc.0.linux-amd64.tar.gz
mkdir prometheus-files
cp -r prometheus-2.44.0-rc.0.linux-amd64/. prometheus-files
useradd --no-create-home --shell /bin/false prometheus
mkdir /etc/prometheus
mkdir /var/lib/prometheus
chown prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /var/lib/prometheus
cp prometheus-files/prometheus /usr/local/bin/
cp prometheus-files/promtool /usr/local/bin/
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool
cp -r prometheus-files/consoles /etc/prometheus
cp -r prometheus-files/console_libraries /etc/prometheus
chown -R prometheus:prometheus /etc/prometheus/consoles
chown -R prometheus:prometheus /etc/prometheus/console_libraries
#echo $pip

#ip_list=$mongodb_private_ip
#IFS=',' read -ra ips <<< "$ip_list"

#ip1="${ips[0]}"
#ip2="${ips[1]}"
#ip3="${ips[2]}"

cat << EOF | sudo tee /etc/prometheus/prometheus.yml

global:
  scrape_interval: 60s # How frequently to scrape targets by default.
  scrape_timeout: 10s # How long until a scrape request times out.
  evaluation_interval: 60s # How frequently to evaluate rules.
  # A scrape configuration
scrape_configs:
  - job_name: prometheus
    metrics_path: /metrics
    static_configs:
      - targets: ['localhost:9090']
  - job_name: elasticsearch_exporter
    static_configs:
      - targets: ['${elasticsearch_private_ip}:9114']
  - job_name: mongodb_exporter
    static_configs:
      - targets: ['${mongodb_private_ip1}:9001','${mongodb_private_ip2}:9001','${mongodb_private_ip3}:9001']
EOF
cat << EOF | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target

EOF
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus
