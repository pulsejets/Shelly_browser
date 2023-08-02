# Shelly_browser

Detect Shelly devices on you network 


build image :
docker build -t shelly_test .

to run docker:

docker run -d --name shelly_test -p  8084:80 -v /var/run/dbus:/var/run/dbus -v /var/run/avahi-daemon/socket:/var/run/avahi-daemon/socket shelly_test

http://ip/8084
