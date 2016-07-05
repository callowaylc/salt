{## imports ####################################}
{%- from "global/map.jinja" import global with context %}

{## includes ###################################}
{%- if salt['pillar.get']( 'allow:include' ) %}
include:
  - nothing
{%- endif %}

{## attributres ################################}
{%- set ns = '/varnish' %}

{## main #######################################}

{{ ns }}/install:
  pkg.latest:
    - names:
      - varnish
    - refresh: True
    - skip_verify: True

{{ ns }}/run:
  service.running:
    - name: varnish
    - enable: true
    - watch:
      - file: {{ name }}-conf

{{ ns }}/configuration/default:
  file.recurse:
    - name: /etc/varnish/default.vcl
    - source: salt://etc/nginx/default

{{ ns }}/configuration/varnish:
  file.recurse:
    - name: /etc/default/varnish
    - source: salt://varnish/files/varnish