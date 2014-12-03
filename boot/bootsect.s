BOOTSEG=0x07c0
.global _start
.text
.code16

_start:

	jmpl $BOOTSEG, $_start2

_start2:
	movw %cs, %ax
	movw %ax, %ds
	movw %ax, %es

	movw $0x600, %ax
	movw $0x700, %bx
	movw $0x0,		%cx
	movw $0x184f, %dx
	int  $0x10

	movw $msg, %bp
	movw $0x0, %dx
	movw $len, %cx
	movw $0xc, %bx
	movw $0x1301, %ax
	int $0x10
	jmp .

msg : .string "SexyOS"
len = . - msg
.org 510
BOOT_FLAG : .word 0xAA55
