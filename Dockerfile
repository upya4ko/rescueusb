FROM debian:latest

RUN apt-get update; apt-get install -y \
    bash \
    parted \
    wget \
    p7zip-full \
    unzip \
    ntfs-3g \
    dosfstools \
    fdisk \
    grub-pc \
    grub-efi-amd64-bin \
    grub-efi-ia32-bin \
    grub-imageboot \
    grep \
    aria2 \
    ca-certificates \
    'memtest86+' \
    f3 \
    tar \
    gzip ;\
    apt-get clean ;\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


COPY entrypoint.sh /entrypoint.sh
COPY updateDebian.sh /updateDebian.sh
COPY updateKali.sh /updateKali.sh
COPY initNonFree.sh /initNonFree.sh
COPY installMemtest.sh /installMemtest.sh
COPY unpackNonFree.sh /unpackNonFree.sh
COPY backupList.txt /backupList.txt

RUN chmod +x /entrypoint.sh \
             /updateDebian.sh \
             /updateKali.sh \
             /initNonFree.sh \
             /installMemtest.sh \
             /unpackNonFree.sh


ENTRYPOINT ["/entrypoint.sh"]

