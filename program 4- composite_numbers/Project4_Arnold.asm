TITLE Composite Numbers     (Project4_Arnold.asm)

; Author: Keisha Arnold
; Email: arnoldke@oregonstate.edu
; Course / Project ID: CS 271-400 / Composite Numbers       Due Date: November 6, 2016
; Description: This program will prompt the user to enter the number of composites they would 
;    like displayed [1, 400], validate user input, then calculate and display the number of 
;    composites up to and including the nth composite. 

INCLUDE Irvine32.inc

; (insert constant definitions here)
; term range
LOWER_LIMIT = 1
UPPER_LIMIT = 400

.data
; string variables
intro_program  BYTE "Composite Numbers       by Keisha Arnold", 0
display_intro  BYTE "How many composite numbers you would like to see? ", 0dh, 0ah
               BYTE "I'll accept orders for up to 400 composites.", 0
prompt_num     BYTE "Enter the number of composites to display [1 ... 400]: ", 0
prompt_error   BYTE "Out of range. Try again. ", 0
goodbye        BYTE "Goodbye! ", 0

; integer variables
num_comp       DWORD      ?             ; number of composites reqested by user
listInts       DWORD      600 DUP(?)
checkComp      DWORD      4             ; composite numbers start at 4
    
; EC Options
ec_1      BYTE "**EC: Align the output columns.", 0
;ec_2      BYTE "**EC: Show composites one page at a time. The user can 'Press any key to continue...'", 0dh, 0ah
;          BYTE "to view the next page. ", 0
ec_3      BYTE "**EC: Make the program more efficient by checking against only prime divisors, ", 0dh, 0ah
          BYTE "which requires saving all of the primes found so far (numbers that fail ", 0dh, 0ah
          BYTE "the composite test).", 0
Note      BYTE "Note: For EC 3, I first implemented the Sieves of Eratosthenes algorithm to ", 0dh, 0ah
          BYTE "calculate all prime numbers and saved the numbers in an array. Then I checked ", 0dh, 0ah
          BYTE "integers against the prime array to determine if it was composite.", 0

; Note to self: It would have been easier to have the listInts array save the composite numbers rather than 
; the primes so the ShowComposites function would only need to print the number of composites the user 
; requested rather than comparing them to the prime numbers, but it was implemented this way to fulfill EC3. 
; Or perhaps have a single array with consecutive itegers and each integer contains a boolean value if it's prime
; or composite? Either way, it was neat to see how the Sieves algorithm was implemented. 
; Reference: https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes 

.code
main PROC
     call intro
     call printEc
     call getData
          ; call validate
     call fillArray      ; fills an array with consecutive integers 2 - n
     ;call printArray    ; check that the array filled correctly
     call calcPrimes     ; takes an array of consecutive ints and determines which are prime
     ;call printArray    ; check that Primes were calculated correctly
     call showComposites
          ; call isComposite
     call partingMsg

     exit                ; exit to operating system
main ENDP

; *****Procedure to introduce the program, author, and intro*****
; receives: none
; returns: none
; preconditions: none
; registers changed: edx
intro     PROC

; Introduce the program name/author
     mov  edx, OFFSET intro_program
     call WriteString
     call CrLf
; Display introduction
     mov  edx, OFFSET display_intro
     call WriteString
     call CrLf
     call CrLf

     ret
intro     ENDP

; *****Procedure to print the EC statements*****
; receives: none
; returns: none
; preconditions: none
; registers changed; edx
printEc   PROC

;Print EC statements
     mov edx, OFFSET ec_1
     call WriteString
     call CrLf
     mov edx, OFFSET ec_3
     call WriteString
     call CrLf
     mov edx, OFFSET Note
     call WriteString
     call CrLf
     call CrLf

     ret
printEc   ENDP

; *****Procedure to get value num_comp from the user*****
; receives: none
; returns: user input values for global variable num_comp
; preconditions: none
; registers changed: eax, edx
getData     PROC

; Get user number
     mov  edx, OFFSET prompt_num
     call WriteString
     call ReadInt
     mov  num_comp, eax
     call validate

     ret
getData   ENDP

; *****Procedure to validate value in num_comp*****
; receives: num_comp is a global variable, UPPER_LIMIT and LOWER_LIMIT are constants
; returns: none
; preconditions: num_comp is initialized
; registers changed: edx
validate  PROC

; Validate user input- lower limit (1)
     cmp  num_comp, LOWER_LIMIT   ; if < 1 display error, ask again
     jl   error

; Validate user input- upper limit (400)
     cmp  num_comp, UPPER_LIMIT   ; if > 400 keep asking for integers
     ja   error
     ;jmp calculate
     ret

; Display error message if needed (out of range)
error:
     mov  edx, OFFSET prompt_error
     call WriteString
     call CrLf
     call  getData
   
     ;ret
