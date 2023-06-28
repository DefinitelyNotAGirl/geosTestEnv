.PHONY: qemu-exec
.PHONY: prep-fs

IMG=disk.cdr

test: prep-fs
	$(MAKE) -C ../geos
	$(MAKE) -C ../geos install
	@cp content/EFI/BOOT/BOOTX64.EFI content/main.efi
	$(MAKE) prep
	$(MAKE) run

prep:
#	grub-mkrescue -o bootable.iso iso
	dd if=/dev/zero of=$(IMG) bs=512 count=93750
	hdiutil create -fs fat32 -ov -size 48m -volname GEOS -format UDTO -srcfolder content $(IMG)

prep-fs:
	@mkdir -p content
	@mkdir -p content/geos
	@mkdir -p content/geos/kernel
	@mkdir -p content/EFI
	@mkdir -p content/EFI/BOOT

clean:
	rm -r content

run: qemu-exec

QEMU_D0=-drive file=/opt/homebrew/Cellar/ovmf/stable202102/share/OVMF/OvmfX64/OVMF_CODE.fd,if=pflash,format=raw,unit=0,readonly=on
QEMU_D1=-drive file=/opt/homebrew/Cellar/ovmf/stable202102/share/OVMF/OvmfX64/OVMF_VARS.fd,if=pflash,format=raw,unit=1
QEMU_DM=-drive file=$(IMG),if=ide
#QEMU_DM=
QEMU_CPU=-cpu qemu64
QEMU_NET=-net none
QEMU_MEMORY=-m 800M
QEMU_MACHINE=-machine q35
QEMU_MISC=-d in_asm,int,cpu_reset -no-reboot -no-shutdown 2> qemu.log
qemu-exec:
	qemu-system-x86_64 $(QEMU_CPU) $(QEMU_D0) $(QEMU_D1) $(QEMU_DM) $(QEMU_NET) $(QEMU_MACHINE) $(QEMU_MEMORY) $(QEMU_MISC)