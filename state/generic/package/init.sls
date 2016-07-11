{# Install packages for a given target #}

{# imports #####################################}

{# dependencies ################################}

{# attributes ##################################}
{%- set name = sls.split('.')[::-1][0] %}
{%- set ns = '/' + slspath + '/' + name %}

{# main ########################################}
