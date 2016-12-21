#####################################
##### Salt Formula For Resolver #####
#####################################
{% set use_resolvconf = salt['pillar.get']('resolver:use_resolvconf', True) %}
{% set is_ubuntu = salt['grains.get']('os')|lower() == 'ubuntu' %}
{% set is_resolv_conf_installed = salt['pkg.version']('resolvconf') %}
{% if use_resolvconf %}
  {% if is_ubuntu and is_resolv_conf_installed %}
{% set resolver_conf = '/etc/resolvconf/resolv.conf.d/base' %}
resolv-update:
  cmd.run:
    - name: resolvconf -u
    - onchanges:
      - file: resolv-file
  {% else %}
{% set resolver_conf = '/etc/resolv.conf' %}
  {% endif %}
{% else %}
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
        nameservers: {{ salt['pillar.get']('resolver:nameservers', []) }}
        searchpaths: {{ salt['pillar.get']('resolver:searchpaths', []) }}
        options: {{ salt['pillar.get']('resolver:options', []) }}
        domain: {{ salt['pillar.get']('resolver:domain') }}
