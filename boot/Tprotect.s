DA_32 = 0x4000

DA_DPL0 = 0x0
DA_DPL1 = 0x20
DA_DPL2 = 0x40
DA_DPL3 = 0x60

DA_DR = 0x90
DA_DRW = 0x92
DA_DRWA = 0x93
DA_C = 0x98
DA_CR = 0x9A
DA_CC0 = 0x9C
DA_CC0R = 0x9E

#系统段描述符类型
DA_LDT		=	  0x82
DA_TaskGate	=	  0x85
DA_386TSS	=	  0x89
DA_386CGate	=	  0x8C
DA_386IGate	=	  0x8E
DA_386TGate	=	  0x8F

SA_RPL0 = 0x0
SA_RPL1 = 0x1
SA_RPL2 = 0x2
SA_RPL3 = 0x3

SA_TIG = 0x0
SA_TIL = 0x4

/*
	 */
BOOTSEG = 0x7c0
SPSEG = 0x9000
.macro Descriptor Base Limit Attr
.word 0xFFFF & \Limit
.word 0xFFFF & \Base
.byte 0xFF & (\Base >> 16)
.word (0xF00 &(\Limit>>8)) | (0xF0FF & \Attr)
.byte 0xFF & (\Base >> 24)
.endm

.global _start
.code16
.text
_start:
	jmpl $BOOTSEG , $_start2 

L_GDT : Descriptor 0 , 0 , 0
L_CODE32: Descriptor 0, (SegCodeLen-1) , (DA_C+DA_32)
L_VIDEO: Descriptor 0xB8000 , 0xFFFF , DA_DRW

GdtLen = . - L_GDT
GdtPtr : .word GdtLen-1
	.long 0
SelCode = L_CODE32 - L_GDT
SelVideo = L_VIDEO -L_GDT

_start2:
	movw %cs, %ax
	movw %ax, %es
	movw %ax, %ds
	movw %ax, %ss
	movw $0x100, %sp

	// 初始化32位代码段描述符
	xorl %eax, %eax
	movw %cs, %ax
	shll $4, %eax
	addl $L_SEG_CODE32 , %eax
	movw %ax, (L_CODE32+2)
	shrl $16, %eax
	movb %al, (L_CODE32+4)
	movb %ah, (L_CODE32+7)

	#准备加载GDTR
	xorl %eax, %eax
	movw %ds, %ax
	shll $0x4,%eax
	addl $L_GDT, %eax	#GDT范围
	movl %eax, (GdtPtr+2)	 #GDT基础地址

	lgdt GdtPtr
	cli
	#打开地址总线A20
	inb $0x92, %al
	orb 0x2 , %al
	outb %al, $0x92

	#切换到保护模式

	movl %cr0, %eax
	orl $1, %eax
	movl %eax, %cr0
	ljmp $SelCode, $0
	jmp .

Cls:
	movw $0x600, %ax
	movw $0x700, %bx
	movw $0x0,		%cx
	movw $0x184f, %dx
	int  $0x10
	jmp .
	ret

L_SEG_CODE32:
.code32
	movw $SelVideo, %ax
	movw %ax, %gs
	movl $164 , %edi
	movb $0xC, %ah
	movb $'S', %al
	movw %ax, %gs:(%edi)
	jmp .

SegCodeLen = . - L_SEG_CODE32

.org 510
BTFLAG : .word 0xAA55
