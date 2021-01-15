; *******************************************************************
; *** This software is copyright 2004 by Michael H Riley          ***
; *** You have permission to use, modify, copy, and distribute    ***
; *** this software so long as this copyright notice is retained. ***
; *** This software may not be used in commercial applications    ***
; *** without express written permission from the author.         ***
; *******************************************************************

include    bios.inc
include    kernel.inc

           org     8000h
           lbr     0ff00h
           db      'stat',0
           dw      9000h
           dw      endrom+7000h
           dw      2000h
           dw      endrom-2000h
           dw      2000h
           db      0

           org     2000h
           br      start

include    date.inc
include    build.inc
           db      'Written by Michael H. Riley',0

start:
           lda     ra                  ; move past any spaces
           smi     ' '
           lbz     start
           dec     ra                  ; move back to non-space character
           ghi     ra                  ; copy argument address to rf
           phi     rf
           glo     ra
           plo     rf
loop1:     lda     rf                  ; look for first less <= space
           smi     33
           bdf     loop1
           dec     rf                  ; backup to char
           ldi     0                   ; need proper termination
           str     rf
           ghi     ra                  ; back to beginning of name
           phi     rf
           glo     ra
           plo     rf
           ldn     rf                  ; get byte from argument
           lbnz    good                ; jump if filename given
           sep     scall               ; otherwise display usage message
           dw      o_inmsg
           db      'Usage: stat filename',10,13,0
           sep     sret                ; and return to os
good:      ldi     high fildes         ; get file descriptor
           phi     rd
           ldi     low fildes
           plo     rd
           ldi     4                   ; flags for open, append
           plo     r7
           sep     scall               ; attempt to open file
           dw      o_open
           bnf     opened              ; jump if file was opened
           ldi     high errmsg         ; get error message
           phi     rf
           ldi     low errmsg
           plo     rf
           sep     scall               ; display it
           dw      o_msg
           lbr     o_wrmboot           ; and return to os
opened:    inc     rd                  ; point to offset
           inc     rd          
           lda     rd
           phi     r7                  ; put into r7
           ldn     rd
           plo     r7
           dec     rd                  ; restore descriptor
           dec     rd
           dec     rd
           sep     scall               ; close the file
           dw      o_close

;           glo     rd                  ; point to directory sector
;           adi     9
;           plo     rd
;           ghi     rd
;           adci    0
;           phi     rd
;           lda     rd                  ; retrieve sector
;           ldi     0e0h                ; force lba mode
;           phi     r8
;           lda     rd
;           plo     r8
;           lda     rd
;           phi     r7
;           lda     rd
;           plo     r7
;           ldi     high dta            ; point to sector buffer
;           phi     rf
;           ldi     low dta
;           plo     rf
;           sep     scall               ; read directory sector
;           dw      f_ideread
;           lda     rd                  ; get high byte of dir ofset
;           stxd                        ; place onto stack
;           ldn     rd                  ; get low byte of dir offset
;           str     r2                  ; place onto stack
;           ldi     low dta             ; get directory data
;           add                         ; add in dir offset
;           plo     rf                  ; and place into rf
;           irx                         ; point to high byte
;           ldi     high dta            ; compute for high byte
;           add
;           phi     rf                  ; rf now points at dir entry
;           inc     rf                  ; get starting lump
;           inc     rf
;           lda     rf
;           phi     ra
;           lda     rf
;           plo     ra
;           lda     rf                  ; set size to eof byte
;           phi     r7
;           lda     rf
;           plo     r7
;           ldi     0                   ; zero high word of count
;           phi     r8
;           plo     r8
;lumplp:    sep     scall               ; read lump value
;           dw      o_rdlump
;           ghi     ra                  ; check for end of chain
;           smi     0feh
;           bnz     notend              ; jump if not at end
;           glo     ra                  ; check low byte as well
;           smi     0feh
;           bnz     notend
;           br      endfnd              ; jump if at end
;notend:    ldi     16                  ; add 4k to count
;           str     r2
;           ghi     r7
;           add
;           phi     r7
;           glo     r8
;           adci    0
;           plo     r8
;           ghi     r8
;           adci    0
;           phi     r8
;           br      lumplp              ; and loop back for next lump

endfnd:    ghi     r7                  ; move number
           phi     rd
           glo     r7
           plo     rd
           ldi     high dta            ; point to buffer
           phi     rf
           ldi     low dta
           plo     rf
           sep     scall               ; convert number to ascii
           dw      f_uintout
           ldi     13                  ; add cr/lf
           str     rf
           inc     rf
           ldi     10
           str     rf
           inc     rf
           ldi     0                   ; and terminator
           str     rf
           ldi     high dta            ; point to buffer
           phi     rf
           ldi     low dta
           plo     rf
           sep     scall               ; and display count
           dw      o_msg
           sep     sret                ; then return to os

errmsg:    db      'File not found',10,13,0
fildes:    db      0,0,0,0
           dw      dta
           db      0,0
           db      0
           db      0,0,0,0
           dw      0,0
           db      0,0,0,0

endrom:    equ     $

buffer:    ds      20
cbuffer:   ds      80
dta:       ds      512

