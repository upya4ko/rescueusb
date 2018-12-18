BIOS
sudo qemu-system-x86_64 -m 2048 -usb /dev/sdc -hdb test1.qcow -cpu kvm64 -smp cores=4 -enable-kvm


EFI
sudo qemu-system-x86_64 -m 2048 -usb /dev/sdc -hdb test1.qcow -cpu kvm64 -smp cores=4 -enable-kvm -bios bios.bin



