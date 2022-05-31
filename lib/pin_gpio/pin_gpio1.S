// Cortex-M3 Devices Generic User Guide: https://developer.arm.com/documentation/dui0552/
// STM32f103xx Family Reference Manual: https://www.st.com/resource/en/reference_manual/cd00171190-stm32f101xx-stm32f102xx-stm32f103xx-stm32f105xx-and-stm32f107xx-advanced-arm-based-32-bit-mcus-stmicroelectronics.pdf
// STM32f103c8 Datasheet: https://www.st.com/resource/en/datasheet/stm32f103c8.pdf
// Procedure Call Standard for the Arm Architecture: https://github.com/ARM-software/abi-aa/blob/main/aapcs32/aapcs32.rst
.syntax unified
.cpu cortex-m3
.fpu softvfp
.thumb

.macro defun nombre
    .section .text.\nombre
    .global \nombre
    .type \nombre, %function
\nombre:
.endm
.macro endfun nombre
    .size \nombre, . - \nombre
.endm

.set Pin__puerto,0
.set Pin__numero,4

defun Pin_init
    // R0: self, R1: puerto, R2: numPin
    str R1,[R0,#Pin__puerto]
    str R2,[R0,#Pin__numero]
    bx lr
endfun Pin_init

.set CRL,0x00
.set CRH,0x04
.set IDR,0x08
.set ODR,0x0C
.set BSRR,0x10
.set BRR,0x14
.set MASCARA_BITS, 0xF

defun Pin_configura
    // R0: self, R1: config
    push {R4-R7,LR}
    ldr R2,[R0,#Pin__puerto]
    ldr R3,[R0,#Pin__numero]
    movs R7,R1
    cmp R3,#7
    bls 0f
    mov R6,#CRH
    subs R3,#8
    b 1f
0: 
    mov R6,#CRL
1:  ldr R4,[R2,R6]
    lsls R3,#2
    mov R5,#MASCARA_BITS
    lsls R5,R3
    bics R4,R5
    ands R1,#MASCARA_BITS
    lsls R1,R3
    orrs R4,R1
    str R4,[R2,R6]
    cmp R7,0b01000
    bne 1f
    mov R1,#0
    bl Pin_escribe
1:  cmp R7,0b11000
    bne 1f
    mov R1,#1
    bl Pin_escribe
1:  pop {R4-R7,PC}
endfun Pin_configura



defun Pin_escribe
    // R0: self, R1: valor
    ldr R2,[R0,#Pin__puerto]
    ldr R3,[R0,#Pin__numero]
    mov R0,#1
    lsls R0,R3
    cmp R1,#0
    beq 0f
    str R0,[R2,#BSRR]
    b 1f
0:  str R0,[R2,#BRR]
1:  bx lr
endfun Pin_escribe

defun Pin_lee
    // R0: self
    ldr R2,[R0,#Pin__puerto]
    ldr R3,[R0,#Pin__numero]
    ldr R0,[R2,#IDR]
    mov R1,#1
    lsls R1,R3
    and R0,R1
    lsrs R0,R3
    bx lr
    // R0: valor
endfun Pin_lee
defun Pin_leeSalida
    // R0: self
    bx lr
    // R0: valor
endfun Pin_leeSalida
