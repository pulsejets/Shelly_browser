
# Use the latest stable Debian image as the base
FROM debian:10-slim

# Update package lists and install Apache2
RUN apt-get update && \
    apt-get install -y curl nano vim  jq apache2 cron  avahi-utils iputils-ping 
COPY shelly.sh /root/ 
COPY index.html /var/www/html/
COPY setup_cron.sh /root/setup_cron.sh
COPY cronjobs.txt /root/cronjobs.txt
RUN chmod +x /root/setup_cron.sh
RUN chmod +x /root/shelly.sh
# Expose port 80 (the default port for Apache)
EXPOSE 80
#ENTRYPOINT ["/root/setup_cron.sh"]
# Start Apache when the container runs
CMD ["apache2ctl", "-D", "FOREGROUND"]
#CMD ["sleep", "10"]
#CMD cron
#CMD service cron start
#CMD ["./root/shelly.sh"]
