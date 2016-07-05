{## imports ####################################}
{%- from "global/map.jinja" import global with context %}

{## includes ###################################}
{%- if salt['pillar.get']( 'allow:include' ) %}
include:
  - nothing
{%- endif %}

{## attributres ################################}
{%- set ns = '/mysql' %}

{## main #######################################}

{{ ns }}/install:
  pkg.latest:
    - names:
      - mysql-server-core-5.6
CREATE USER 'gw'@'localhost' IDENTIFIED BY 'DBWH57qvbDnjSk24w93qoE44s';
GRANT ALL PRIVILEGES ON * . * TO 'gw'@'localhost';
