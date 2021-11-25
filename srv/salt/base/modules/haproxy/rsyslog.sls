/etc/rsyslog.conf:
  file.managed:
    - source: salt://modules/haproxy/files/rsyslog.conf

start-rsyslog:
  service.running:
    - name: rsyslog.service
    - enable: true

