.model small
.stack 100h
.data

bufsize=500

buffer db bufsize dup(?)
infile BYTE "C:\COAL\MASM611\BIN\\records.txt",0

inhandle WORD ?

bytesread WORD ?

slow dw 28000
slow2 dw 20000
slow3 dw 10000

nameit db "NUMBER CATCHER    (PRESS 'Q' TO EXIT GAME)",'$'

gameover db "G.A.M.E/\O.V.E.R",0Dh,0Ah,'$'
gamescore db "SCORE: ",'$'
score dw 0

level db "LEVEL ",'$'

numb dw ?

count db 0

tflag db 0
iflag db 0
mflag db 0
eflag db 0
pflag db 0
lflag db 0
zflag db 0
cheatflag db 0

flag db 0
exitflag db 0

scancode db 0

timer dw 399

time db "Timer: ",'$'

multiplier dw 8192
modolus dw 25
modcol dw 77
adder dw 1013
xnot dw 0
ynot dw 0
xnot1 dw ?

modolus2 dw 25
xnot2 dw ?

modolus3 dw 25
xnot3 dw ?

draw2flag db 0

temp dw ?
newline db " ",0Dh,0Ah,'$'

hrs db 0
mins db 0
secs db 0
milisec db 0

crow db 0

randrow db 2
randcol dw ?

bas1row db 17
bas1col db 51

bas2row db 17
bas2col db 52

bas3row db 17
bas3col db 53

bas4row db 17
bas4col db 54

bas5row db 17
bas5col db 55

headrow db 18
headcol db 55

l_arm1row db 18
l_arm1col db 53

l_arm2row db 19
l_arm2col db 53

l_arm3row db 19
l_arm3col db 54

r_arm1row db 19
r_arm1col db 56

r_arm2row db 19
r_arm2col db 57

body1row db 19
body1col db 55

body2row db 20
body2col db 55

l_leg1row db 20
l_leg1col db 54

l_leg2row db 21
l_leg2col db 54

r_leg1row db 20
r_leg1col db 56

r_leg2row db 21
r_leg2col db 56

.code
main proc

mov ax,@data
mov ds,ax

mov al,03
mov ah,0
int 10h

mov ch, 32
mov ah, 1
int 10h

Call Draw   	 ;Draw background and layout

fallingnum:      ;beginning of new number

mov dh,crow
mov dl,BYTE PTR randcol
mov bh,0			;---Clearing Last Index---
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

mov flag,0

cmp score,20	;---check level for generating random numbers according to specs of each level----
jge ran2

Call rand

jmp just1

ran2:		;---for level2----
cmp score,40
jge ran3

call rand2	;---generates random numbers with twice as much 0's---
jmp just1

ran3:		;----for level3----

call rand3	;---generates random numbers with thrice as much 0's---

just1:

mov randrow,2

cmp randcol,0	;---left boundary---
je addmore

cmp randcol,1	;---left boundary---
je addmore

cmp randcol,78	;---right boundary---
je red

cmp randcol,79	;---right boundary---
je red

jmp gameon

red:
add randcol,4   ;---add to randcol so that number does not fall in the boundary----

jmp gameon

addmore:
add randcol,2

gameon:

;===CHEATS CHECK====
cmp tflag,1
je tdone

jmp nocheat

tdone:
cmp iflag,1
je idone		;----CHECKS FLAG OF EACH LETTER IF ACTIVATED OR NOT-----

jmp nocheat

idone:
cmp mflag,1
je mdone

jmp nocheat

mdone:
cmp eflag,1
je edone

jmp nocheat

edone:
cmp pflag,1
je pdone

jmp nocheat

pdone:
cmp lflag,1
je ldone

jmp nocheat

ldone:
cmp zflag,1		;---IF ALL CHEAT FLAGS HAVE BEEN ACTIVATED CHEATS ARE ENABLED---
je zdone

zdone:
inc cheatflag

nocheat:

cmp cheatflag,0
jne cheatson
jmp nope

