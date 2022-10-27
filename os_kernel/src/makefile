BUILD:=./build
SRC:=.

ENTRYPOINT:=0x10000

$(BUILD)/boot/%.bin:$(SRC)/boot/%.asm
	$(shell mkdir -p $(dir $@))
	nasm  $< -o $@


$(BUILD)/kernel/%.o:$(SRC)/kernel/%.asm
	$(shell mkdir -p $(dir $@))
	nasm  -f elf32 $< -o $@


$(BUILD)/kernel.bin:$(BUILD)/kernel/start.o
	$(shell mkdir -p $(dir $@))
	ld -m elf_i386 -static $< -o $@ -Ttext $(ENTRYPOINT)

$(BUILD)/system.bin:$(BUILD)/kernel.bin
	objcopy -O binary $<  $@

$(BUILD)/system.map:$(BUILD)/kernel.bin
	nm $< | sort > $@

master.img:$(BUILD)/boot/boot.bin \
	$(BUILD)/boot/loader.bin\
	$(BUILD)/system.bin
	dd if=$(BUILD)/boot/boot.bin of=$@ bs=512 count=1 conv=notrunc
	dd if=$(BUILD)/boot/loader.bin of=$@ bs=512 count=4  seek=2 conv=notrunc
	dd if=$(BUILD)/system.bin of=$@ bs=512 count=5  seek=10 conv=notrunc
.PHONY:clean
clean:
	rm -rf $(BUILD)

.PHONY:bochs
bochs:master.img
	bochs -q
