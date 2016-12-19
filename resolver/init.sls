#####################################
##### Salt Formula For Resolver #####
#####################################

{% if salt['pillar.get']('resolver:use_resolvconf', True) %}
  {% if grains['os'] == 'Ubuntu' and salt['pkg.version']('resolvconf') %}
{% set resolver_conf = '/etc/resolvconf/resolv.conf.d/base' %}
resolv-update:
  cmd.run:
    - name: resolvconf -u
    - onchanges:
      - file: resolv-file
  {% endif %}
{% else %}
{% set resolver_conf = '/etc/resolv.conf' %}
resolvconf-purge:
  pkg.purged:
    - name: resolvconf
    - require_in:
      - file: resolv-file
{% endif %}

# Resolver Configuration
resolv-file:
  file.managed:
    - name: {{ resolver_conf }}
    - user: root
    - group: root
    - mode: '0644'
    - source: salt://resolver/files/resolv.conf
    - template: jinja
    - defaults:
        nameservers: {{ salt['pillar.get']('resolver:nameservers', ['8.8.8.8','8.8.4.4']) }}
        searchpaths: {{ salt['pillar.get']('resolver:searchpaths', [salt['grains.get']('domain'),]) }}
        options: {{ salt['pillar.get']('resolver:options', []) }}
        domain: {{ salt['pillar.get']('resolver:domain') }}