cheatson:
mov tflag,0
mov iflag,0
mov mflag,0
mov eflag,0
mov pflag,0
mov lflag,0
mov zflag,0
mov cheatflag,0
add timer,500

nope:

mov dh,23
mov dl,12
mov bh,0
mov ah,2
int 10h

call doubledigit	;---Display Updated Score---


mov dh,0
mov dl,60
mov bh,0
mov ah,2
int 10h

mov ah,09
mov dx,offset time	;----DISPLAY TIMER-----
int 21h

mov dh,0
mov dl,66
mov bh,0
mov ah,2
int 10h

call timedisplay	;---DISPLAY TIME USING DOUBLEDIGIT----

cmp timer,99
jle thenrem		;---If time becomes 99 or less then the extra digit is removed from double digit display----

jmp it

thenrem:
mov dh,0
mov dl,68
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

it:

cmp timer,9
jle thenrems		;---If time becomes 9 or less then only display single digit-----

jmp its

thenrems:
mov dh,0
mov dl,68
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

mov dh,0
mov dl,67
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

its:

mov scancode,0

;****FALLING NUMBERS****

mov ah,6	;check input buffer
mov dl,0FFh	
int 21h
mov scancode,al

cmp scancode,0
jne moves

jmp dontmoves

moves:
call movement   ;---Movement of stick figure----

dontmoves:


mov dh,randrow
mov dl,BYTE PTR randcol
mov bh,0
mov ah,2
int 10h

mov ah,40h			;Display Function
mov bx,1			;Console
mov cx,1			; 10 bytes to display
mov dx,offset buffer		;Buffer contains these bytes
int 21h

mov ah,6	;---CHECK KB HIT AGAIN INCASE USER HAS PRESSED ANY KEY.TO AVOID DELAY----
mov dl,0FFh	
int 21h
mov scancode,al

cmp scancode,0
jne moves

jmp dontmovess

movess:
call movement   ;---Movement of stick figure----

dontmovess:

cmp score,20	;---CHECK LEVEL OF GAME---
jge level2

mov dh,0
mov dl,11
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,1
add dl,30h	;----Displaying level1----
int  21h

call drawlevel1

call Delay

jmp firstl

level2:
cmp score,40	;---CHECK FOR LEVEL 3---
jge level3

mov dh,0
mov dl,11
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,2	;----Displaying level2----
add dl,30h
int  21h

call drawlevel2

call Delay2     ;---DELAY FOR LEVEL2-----

jmp firstl

level3:

mov dh,0
mov dl,11
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,3	;----Displaying level3----
add dl,30h
int  21h

call drawlevel3

call Delay3	;----DELAY FOR LEVEL3-----

firstl:

mov dh,randrow
mov crow,dh

mov ah,6	;check input buffer again to avoid delay in movement
mov dl,0FFh	
int 21h
mov scancode,al

cmp scancode,0
jne move

jmp dontmove

move:
call movement   ;---Movement of stick figure----

dontmove:

cmp exitflag,0
jne exit	;---Checks if 'Q' has been pressed and exits game loop if yes----

Call addscore	;-----Check number hit in basket and add score----

cmp flag,1
je fallingnum	;---If number falls into basket..flag value becomes 1 and indicates end of number fall----

mov ah,randrow
cmp ah,17	;---If number has reached last row---
je fallingnum

inc randrow
dec timer

mov dh,crow
mov dl,BYTE PTR randcol		;----CLEANS UP NUMBER FROM CURRENT LOCATION-----
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

cmp timer,0
je exit

jmp gameon

exit:		;---GAME EXIT----

mov dh,0
mov dl,60
mov bh,0
mov ah,2
int 10h

mov ah,09
mov dx,offset time	;----DISPLAY TIMER-----
int 21h

mov dh,0
mov dl,66
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,0
add dl,30h
int 21h

mov dh,12
mov dl,35
mov bh,0
mov ah,2
int 10h

mov ah,09
mov dx,offset gameover
int 21h

mov ax,4C00h
int 21h

main endp

;====DRAWING======
Draw proc

;===BACKGROUND BLUE COLOR===
mov ah, 06h
mov al, 0
mov cx, 0
mov dh, 17		
mov dl, 79
mov bh, 1Fh
int 10h

