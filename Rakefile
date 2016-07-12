#!/usr/bin/env ruby
# callowaylc@gmail
# Provides utility tasks for managing salt instances

## tasks ########################################

namespace :salt do
  desc "Usage: {start|stop|reload|restart|force-reload}"
  task :master, [ :action ] do | t, arguments |
    command %{
      sudo docker rm -f salt-master-0 > /dev/null 2>&1
    } if %w{ start restart stop }.include? arguments[:action]

    command %{
      sudo docker run \
        --name="salt-master-0" \
        -d \
        --publish="0.0.0.0:4505:4505" \
        --publish="0.0.0.0:4506:4506" \
        --volume="/docker/salt-master-0/etc/salt/pki:/etc/salt/pki" \
        --volume="/docker/salt-master-0/etc/salt/generic/stack:/etc/salt/generic/stack" \
        --volume="/docker/salt-master-0/var/log/salt:/var/log/salt" \
        --volume="/docker/salt-master-0/etc/salt/master.d:/etc/salt/master.d" \
        --volume="/docker/salt-master-0/srv/salt:/srv/salt" \
          callowaylc/salt-master \
            --log-level=warning > /dev/stdout

      sudo chmod o+w /docker/salt-master-0/etc/salt/generic/stack
    } if %w{ start restart }.include? arguments[:action]
  end

  desc "Usage: {start|stop|reload|restart|force-reload|install}"
  task :minion, [ :action, :host ] do | t, arguments |
    exec %{
      path=`dirname $0`
      host="#{ arguments[:host] }"
      echo $host > $path/.master

      sudo su -c "
        sed -i '/salt/d' /etc/hosts
        echo $host salt >> /etc/hosts
      "
    } unless arguments[:host].nil?

    command %{
      sudo pkill -9 -f salt-minion > /dev/null 2>&1
    } if %w{ start restart stop }.include? arguments[:action]

    exec %{
      sudo nohup salt-minion > /dev/null 2>&1 &
    } if %w{ start restart }.include? arguments[:action]

    exec %{
      sudo su -c "
        apt-get update && \
        apt-get install -y curl && \
        apt-get autoremove -y && \
        curl -Ls https://bootstrap.saltstack.com > /usr/local/bin/bootstrap-salt && \
        chmod +x /usr/local/bin/bootstrap-salt && \
        bootstrap-salt -X -d git v2016.3.1
      "
    } if %w{ install }.include? arguments[:action]
  end
end

namespace :pillar do
  desc "encrypt pillar"
  task :encrypt do
    command %{
      key="#{ home }/.stack/key"
      openssl rand -base64 128 -out $key

      find #{ home }/stack -name '*.yml' | while read file
        do
          path=`echo $file | sed 's/stack/.stack/'`
          mkdir -p `dirname $path` > /dev/null 2>&1
          cat $file | openssl \
            enc \
            -aes-256-cbc \
            -salt \
            -pass file:$key > $path
      done

      # finally encrypt key file
      cat $key | openssl \
        rsautl \
        -encrypt \
        -inkey ~/.ssh/salt.public.pem \
        -pubin > $key.encrypted

      rm $key
    }
  end

  desc "decrypt pillar"
  task :decrypt do
    command %{
      key="#{ home }/.stack/key"
      cat $key.encrypted | openssl \
        rsautl \
        -decrypt \
        -inkey ~/.ssh/salt.private.pem \
          > $key

      find #{ home }/.stack -name '*.yml' | while read file
        do
          path=`echo $file | sed 's/.stack/stack/'`
          mkdir -p `dirname $path` > /dev/null 2>&1
          cat $file | openssl \
            enc \
            -d \
            -aes-256-cbc \
            -pass file:$key > $path
      done

      rm $key
    }
  end
end

desc "sync to remote environment"
task :sync, [ :remote ] do | t, arguments |
  command  %{
    # kill any previous fsync processes attached to this sync
    pkill -9 -f __salt__

    # below isnt working in rake context.. falling back
    # to ruby solution
    #path=`pwd`
    #repository=${path/$HOME/\~}
    repository="#{ home.sub ENV['HOME'], '~' }"
      fsync ./ #{ arguments[:remote] }:$repository __salt__ \
        > /tmp/sync.`basename $repository`.log 2>&1 &

    # TODO: iteratate through stacks
    stacks=( generic pme media-server )
      fsync ./stack/generic \
        #{ arguments[:remote] }:/docker/salt-master-0/etc/salt/generic/stack __salt__ \
          > /tmp/sync.stack.generic.log 2>&1 &
  }
end

desc "Execute salt command against master"
task :salt, [ :command ] do | t, arguments |
  exec %{
    sudo docker exec -i #{ name } bash -c '#{ arguments[:command] }'
  }
end

namespace :run do
  desc "run salt-master"
  task :master do | t, arguments |
    Rake::Task['salt:master'].invoke 'restart'
  end

  desc "run salt-minion"
  task :minion do | t, arguments |
    Rake::Task['salt:minion'].invoke 'restart'
  end
end

## methods ######################################

private def command bash
  IO.popen bash do | io |
    while (char = io.getc) do
      print char
    end
  end
end

private def name
  'salt-master-0'
end

private def home
  File.dirname  __FILE__
end