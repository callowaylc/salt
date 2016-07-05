

{{ ns }}:
  cmd.run:
    - name: |
        sudo rm -rf /tmp/.X*
        sudo rm -rf ~/.X* 
        sudo DISPLAY=:0.0 aticonfig --adapter=all --od-getclocks
        /usr/bin/x11vnc -xkb -forever -auth /var/run/lightdm/root/:0 -display :0 -rfbauth /etc/x11vnc.pass -rfbport 5900 -bg -o /var/log/x11vnc.log      

        sudo x11vnc -storepasswd password /etc/x11vnc.pass
        sudo x11vnc -xkb -noxrecord -noxfixes -noxdamage -display :0 -auth /var/lib/xdm/authdir/authfiles/A:0-XQvaJk -usepw

      /usr/bin/x11vnc -xkb -noxrecord -noxfixes -noxdamage -display :0 -auth guess -rfbauth /etc/x11vnc.pass

# this works but no firefox view
sudo x11vnc -storepasswd password /etc/x11vnc.pass
/usr/bin/x11vnc -xkb -forever -auth /var/run/lightdm/root/:0 -display :0 -rfbauth /etc/x11vnc.pass -rfbport 5900 -bg -o /var/log/x11vnc.log