;===PATTERN====
mov ah, 06h
mov al, 0
mov ch, 0     ;upper row
mov cl,4      ;leftcol
mov dh, 17    ;lower row
mov dl, 5     ;rightcol
mov bh, 35h
int 10h

mov ah, 06h
mov al, 0
mov ch, 0     ;upper row
mov cl,74      ;leftcol
mov dh, 17    ;lower row
mov dl, 75     ;rightcol
mov bh, 35h
int 10h



;===LOWER BACKGROUND GREEN COLOR====
mov ah, 06h
mov al, 0
mov ch, 18
mov cl,0
mov dh, 21
mov dl, 79
mov bh, 2Fh
int 10h

;====UPPER BOUNDARY======
mov ah, 06h
mov al, 0
mov ch, 0
mov cl,1
mov dh, 0
mov dl, 78
mov bh, 4Fh
int 10h


;====LOWER BOUNDARY=====
mov ah, 06h
mov al, 0
mov ch, 22
mov cl,0
mov dh, 23
mov dl, 79
mov bh, 4Fh
int 10h

;==NAME OF THE GAME==
mov dh,23
mov dl,33
mov bh,0
mov ah,2
int 10h

mov ah,09
mov dx,offset nameit
int 21h

;==INGAME SCORE==
mov dh,23
mov dl,5
mov bh,0
mov ah,2
int 10h

mov ah,09
mov dx,offset gamescore
int 21h

;==INGAME LEVEL==
mov dh,0
mov dl,5
mov bh,0
mov ah,2
int 10h

mov ah,09
mov dx,offset level
int 21h

;====LEFT BOUNDARY======
mov ah, 06h
mov al, 0
mov ch, 0
mov cl,0
mov dh, 23
mov dl, 1
mov bh, 4Fh
int 10h

;====RIGHT BOUNDARY====
mov ah, 06h
mov al, 0
mov ch, 0
mov cl,78
mov dh, 23
mov dl, 79
mov bh, 4Fh
int 10h

;====BASKET LEFT END=====
mov dh,17
mov dl,51
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,200
int 21h


;=====BASKET MIDDLE====

mov dh,17
mov dl,52
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,205
int 21h

mov dh,17
mov dl,54
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,205
int 21h


;=====BASKET RIGHT END====

mov dh,17
mov dl,55
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,188
int 21h

;=====HEAD===

mov dh,18
mov dl,55
mov bh,0
mov ah,2
int 10h

mov ax,02001h

mov ah,02
mov dl,al
int 21h

;===LEFT ARM====

mov dh,17
mov dl,53
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,209
int 21h

mov dh,18
mov dl,53
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,179
int 21h

mov dh,19
mov dl,53
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,192
int 21h

mov dh,19
mov dl,54
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,196
int 21h

;====RIGHT ARM===

mov dh,19
mov dl,56
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,196
int 21h

mov dh,19
mov dl,57
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,191
int 21h



;===UPPER BODY===

mov dh,19
mov dl,55
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,186
int 21h

mov dh,20
mov dl,55
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,208
int 21h

;====LOWER BODY===


mov dh,20
mov dl,54
mov bh,0	;LEFT LEG
mov ah,2
int 10h

mov ah,02
mov dl,218
int 21h

mov dh,21
mov dl,54
mov bh,0	
mov ah,2
int 10h

mov ah,02
mov dl,217
int 21h

mov dh,20
mov dl,56
mov bh,0	;RIGHT LEG
mov ah,2
int 10h

mov ah,02
mov dl,191
int 21h

mov dh,21
mov dl,56
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,192
int 21h

;#####END OF DRAWING PART####

RET
Draw endp


;====MOVEMENT====

movement proc

cmp scancode,'q'	;--INCASE OF ESCAPE KEY---
je exits

cmp scancode,4Bh      ;--INCASE OF LEFT KEY----
je movleft

cmp scancode,4Dh	;--INCASE OF RIGHT KEY---
je movright

cmp scancode,'t'
je tcheat

