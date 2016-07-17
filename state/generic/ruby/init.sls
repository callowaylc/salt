{# Install ruby to target #}

{# imports #####################################}

{# dependencies ################################}

{# attributes ##################################}
{%- set name = sls.split('.')[::-1][0] %}
{%- set ns = '/' + slspath + '/' + name %}
{%- set __state__ = salt['pillar.get']( name ) %}

{# main ########################################}

{{ ns }}:
  cmd.run:
    - name: |
        gpg \
            --keyserver hkp://keys.gnupg.net \
            --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 && \
        curl -sSL https://get.rvm.io | sudo bash -s stable && \
        source /etc/profile.d/rvm.sh && \
        rvm install {{ __state__.version }} && \
        gem install --no-ri --no-rdoc bundler rake

{{ ns }}/group/rvm/root:
  cmd.run:
    - name: |
        usermod -a -G rvm root

{%- for user in salt['pillar.get']( 'user' ) %}
{{ ns }}/group/rvm/{{ user }}:
  cmd.run:
    - name: |
        usermod -a -G rvm {{ user }}
{%- endfor %}


