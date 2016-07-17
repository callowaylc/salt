{# Install packages for a given target #}

{# imports #####################################}

{# dependencies ################################}

{# attributes ##################################}
{%- set name = sls.split('.')[::-1][0] %}
{%- set ns = '/' + slspath + '/' + name %}
{%- set __pillar__ = salt['pillar.get']( name ) %}

{# main ########################################}

{{ ns }}/update:
  cmd.run:
    - name: apt-get update

{%- for command, packages in __pillar__.iteritems() %}
  {%- for pkg, version in packages.iteritems() %}
{{ ns }}/install/{{ pkg }}:
  cmd.run:
    - name: |
        {%- if version in [ 'latest' ] %}
          {%- if 'apt' in command %}
            {%- set command = command.replace( '=$version', '' ) %}
          {%- elif 'gem' in command %}
            {%- set command = command.replace( '-v $version', '' ) %}
          {%- endif %}
        {%- endif %}
        {{ command | replace( '$name', pkg ) | replace( '$version', version ) }}
  {%- endfor %}
{%- endfor %}
