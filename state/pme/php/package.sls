{## imports ####################################}
{%- from "global/map.jinja" import global with context %}

{## includes ###################################}
{%- if salt['pillar.get']( 'allow:include' ) %}
include:
  - nothing
{%- endif %}

{## attributres ################################}
{%- set ns = '/php/package' %}

{## main #######################################}

{{ ns }}/install:
  pkg.latest:
    - names:
      - php5-fpm
      - php5-cli
      - php5-json
      - php5-common
      - php5-imagick
      - php5-curl
      - php5-mysql
      - php5-dev
      - php-gettext
      - gettext
      - php5-intl
      - libgeoip-dev
      - php5-tidy
      - php5-gd
      - php5-imap
      - libmemcached-dev
      - php5-memcached
  