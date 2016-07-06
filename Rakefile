#!/usr/bin/env ruby
# callowaylc@gmail
# includes individual tasks

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
        --volume="/docker/salt-master-0/var/log/salt:/var/log/salt:ro" \
        --volume="/docker/salt-master-0/etc/salt/master.d:/etc/salt/master.d:ro" \
        --volume="/docker/salt-master-0/srv/salt:/srv/salt:ro" \
          callowaylc/salt-master \
            --log-level=warning > /dev/stdout
    } if %w{ start restart }.include? arguments[:action]
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
    # below isnt working in rake context.. falling back
    # to ruby solution
    #path=`pwd`
    #repository=${path/$HOME/\~}
    repository="#{ home.sub ENV['HOME'], '~' }"
    fsync ./ #{ arguments[:remote] }:$repository \
      > /tmp/sync.`basename $repository`.log 2>&1 &
  }
end

desc "Execute salt command against master"
task :salt, [ :command ] do | t, arguments |
  exec %{
    sudo docker exec -i #{ name } bash -c '#{ arguments[:command] }'
  }
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