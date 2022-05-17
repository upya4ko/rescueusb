FROM debian:latest AS tools

RUN apt-get update; apt-get install -y \
    'memtest86+' \
    grub-imageboot \
    f3 ;\
    apt-get clean ;\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#    bash \
#    parted \
#    wget \
#    p7zip-full \
#    unzip \
#    ntfs-3g \
#    dosfstools \
#    fdisk \
#    grub-pc \
#    grub-efi-amd64-bin \
#    grub-efi-ia32-bin \
#    grub-imageboot \
#    grep \
#    aria2 \
#    ca-certificates \
#    'memtest86+' \
#    genisoimage \
#    f3 \
#    tar \
#    gzip ;\

FROM alpine:latest AS builder

RUN apk update && \
    apk add --no-cache \
    bash \
    parted \
    wget \
    p7zip \
    unzip \
    ntfs-3g \
    ntfs-3g-progs \
    dosfstools \
    grub-bios \
    grub-efi \
    grub \
    grep \
    aria2 \
    ca-certificates \
    cdrkit \
    tar \
    gzip 
#    syslinux \

RUN mkdir /sourceDir

COPY --from=tools /boot/memdisk /sourceDir/
COPY --from=tools /boot/memtest86+.bin /sourceDir/
COPY --from=tools /usr/bin/f3write /usr/bin/f3write 
COPY --from=tools /usr/bin/f3read /usr/bin/f3read 
COPY --from=tools /usr/bin/f3brew /usr/bin/f3brew
COPY --from=tools /usr/bin/f3fix /usr/bin/f3fix
COPY --from=tools /usr/bin/f3probe /usr/bin/f3probe
COPY --from=tools /usr/share/f3/f3write.h2w /usr/share/f3/f3write.h2w
COPY --from=tools /usr/share/f3/log-f3wr /usr/share/f3/log-f3wr

RUN chmod 755 /usr/bin/f3read
RUN chmod 755 /usr/bin/f3write
RUN chmod 755 /usr/bin/f3brew
RUN chmod 755 /usr/bin/f3fix
RUN chmod 755 /usr/bin/f3probe

COPY entrypoint.sh /entrypoint.sh
COPY updateDebian.sh /updateDebian.sh
COPY updateKali.sh /updateKali.sh
COPY configFileGenerator.sh /configFileGenerator.sh
COPY installMemtest.sh /installMemtest.sh
COPY backupList.txt /backupList.txt

RUN chmod +x /entrypoint.sh \
             /updateDebian.sh \
             /updateKali.sh \
             /configFileGenerator.sh \
             /installMemtest.sh 

ENTRYPOINT ["/entrypoint.sh"]

