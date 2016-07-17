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

{%- for name, user in __pillar__.iteritems() %}
{{ ns }}/{{ name }}/group:
  group.present:
    - name: {{ name }}
    - gid: {{ user.gid }}

{{ ns }}/manage/{{ name }}:
  user.{{ user.status }}:
    - name: {{ name }}
    - uid: {{ user.uid }}
    - gid: {{ user.gid }}
    - groups:
      - {{ name }}
      {%- for group in user.groups|default([]) %}
      - {{ group }}
      {%- endfor %}
    - password: "{{ salt['cmd.run']( 'openssl rand -base64 32' ) }}"
    - enforce_password: False
{%- endfor %}