cmp scancode,'i'
je icheat

cmp scancode,'m'
je mcheat

cmp scancode,'e'
je echeat

cmp scancode,'p'
je pcheat

cmp scancode,'l'
je lcheat

cmp scancode,'z'
je zcheat

jmp endit

tcheat:
inc tflag
jmp endit

icheat:
inc iflag
jmp endit

mcheat:
inc mflag
jmp endit

echeat:
inc eflag
jmp endit

pcheat:
inc pflag
jmp endit

lcheat:
inc lflag
jmp endit

zcheat:
inc zflag
jmp endit

;====LEFT KEY====

movleft:

;***BASKET MOVE*****

mov bl,bas1col
cmp bl,2		;####CHECK IF LEFT WALL HAS BEEN REACHED####
je endit

mov dh,bas1row
mov dl,bas1col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

dec bas1col

mov dh,bas1row
mov dl,bas1col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,200
int 21h

mov dh,bas2row
mov dl,bas2col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

dec bas2col

mov dh,bas2row
mov dl,bas2col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,205
int 21h

mov dh,bas3row
mov dl,bas3col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

dec bas3col

mov dh,bas3row
mov dl,bas3col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,209
int 21h

mov dh,bas4row
mov dl,bas4col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

dec bas4col

mov dh,bas4row
mov dl,bas4col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,205
int 21h

mov dh,bas5row
mov dl,bas5col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

dec bas5col

mov dh,bas5row
mov dl,bas5col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,188
int 21h

mov dh,headrow
mov dl,headcol
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

dec headcol

mov dh,headrow
mov dl,headcol
mov bh,0
mov ah,2
int 10h

mov ax,02001h

mov ah,02
mov dl,al
int 21h

mov dh,l_arm1row
mov dl,l_arm1col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

dec l_arm1col

mov dh,l_arm1row
mov dl,l_arm1col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,179
int 21h

mov dh,l_arm2row
mov dl,l_arm2col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

dec l_arm2col

mov dh,l_arm2row
mov dl,l_arm2col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,192
int 21h

mov dh,l_arm3row
mov dl,l_arm3col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

dec l_arm3col

mov dh,l_arm3row
mov dl,l_arm3col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,196
int 21h

mov dh,r_arm1row
mov dl,r_arm1col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

dec r_arm1col

mov dh,r_arm1row
mov dl,r_arm1col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,196
int 21h

mov dh,r_arm2row
mov dl,r_arm2col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

dec r_arm2col

mov dh,r_arm2row
mov dl,r_arm2col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,191
int 21h

mov dh,body1row
mov dl,body1col
mov bh,0
mov ah,2
int 10h

dec body1col

mov dh,body1row
mov dl,body1col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,186
int 21h

mov dh,body2row
mov dl,body2col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

dec body2col

mov dh,body2row
mov dl,body2col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,208
int 21h

mov dh,l_leg1row
mov dl,l_leg1col
mov bh,0
mov ah,2
int 10h

dec l_leg1col

mov dh,l_leg1row
mov dl,l_leg1col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,218
int 21h

mov dh,l_leg2row
mov dl,l_leg2col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

dec l_leg2col

mov dh,l_leg2row
mov dl,l_leg2col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,217
int 21h


mov dh,r_leg1row
mov dl,r_leg1col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

dec r_leg1col

mov dh,r_leg1row
mov dl,r_leg1col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,191
int 21h


mov dh,r_leg2row
mov dl,r_leg2col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

dec r_leg2col

mov dh,r_leg2row
mov dl,r_leg2col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,192
int 21h

;####END OF LEFTKEY PROCESS#####
jmp endit


;====RIGHT KEY=====

movright:


mov bl,r_arm2col
cmp bl,77		;####CHECK IF RIGHT WALL HAS BEEN REACHED####
je endit

mov dh,bas5row
mov dl,bas5col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

inc bas5col

mov dh,bas5row
mov dl,bas5col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,188
int 21h

mov dh,bas4row
mov dl,bas4col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

inc bas4col

mov dh,bas4row
mov dl,bas4col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,205
int 21h

