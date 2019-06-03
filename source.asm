/***************************************************************************************
;* Titulo: MCUHCS08QG8.equ                     (c)FREESCALE Inc 2019 All rights reserved.
;* Proyecto : BestPractices 
;* Source: Main.asm 
;* Autor: Andrés Felipe Herrera - Juan Sebastian Realpe 
;* Sergio Ballesteros 
;* Est Ingeniería Mecatrónica-Universidad Nacional de Colombia
;*
;* Descripción: Programa de ejemplo para aplicacion de buenas practicas en assembly, con 
;* modulos de ejemplo aplicados en ejemplo de cambio de estado de led con pulsador 
;* Documentacion: 
;* NT001 Como empezar a usar el microcontrolador 
;* AN2111: A Coding Standard for HCS08 Assembly Language
;* Hoja de Datos MCUHCS08QG8
;* ARCHIVOS INCLUIDOS: Ninguno 
;* LENGUAJE: ABSOLUTE ASSEMBLY
;* ASSEMBLER: Codewarrior 10.7
;*************************************************************************************** 
;* HISTORIAL:
;* DD MM AA        DESCRIPCION                             QUIEN              REV
;*--------------------------------------------------------------------------------------
;* 16 04 19        INICIALIZACION DE CODIGO                 JREALPE           0.0
;* 17 04 19        SE COMENTARON RUTINAS Y SUBRUTINAS       AHERRERA          1.0
;*
;****************************************************************************************/

;Include derivative-specific definitions
            INCLUDE 'derivative.inc'

;export symbols;
            XDEF _Startup, main
            ; we export both '_Startup' and 'main' as symbols. Either can
            ; be referenced in the linker .prm file or from C/C++ later on
            XREF __SEG_END_SSTACK   ; symbol defined by the linker for the end of the stack

; variable/data section
MY_ZEROPAGE: SECTION  SHORT         ;seccion de la pagina zero de la RAM
btnst:   dc.b  1                    ;variable para estado de boton
; code section
MyCode:     SECTION
main:
_Startup:
            LDHX   #__SEG_END_SSTACK ; initialize the stack pointer
            TXS
            lda   #$02               ;desactivar watchdog, dejar modo BKGD enabled
            sta   SOPT1             ;BKGD jamas disabled
            mov   #%11111110,PTADD  ;puerto A bit0 como entrada
            lda   #$01              ;cargar hex 01 en acumulador
            sta   PTAPE             ;habilitar pull-up en pin0 de PTA
                                    ;puerto en estado natural en 1 logico
                                    ;boton presionado lo pone en 0 logico
            mov   #$01,btnst        ;dar un estado inicial a variable de boton
            mov   #%00000100,PTBDD  ;puerto B bit2 como salida
            mov   #%00000100,PTBD   ;bit2 del puerto B en 1 logico
            
mainLoop:   
            brclr 0,PTAD,boton      ;pregunta si boton esta presionado, osea bit en 0, 
                                    ;dado el caso salta a rutina boton
            BRA    mainLoop
;************************************************************************************************
;* boton  - Actualiza el puerto PTBD a partir de valor de la variable btnst
;* 
;*
;* I/O: Recibe   btnst,PTBD
;*                  
;*      Devuelve: PTBD actualizado 
;*
;* Convención de llamada: 
;*                         jsr boton 
;*                         bra boton 
;*                         
;*
;* Registros Afectados: A , PTBD 
;************************************************************************************************            
            
boton:
            mov   #$00,btnst        ;atualizar variable estado boton.
            lda   PTBD              ;cargar estado actual del puerto B en acumulador.
            eor   #%00000100        ;operación XOR entre el acumulador y el numero indicado
                                    ;hacer esta operación con ese bit en especifico resulta en alternar el bit
                                    ;correspondiente, resultado se guarda en el acumulador.
            sta   PTBD              ;guardar en PTBD lo presente en el acumulador
still:
            lda   PTAD              ;cargar el estado actual del puerto A
            cbeq  btnst,still       ;compare el acumulador con btnst, branch if equal a etiqueta still
                                    ;haciendo esta comparacion le decimos a el MCU que espere a que dejemos de
                                    ;pulsar el boton para continuar y asi completar la acción de alternar el estado
                                    ;del puerto o del LED en este caso
            nop                     ;no operation para tener una pequqeña pausa
            bra   mainLoop          ;devuelta al mainLoop.




