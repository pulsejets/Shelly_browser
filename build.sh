docker build -t shelly_test .
docker stop  shelly_test
docker rm shelly_test
docker run -d --name shelly_test -p  8084:80 -v /var/run/dbus:/var/run/dbus -v /var/run/avahi-daemon/socket:/var/run/avahi-daemon/socket shelly_test