mov dh,bas3row
mov dl,bas3col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

inc bas3col

mov dh,bas3row
mov dl,bas3col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,209
int 21h

mov dh,bas2row
mov dl,bas2col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

inc bas2col

mov dh,bas2row
mov dl,bas2col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,205
int 21h

mov dh,bas1row
mov dl,bas1col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

inc bas1col

mov dh,bas1row
mov dl,bas1col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,200
int 21h

mov dh,headrow
mov dl,headcol
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

inc headcol

mov dh,headrow
mov dl,headcol
mov bh,0
mov ah,2
int 10h

mov ax,02001h

mov ah,02
mov dl,al
int 21h

mov dh,r_arm1row
mov dl,r_arm1col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

inc r_arm1col

mov dh,r_arm1row
mov dl,r_arm1col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,196
int 21h

mov dh,r_arm2row
mov dl,r_arm2col
mov bh,0
mov ah,2
int 10h

inc r_arm2col

mov dh,r_arm2row
mov dl,r_arm2col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,191
int 21h

mov dh,body1row
mov dl,body1col
mov bh,0
mov ah,2
int 10h

inc body1col

mov dh,body1row
mov dl,body1col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,186
int 21h

mov dh,body2row
mov dl,body2col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

inc body2col

mov dh,body2row
mov dl,body2col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,208
int 21h

mov dh,l_arm1row
mov dl,l_arm1col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

inc l_arm1col

mov dh,l_arm1row
mov dl,l_arm1col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,179
int 21h

mov dh,l_arm2row
mov dl,l_arm2col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

inc l_arm2col

mov dh,l_arm2row
mov dl,l_arm2col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,192
int 21h

mov dh,l_arm3row
mov dl,l_arm3col
mov bh,0
mov ah,2
int 10h

inc l_arm3col

mov dh,l_arm3row
mov dl,l_arm3col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,196
int 21h

mov dh,r_leg1row
mov dl,r_leg1col
mov bh,0
mov ah,2
int 10h

inc r_leg1col

mov dh,r_leg1row
mov dl,r_leg1col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,191
int 21h


mov dh,r_leg2row
mov dl,r_leg2col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

inc r_leg2col

mov dh,r_leg2row
mov dl,r_leg2col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,192
int 21h

mov dh,l_leg1row
mov dl,l_leg1col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

inc l_leg1col

mov dh,l_leg1row
mov dl,l_leg1col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,218
int 21h

mov dh,l_leg2row
mov dl,l_leg2col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,' '
int 21h

inc l_leg2col

mov dh,l_leg2row
mov dl,l_leg2col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,217
int 21h

;####END OF RIGHT KEY PROCESS####

endit:

jmp a

exits:

inc exitflag

a:

RET

movement endp
;###END OF MOVEMENT FUNCTION###

;====RANDOM NUMBER GENERATOR======
rand proc


mov ax,xnot
mul multiplier
mov xnot1,ax

mov ax,adder
add xnot1,ax

mov ax,xnot1
mov bx,modolus
div bx

mov xnot1,dx
mov xnot,dx

mov ax,xnot1
mov bx,3
mul bx

mov xnot1,ax

neon:

;----------open input file----------------------
mov ah,3dh
mov al,0
mov dx, offset infile
int 21h
jc quit
mov inhandle,ax
mov ax,xnot1			;AX contains the record to be fetch. 0 means first record
mov bx,1			;Fixed Length of each record that is 10
mul bx				; Ax=Ax*BX
mov cx,dx			;Upper half of offset in CX
mov dx,ax			;Lower half of offset in DX
mov ah,42h			;File Pointer 
mov al,0			;Offset from the begining of file
mov bx,inhandle			; File Handler moved to BX
int 21h

mov ah,3fh			; Reading the desired record
mov bx,inhandle			; Reading from File
mov cx,1			; 10 bytes 
mov dx,offset buffer		; saving these bytes to buffer
int 21h
jc quit

;---------------------------------------------------------

mov bx,offset buffer
mov ax,[bx]
mov numb,ax
sub numb,30h

