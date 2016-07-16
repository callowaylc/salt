{# Install packages for a given target #}

{# imports #####################################}

{# dependencies ################################}

{# attributes ##################################}
{%- set name = sls.split('.')[::-1][0] %}
{%- set ns = '/' + slspath + '/' + name %}
{%- set __pillar__ = salt['pillar.get']( name ) %}


{# main ########################################}

{{ ns }}/sudoers.d:
  file.recurse:
    - name: /etc/sudoers.d
    - source: salt://user/files/etc/sudoers.d
    - clean: True
    - file_mode: 0440

{%- for username, attributes in __pillar__.iteritems() %}

