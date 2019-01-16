pkgs:
  - curl
  - unzip
  - vim
  - python-pip
  - nginx
  - postgresql-10
  - pgcli
  - prometheus
  - prometheus-node-exporter
  - prometheus-postgres-exporter
  - grafana
  - python-m2crypto

svc:
  prometheus:
    watch: /etc/prometheus/prometheus.yml
  prometheus-node-exporter:
    watch: /etc/prometheus/node.yml
  prometheus-postgres-exporter:
    watch: /etc/prometheus/db.yml
  nginx:
    watch: /etc/nginx/sites-enabled/default
  grafana-server:
    watch: /etc/nginx/sites-enabled/default

pip-pkgs:
  - docker-py
  - python-gnupg
  - psycopg2
  - m2crypto

nginx_vhosts:
  prometheus:
    server_name: 'monit.*'
    listen: 443 ssl
    ssl_certificate: /etc/pki/issued_certs/server_cert.crt
    ssl_certificate_key: /etc/pki/server_cert.key
    location: /
    proxy_pass:  http://127.0.0.1:9090
  grafana:
    server_name: 'graf.*'
    listen: 443 ssl
    ssl_certificate: /etc/pki/issued_certs/server_cert.crt
    ssl_certificate_key: /etc/pki/server_cert.key
    location: /
    proxy_pass:  http://127.0.0.1:3000

ca:
  root_ca.crt:
        CN: O3H Root CA
        C: Uk
        ST: England
        L: London
        emailAddress: "pki-ops@out3rheaven.io"
        cacert_path: /etc/pki/
        ca_filename: root_ca.crt
        basicConstraints: "critical CA:true"
        keyUsage: "critical cRLSign, keyCertSign"
        subjectKeyIdentifier: hash
        authorityKeyIdentifier: keyid,issuer:always
        days_valid: 3650
        days_remaining: 0
        backup: True
        ca_key: /etc/pki/root_ca.key
        key_bits: 4096
        backup_key: true

web_server_certs:
  server_cert.crt:
        CN: Devlen MSTR
        C: Uk
        ST: England
        L: London
        emailAddress: "pki-ops@out3rheaven.io"
        cacert_path: /etc/pki/root_ca.crt
        signing_private_key: /etc/pki/root_ca.key
        basicConstraints: "critical CA:false"
        keyUsage: "critical cRLSign, keyCertSign"
        subjectKeyIdentifier: hash
        authorityKeyIdentifier: keyid,issuer:always
        subjectAltName: IP:127.0.0.1, DNS:localhost, DNS:*.local
        days_valid: 365
        days_remaining: 0
        backup: True
        ca_key: /etc/pki/server_cert.key
        key_bits: 2048
        backup_key: true

ca_keys:
  /etc/pki/root_ca.key:
        bits: 4096
        backup: true