validate  ENDP

; *****Procedure to fill array with integers*****
; receives: listInts is a global variable
; returns: global variable listInts initialized with consecutive integers 2-n
; preconditions: none
; registers changed: edi, ecx, eax
fillArray  PROC
     ;xor ecx, ecx        ; zero the counter
     mov edi, OFFSET listInts      ; edi = address of listInts
     mov ecx, LENGTHOF listInts    ; initialize loop counter
     mov eax, 2                    ; Sieve of Eratothenes is from 2 to n

fillLoop:
     mov [edi], eax                ; move the integer into the array address   
     inc eax                       ; increment the integer
     add edi, TYPE listInts        ; point to next element
     loop fillLoop                 ; repeat until ecx = 0

     ret
fillArray ENDP

; *****Procedure to print array*****
; receives: listInts is a global variable
; returns: none
; preconditions: listInts has been intialized with consecutive integers 2-n
; registers changed: esi, eax, ecx, al
printArray  PROC
     mov esi, OFFSET listInts
     xor ecx, ecx                  ; zero the counter
     
printLoop:
     xor eax, eax                  ; zero eax
     mov eax, [esi + 4 * ecx]      ; esi= pointer to the array, 4= element size, ecx= element index 
     call WriteDec
     mov al, 9
     call WriteChar
     ;call CrLf
     inc ecx                       ; increment counter
     cmp ecx, LENGTHOF listInts    ; are we at end of array?
     jne   printLoop
     ;call CrLf
     
     ret
printArray ENDP

; *****Procedure to check for prime numbers*****
; receives: listInts is a global variable
; returns: listInts containing only prime numbers (0's for composites)
; preconditions: listInts initialized to consecutive integers 2-n
; registers changed: ecx, ebx
calcPrimes  PROC
     xor ecx, ecx                  ; zero the counter
outerLoop:
     mov ebx, ecx                  ; move counter value into ebx (we will use ebx as innerloop counter)
     cmp [listInts + 4 * ecx], 0   ; is element at array index[counter] == 0 (not prime)?
     jne innerLoop                 ; if it's prime go to innerloop
     
     keepLooping1:
     inc ecx                       ; increment counter
     cmp ecx, LENGTHOF listInts    ; are we at end of array?
     jb   outerLoop                ; if not, go back to beginning of outerLoop
     
     ret

innerLoop:
     add ebx, [listInts + 4 * ecx]      ; add the value contained at array index to ebx counter
     mov [listInts + 4 * ebx], 0        ; number is not prime so set to 0
     cmp ebx, LENGTHOF listInts         ; are we at end of array?
     jb innerLoop 
     jmp keepLooping1

     ret
calcPrimes ENDP

; *****Procedure to determine composite numbers*****
; receives: listInts and checkComp are global variables
; returns: the next composite number
; preconditions: listInts contains only prime numbers (0's for composites)
; registers changed: eax, esi, ebx
isComposite PROC
compare:
     mov eax, [esi + 4 * ebx]      ; esi= pointer to the array, 4= element size, ecx= element index
     cmp eax, 0
     jnz skipPrime
     ret

skipPrime:
     inc ebx
     cmp ebx, LENGTHOF listInts    ; are we at the end of the array?
     jb compare

isComposite ENDP

; *****Procedure to display composite numbers*****
; receives: listInts and num_comp are global variables
; returns: none
; preconditions: listInts contains prime numbers, num_comp initialized
; registers changed: eax, ebx, ecx, edx, esi, al, 
showComposites  PROC
     mov esi, OFFSET listInts
     xor ecx, ecx        ; zero ecx and ebx registers
     xor ebx, ebx
printComp:
     call isComposite
     mov eax, ebx
     add eax, 2          ; the value at array index (ebx) is ebx + 2
     call WriteDec
     mov al, 9           ; tab over
     call WriteChar
     
     push ebx            ; save ebx
     push eax            ; save eax

     formatting:         ; 10 numbers per line
     inc ecx             ; need to increment because 0/10 = 0
     mov eax, ecx
     cdq
     mov ebx, 10
     div ebx
     cmp edx, 0
     jne noNewline
     call CrLf
     noNewline:

     dec ecx             ; decrement back to original
     pop eax             ; call back the saved eax
     pop ebx             ; call back the saved ebx
     inc ebx             ; increment counter (array index)
     inc ecx             ; increment counter (to num_comp)
     cmp ecx, num_comp   ; are we at num of comps?
     jl   printComp

     ret
showComposites ENDP

; *****Procedure to display parting message*****
; receives: none
; returns: none
; preconditions: none
; registers changed: edx
partingMsg     PROC
     call CrLf
     mov  edx, OFFSET goodbye
     call WriteString
     call CrLf

     ret
partingMsg     ENDP

END main
