
FROM debian:latest

# File Author / Maintainer 
MAINTAINER VOICE1 LLC <info@voice1.me>
 
RUN apt-get update -q && \
    apt-get upgrade -qy && \
    apt-get install lsof sysstat wget openssh-server supervisor -qy && \
    echo "wget -q -O kerio-connect-linux-64bit.deb http://download.kerio.com/dwn/kerio-connect-linux-64bit.deb" > dl.sh && \
    chmod +x dl.sh && \
    ./dl.sh && \
    dpkg -i kerio-connect-linux-64bit.deb && \
    echo "/etc/init.d/kerio-connect stop" >> /kerio-restore.sh && \
    echo "/opt/kerio/mailserver/kmsrecover /backup/" >> /kerio-restore.sh && \
    mkdir -p /var/log/supervisord && \
    mkdir -p /var/run/sshd && \
    locale-gen en_US.utf8 && \
    useradd docker -d /home/docker -g users -G sudo -m && \                                                                                                                
    echo docker:test123 | chpasswd && \

ADD /etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/supervisord.conf 
ADD /etc/init.d/kerio-connect /etc/init.d/kerio-connect 
RUN chmod +x /etc/init.d/kerio-connect && \
    chmod +x /kerio-restore.sh 

# Expose the default portonly 4040 is nessecary for admin access  
EXPOSE 4040 22 25 465 587 110 995 143 993 119 563 389 636 80 443 5222 5223 
 
VOLUME /backup
VOLUME /mailserver/data 
# Set default container command
ENTRYPOINT ["/usr/bin/supervisord"]
CMD ["-c", "/etc/supervisor/conf.d/supervisord.conf"] 