mov ax,ynot
mul multiplier
mov randcol,ax

mov ax,adder			;---FOR GENERATING RANDOM COLUMN-----
add randcol,ax

mov ax,randcol
mov bx,modcol
div bx

mov randcol,dx
mov ynot,dx

;----------close file--------------------------------
mov ah,3Eh
mov bx,inhandle
int 21h
jc quit

quit:

RET
rand endp

;====RANDOM2 NUMBER GENERATOR======
rand2 proc

mov ax,xnot2
mul multiplier
mov xnot1,ax

mov ax,adder
add xnot1,ax

mov ax,xnot1
mov bx,modolus2
div bx

mov xnot1,dx
mov xnot2,dx

cmp xnot1,12
jg dosomes

mov ax,xnot1
mov bx,3
mul bx

mov xnot1,ax

neonx:

;----------open input file----------------------
mov ah,3dh
mov al,0
mov dx, offset infile
int 21h
jc quits
mov inhandle,ax
mov ax,xnot1			;AX contains the record to be fetch. 0 means first record
mov bx,1			;Fixed Length of each record that is 10
mul bx				; Ax=Ax*BX
mov cx,dx			;Upper half of offset in CX
mov dx,ax			;Lower half of offset in DX
mov ah,42h			;File Pointer 
mov al,0			;Offset from the begining of file
mov bx,inhandle			; File Handler moved to BX
int 21h

mov ah,3fh			; Reading the desired record
mov bx,inhandle			; Reading from File
mov cx,1			; 10 bytes 
mov dx,offset buffer		; saving these bytes to buffer
int 21h
jc quits

;---------------------------------------------------------

mov bx,offset buffer
mov ax,[bx]
mov numb,ax
sub numb,30h

jmp ets

dosomes:
mov [buffer],'0'
mov bx,offset buffer
mov ax,[bx]
mov numb,ax
sub numb,30h

ets:

mov ax,ynot
mul multiplier
mov randcol,ax

mov ax,adder
add randcol,ax

mov ax,randcol
mov bx,modcol
div bx

mov randcol,dx
mov ynot,dx

;----------close file--------------------------------
mov ah,3Eh
mov bx,inhandle
int 21h
jc quits

quits:

RET
rand2 endp

;====RANDOM3 NUMBER GENERATOR======
rand3 proc

mov ax,xnot3
mul multiplier
mov xnot1,ax

mov ax,adder
add xnot1,ax

mov ax,xnot1
mov bx,modolus3
div bx

mov xnot1,dx
mov xnot3,dx

cmp xnot1,9
jg dosomess

mov ax,xnot1
mov bx,3
mul bx

mov xnot1,ax

neonxx:

;----------open input file----------------------
mov ah,3dh
mov al,0
mov dx, offset infile
int 21h
jc quitss
mov inhandle,ax
mov ax,xnot1			;AX contains the record to be fetch. 0 means first record
mov bx,1			;Fixed Length of each record that is 10
mul bx				; Ax=Ax*BX
mov cx,dx			;Upper half of offset in CX
mov dx,ax			;Lower half of offset in DX
mov ah,42h			;File Pointer 
mov al,0			;Offset from the begining of file
mov bx,inhandle			; File Handler moved to BX
int 21h

mov ah,3fh			; Reading the desired record
mov bx,inhandle			; Reading from File
mov cx,1			; 10 bytes 
mov dx,offset buffer		; saving these bytes to buffer
int 21h
jc quitss

;---------------------------------------------------------

mov bx,offset buffer
mov ax,[bx]
mov numb,ax
sub numb,30h

jmp etss

dosomess:
mov [buffer],'0'
mov bx,offset buffer
mov ax,[bx]
mov numb,ax
sub numb,30h

etss:

mov ax,ynot
mul multiplier
mov randcol,ax

mov ax,adder
add randcol,ax

mov ax,randcol
mov bx,modcol
div bx

mov randcol,dx
mov ynot,dx

;----------close file--------------------------------
mov ah,3Eh
mov bx,inhandle
int 21h
jc quitss

quitss:

RET
rand3 endp

