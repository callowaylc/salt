{## imports ####################################}
{%- from "global/map.jinja" import global with context %}

{## includes ###################################}
{%- if salt['pillar.get']( 'allow:include' ) %}
include:
  - nothing
{%- endif %}

{## attributres ################################}
{%- set ns = '/nginx' %}

{## main #######################################}

{{ ns }}/install:
  pkg.latest:
    - names:
      - nginx
      - nginx-extras
    - refresh: True
    - skip_verify: True

{{ ns }}/run:
  service.running:
    - name: nginx
    - enable: true
    - watch:
      - file: {{ name }}-conf
      - cmd: {{ name }}-create-dh-key

{{ ns }}/configuration:
  file.recurse:
    - name: /etc/nginx/sites-available
    - source: salt://nginx/files
