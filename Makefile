
ORIG_ISO_URL=https://releases.ubuntu.com/20.04/ubuntu-20.04.4-live-server-amd64.iso
ORIG_ISO=iso/ubuntu-20.04.4-live-server-amd64.iso
TARGET=default
ISO=iso/ubuntu-20.04.4-live-server-amd64-sunet-$(TARGET).iso

all: $(ISO)

iso:
	mkdir -p iso

build:
	mkdir -p build

$(ORIG_ISO): iso build
	wget -O$(ORIG_ISO) $(ORIG_ISO_URL)

build/stage/md5sum.txt: $(ORIG_ISO)
	rm -rf build && mkdir -p build/iso build/stage
	mount -oro,loop $(ORIG_ISO) build/iso && rsync -a build/iso/ build/stage/ && umount build/iso

build/stage/preseed/preseed.cfg: build/stage/md5sum.txt
	env TARGET=$(TARGET) ./preseed-gen.sh > build/stage/preseed/preseed.cfg && rsync -avz overlay/ build/stage/

#$(ISO): build/stage/preseed/preseed.cfg
	mkisofs -J -l -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -z -iso-level 4 -c isolinux/isolinux.cat -o $(ISO) -joliet-long build/stage && isohybrid $(ISO) --entry 4 --type 0x1c

$(ISO): build/stage/preseed/preseed.cfg $(SRC_ISO)
	xorriso -as mkisofs -graft-points -b /isolinux/isolinux.bin -no-emul-boot -boot-info-table -boot-load-size 4 -c /isolinux/boot.cat -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin -eltorito-alt-boot -e /boot/grub/efi.img -no-emul-boot -isohybrid-gpt-basdat -V "sunet ubuntu" -o $(ISO) -r build/stage --sort-weight 0 / --sort-weight 1 /boot

clean:
	rm -rf build iso