;====DELAY FUNCTION=====

Delay proc

push cx
mov cx,slow
delay3:
push cx
mov cx,slow
delay4:
loop delay4
pop cx
loop delay3
pop cx

RET
Delay ENDP
;====LEVEL 2 DELAY FUNCTION=====
Delay2 proc

push cx
mov cx,slow2
delay3x:
push cx
mov cx,slow2
delay4x:
loop delay4x
pop cx
loop delay3x
pop cx

RET

Delay2 endp

;====LEVEL 3 DELAY FUNCTION=====

Delay3 proc

push cx
mov cx,slow3
delay3xx:
push cx
mov cx,slow3
delay4xx:
loop delay4xx
pop cx
loop delay3xx
pop cx

RET

Delay3 endp

;====SCORE FUNCTION======

addscore proc

inc randrow

mov ah,BYTE PTR randcol
mov bh,randrow

cmp ah,bas1col
je checknext1

jmp part2

checknext1:
cmp bh,bas1row		;----CHECK NUMBER WITH ROW AND COLUMN OF ALL 5 PARTS oF THE BASKET
je addtoit		;----IF ANY PART MATCHES WITH ROW AND COL NUM OF THE NUMBER THEN ADDScCORE

part2:

cmp ah,bas2col
je checknext2

jmp part3

checknext2:
cmp bh,bas2row
je addtoit

part3:

cmp ah,bas3col
je checknext3

jmp part4

checknext3:
cmp bh,bas3row
je addtoit

part4:

cmp ah,bas4col
je checknext4

jmp part5

checknext4:
cmp bh,bas4row
je addtoit

part5:

cmp ah,bas5col
je checknext5

jmp part6

checknext5:
cmp bh,bas5row
je addtoit

jmp part6

addtoit:
cmp numb,0
je subtractscore
mov ax,score		;---ADD THE NUMBER CAUGHT TO SCORE AND IF 0 SUBTRACT 5 FROM SCORE-----
add ax,numb
mov score,ax
add flag,1

jmp part6

subtractscore:
sub score,5
add flag,1

part6:

dec randrow

RET
addscore endp

;====DOUBLE DIGIT CODE FOR DISPLAYING SCORE====

doubledigit proc

    mov ax,score

    mov cx,0

    mov dx,0

    mov bx,10d

  	loop1:
    	mov dx,0	;ax: Quotient

    	div bx	        

    	push dx		;dx: Remainder

    	inc cx
    	cmp ax,0	;if ax!=0 then

    	jnz loop1	;Loop will be repeated

  	loop2:
    	mov ah,02
    	pop dx
    	add dl,48
    	int 21h

    	dec cx

    	cmp cx,0	;if cx!=0 then
    	jnz loop2	;Loop will be repeated

RET
doubledigit endp

;====DOUBLE DIGIT CODE FOR DISPLAYING time====

timedisplay proc

    mov ax,timer

    mov cx,0

    mov dx,0

    mov bx,10d

  	loop11:
    	mov dx,0	;ax: Quotient

    	div bx	        

    	push dx		;dx: Remainder

    	inc cx
    	cmp ax,0	;if ax!=0 then

    	jnz loop11	;Loop will be repeated

  	loop22:
    	mov ah,02
    	pop dx
    	add dl,48
    	int 21h

    	dec cx

    	cmp cx,0	;if cx!=0 then
    	jnz loop22	;Loop will be repeated

RET
timedisplay endp

;===LEVEL2 DRAw======

drawlevel2 proc

mov ah, 06h
mov al, 0
mov ch, 1    ;upper row
mov cl,2      ;leftcol
mov dh, 17    ;lower row
mov dl, 77    ;rightcol
mov bh, 6Fh
int 10h

;===PATTERN====
mov ah, 06h
mov al, 0
mov ch, 1    ;upper row
mov cl,4      ;leftcol
mov dh, 17    ;lower row
mov dl, 5     ;rightcol
mov bh, 5Fh
int 10h

