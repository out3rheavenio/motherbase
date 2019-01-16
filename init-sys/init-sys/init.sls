{% for pkg in pillar.get('pkgs', []) %}
{{ pkg }}:
  pkg.installed:
    - refresh: True
{% endfor %}

{% for pkg in pillar.get('pip-pkgs', []) %}
{{ pkg }}:
  pip.installed:
    - require:
      - pkg: python-pip
{% endfor %}

/etc/nginx/sites-available/default:
  file.managed:
    - source: salt://init-sys/nginx.default
    - template: jinja

install_salt_master:
  cmd.run:
    - name: curl -o /tmp/bootstrap-salt.sh -L https://bootstrap.saltstack.com && sh /tmp/bootstrap-salt.sh -M -N git v2018.3.2
    - creates:
      - /etc/salt/master

install_salt_minion:
  cmd.run:
    - name: curl -o /tmp/bootstrap-salt.sh -L https://bootstrap.saltstack.com && sh /tmp/bootstrap-salt.sh git v2018.3.2
    - require:
      - file: /etc/salt/master

{% for svc, args in pillar.get('svc',{}).iteritems()%}
managing_svc_{{ svc }}:
  service.running:
    - name: {{ svc}}
    - enable: True
    - running: True
    - reload: True
{% endfor %}

/etc/pki:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755

base:
  pkgrepo.managed:
    - humanname: Grafna labs
    - name: deb https://packages.grafana.com/oss/deb beta main
    - dist: beta
    - file: /etc/apt/sources.list.d/grafana.list
    - keyid: 8C8C34C524098CB6
    - keyserver: keyserver.ubuntu.com
    - key_url: https://packages.grafana.com/gpg.key
    - gpgcheck: 1
    - require_in:
      - pkg: grafana

/etc/consul:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755

/etc/consul/config.json:
  file.managed:
    - source: salt://init-sys/consul.config
    - template: jinja
    - require:
      - file: /etc/consul

/etc/systemd/system/consul.service:
  file.managed:
    - source: salt://init-sys/consul.service
    - require:
      - file: /etc/consul/config.json


/etc/pki/issued_certs:
  file.directory:
    - require:
      - file: /etc/pki


{% for ca_key, args in pillar.get('ca_keys',{}).iteritems()%}
{{ ca_key }}:
  x509.private_key_managed:
    - bits: {{ args['bits'] }}
    - backup: {{ args['backup'] }}
    - require:
      - file: /etc/pki
{% endfor %}


{% for cert, args in pillar.get('ca',{}).iteritems() %}
/etc/pki/{{ cert }}:
  x509.certificate_managed:
    - signing_private_key: {{ args['ca_key'] }}
    - CN: {{ args['CN'] }}
    - C: {{ args['C'] }}
    - ST: {{ args['ST'] }}
    - L: {{ args['L'] }}
    - basicConstraints: {{ args['basicConstraints'] }}
    - keyUsage: {{ args['keyUsage'] }}
    - subjectKeyIdentifier: {{ args['subjectKeyIdentifier'] }}
    - authorityKeyIdentifier: {{ args['authorityKeyIdentifier'] }}
    - days_valid: {{ args['days_valid'] }}
    - days_remaining: {{ args['days_remaining'] }}
    - backup: {{ args['backup'] }}
    - require:
      - file: /etc/pki
      - x509: {{ args['ca_key'] }}
{% endfor %}

{% for cert, args in pillar.get('web_server_certs',{}).iteritems() %}
/etc/pki/issued_certs/{{ cert }}:
  x509.certificate_managed:
    - CN: {{ args['CN'] }}
    - C: {{ args['C'] }}
    - ST: {{ args['ST'] }}
    - L: {{ args['L'] }}
    - basicConstraints: {{ args['basicConstraints'] }}
    - keyUsage: {{ args['keyUsage'] }}
    - signing_private_key: {{ args['signing_private_key'] }}
    - signing_cert: {{ args['cacert_path'] }}
    - subjectKeyIdentifier: {{ args['subjectKeyIdentifier'] }}
    - authorityKeyIdentifier: {{ args['authorityKeyIdentifier'] }}
    - subjectAltName: {{ args['subjectAltName'] }}
    - days_valid: {{ args['days_valid'] }}
    - days_remaining: {{ args['days_remaining'] }}
    - backup: {{ args['backup'] }}
    - managed_private_key:
        name: {{ args['ca_key'] }}
        bits: {{ args['key_bits'] }}
        backup: {{ args['backup_key'] }}
{% endfor %}

/etc/salt/master:
  file.managed:
    - source: salt://init-sys/master.conf
    - template: jinja

/etc/salt/master.d:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755