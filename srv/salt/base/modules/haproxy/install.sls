include:
  - modules.haproxy.rsyslog

haproxy-pkg:
  pkg.installed:
    - pkgs:
      - make
      - gcc
      - pcre-devel
      - bzip2-devel
      - openssl-devel
      - systemd-devel
      - gcc-c++

create-haproxy:
  user.present:
    - name: haproxy
    - system: true
    - createhome: false
    - shell: /sbin/nologin

unzip-haproxy:
  archive.extracted:
    - name: /usr/src
    - source: salt://modules/haproxy/files/{{ pillar['haproxy_version'] }}.tar.gz
    - if_missing: /usr/src/haproxy-{{ pillar['haproxy_version'] }}

redis-installed:
  cmd.script:
    - name: salt://modules/haproxy/files/install.sh.j2
    - template: jinja
    - require:
      - archive: unzip-haproxy
    - unless: test -d {{ pillar['haproxy_install_dir'] }}/haproxy

{{ pillar['haproxy_install_dir'] }}/sbin/haproxy:
  file.symlink:
    - target: /usr/sbin/haproxy

/etc/sysctl.conf:
  file.append:
  - text:
    - net.ipv4.ip_nonlocal_bind = 1
    - net.ipv4.ip_forward = 1
  cmd.run:
    - name: sysctl -p

{{ pillar['haproxy_install_dir'] }}/haproxy/conf:
  file.directory:
    - user: root
    - group: root
    - mode: '0755'
    - makedirs: true

{{ pillar['haproxy_install_dir'] }}/haproxy/conf/haproxy.cfg:
  file.managed:
    - source: salt://modules/haproxy/files/haproxy.cfg.j2
    - template: jinja

/usr/lib/systemd/system/haproxy.service:
  file.managed:
    - source: salt://modules/haproxy/files/haproxy.service.j2
    - template: jinja

haproxy.service:
  service.running:
    - enable: true
    - reload: true
    - watch:
      - file: {{ pillar['haproxy_install_dir'] }}/haproxy/conf/haproxy.cfg