mov ah, 06h
mov al, 0
mov ch, 1    ;upper row
mov cl,74      ;leftcol
mov dh, 17    ;lower row
mov dl, 75     ;rightcol
mov bh, 5Fh
int 10h

;====BASKET LEFT END=====
mov dh,bas1row
mov dl,bas1col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,200
int 21h


;=====BASKET MIDDLE====

mov dh,bas2row
mov dl,bas2col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,205
int 21h

mov dh,bas3row
mov dl,bas3col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,209
int 21h

mov dh,bas4row
mov dl,bas4col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,205
int 21h


;=====BASKET RIGHT END====

mov dh,bas5row
mov dl,bas5col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,188
int 21h

mov dh,randrow
mov dl,BYTE PTR randcol
mov bh,0
mov ah,2
int 10h

mov ah,40h			;Display Function
mov bx,1			;Console
mov cx,1			; 10 bytes to display
mov dx,offset buffer		;Buffer contains these bytes
int 21h


RET
drawlevel2 endp

;===LEVEL3 DRAw======

drawlevel3 proc

mov ah, 06h
mov al, 0
mov ch, 1    ;upper row
mov cl,2      ;leftcol
mov dh, 17    ;lower row
mov dl, 77    ;rightcol
mov bh, 5Fh
int 10h

;===PATTERN====
mov ah, 06h
mov al, 0
mov ch, 1    ;upper row
mov cl,4      ;leftcol
mov dh, 17    ;lower row
mov dl, 5     ;rightcol
mov bh, 1Fh
int 10h

mov ah, 06h
mov al, 0
mov ch, 1    ;upper row
mov cl,74      ;leftcol
mov dh, 17    ;lower row
mov dl, 75     ;rightcol
mov bh, 1Fh
int 10h

;====BASKET LEFT END=====
mov dh,bas1row
mov dl,bas1col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,200
int 21h


;=====BASKET MIDDLE====

mov dh,bas2row
mov dl,bas2col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,205
int 21h

mov dh,bas3row
mov dl,bas3col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,209
int 21h

mov dh,bas4row
mov dl,bas4col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,205
int 21h


;=====BASKET RIGHT END====

mov dh,bas5row
mov dl,bas5col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,188
int 21h

mov dh,randrow
mov dl,BYTE PTR randcol
mov bh,0
mov ah,2
int 10h

mov ah,40h			;Display Function
mov bx,1			;Console
mov cx,1			; 10 bytes to display
mov dx,offset buffer		;Buffer contains these bytes
int 21h

RET
drawlevel3 endp


;===LEVEL1 DRAw======

drawlevel1 proc

mov ah, 06h
mov al, 0
mov ch, 1    ;upper row
mov cl,2      ;leftcol
mov dh, 17    ;lower row
mov dl, 77    ;rightcol
mov bh, 1Fh
int 10h

;===PATTERN====
mov ah, 06h
mov al, 0
mov ch, 1    ;upper row
mov cl,4      ;leftcol
mov dh, 17    ;lower row
mov dl, 5     ;rightcol
mov bh, 3Fh
int 10h

mov ah, 06h
mov al, 0
mov ch, 1    ;upper row
mov cl,74      ;leftcol
mov dh, 17    ;lower row
mov dl, 75     ;rightcol
mov bh, 3Fh
int 10h

;====BASKET LEFT END=====
mov dh,bas1row
mov dl,bas1col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,200
int 21h


;=====BASKET MIDDLE====

mov dh,bas2row
mov dl,bas2col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,205
int 21h

mov dh,bas3row
mov dl,bas3col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,209
int 21h

mov dh,bas4row
mov dl,bas4col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,205
int 21h


;=====BASKET RIGHT END====

mov dh,bas5row
mov dl,bas5col
mov bh,0
mov ah,2
int 10h

mov ah,02
mov dl,188
int 21h

mov dh,randrow
mov dl,BYTE PTR randcol
mov bh,0
mov ah,2
int 10h

mov ah,40h			;Display Function
mov bx,1			;Console
mov cx,1			; 10 bytes to display
mov dx,offset buffer		;Buffer contains these bytes
int 21h

RET
drawlevel1 endp

end main