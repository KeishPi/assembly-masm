TITLE Designing low-level I/O procedures    (Project6_Arnold.asm)

; Author: Keisha Arnold
; Email: arnoldke@oregonstate.edu
; Course / Project ID: CS 271-400 / Designing low-level I/O procedures       Due Date: December 4, 2016
; Description: This program prompts the user to enter 10 unsigned decimal integers,
;    validates each number fits in a 32 bit register, then displays a list of the integers,
;    their sum, and their average. 
 

INCLUDE Irvine32.inc

; (insert constant definitions here)
NUM_INTS = 10            ;number of unsigned integers user needs to input


; ********************************************************************
; Macro to display the string stored in a specified memory location.
; receives: address of string 
; returns: none
; preconditions: none
; registers changed: edx
; ********************************************************************
displayString MACRO string
     push edx                      ;preserve edx
     mov  edx, OFFSET string
     call WriteString

     pop  edx                      ;restore edx           
ENDM

; ********************************************************************
; Macro to display a prompt, then get the user's keyboard input into
;    a memory location.
; receives: address of string (prompt), num (read as a string)
; returns: none
; preconditions: none
; registers changed: none
; ********************************************************************
getString MACRO prompt, userInput, numBytes
     pushad
     displayString prompt
     ;mov  eax, elementIndex
     ;call WriteDec
     ;mov  al, ':'
     ;call WriteChar
     mov  edx, userInput
     mov  ecx, numBytes
     call ReadString
   
     popad
ENDM


.data
; string variables
intro_program  BYTE "PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures", 0dh, 0ah       
               BYTE "Written by: Keisha Arnold", 0
display_intro  BYTE "Please provide 10 unsigned decimal integers.", 0dh, 0ah
               BYTE "Each number needs to be small enough to fit inside a 32 bit register.", 0dh, 0ah
               BYTE "After you have finished inputting the raw numbers I will display a list ", 0dh, 0ah
               BYTE "of the integers, their sum, and their average value.", 0
prompt_num     BYTE "Please enter an unsigned number: ", 0
prompt_error   BYTE "ERROR: You did not enter an unsigned number or your number was too big. ", 0dh, 0ah, 0
               ;BYTE "Please try again: ", 0
display_list   BYTE "You entered the following numbers: ", 0
display_sum    BYTE "The sum of these numbers is: ", 0
display_avg    BYTE "The average is: ", 0
display_subt   BYTE "Your running subtotal is: ", 0
goodbye        BYTE "Thanks for playing! ", 0

; integer variables
input_buffer   BYTE      200 DUP(0)
string_array   BYTE      20 DUP(?)   
array          DWORD     NUM_INTS DUP(?)    ; array of integers
num_bytes      DWORD     0  
;uns_int        DWORD     ?
;loop_count     DWORD     0
sum            DWORD     0
avg            DWORD     ?
subtotal       DWORD     ?
   
; EC Options
;ec_1      BYTE "**EC: Number each line of user input and display a running subtotal of the user's numbers.", 0
;ec_2      BYTE "**EC: Handle signed integers.", 0
;ec_3      BYTE "**EC: Make your readVal and writeVal procedures recursive.", 0
;ec_4      BYTE "**EC: Generate the numbers into a file, then read the file into the array."

.code
main PROC
     displayString  intro_program   ;display intro and programmer's name
     call CrLf
     call CrLf
     displayString  display_intro
     call CrLf
     call CrLf                   
     
     mov  edi, OFFSET array
     mov  ecx, NUM_INTS
     ;mov  eax, 1                  ;line numbers

     getInput:                     ;get user input, convert string to numeric, validate user input
          ;call WriteDec
          ;displayString  prompt_num
          push OFFSET input_buffer
          push LENGTHOF input_buffer
          call readVal

          mov  ebx, DWORD PTR input_buffer   ;go to next number in array
          mov  [edi], ebx
          add  edi, 4
          ;inc  eax
          loop getInput
     call CrLf

     displayString display_list    ;display string "You entered the following numbers: "
     call CrLf
       
     mov  esi, OFFSET array
     mov  ecx, NUM_INTS
     xor  ebx, ebx
     
     addSum:
          mov  eax, [esi]
          add  ebx, eax
          push OFFSET string_array      ;display array of numbers
          push eax
          call WriteVal
          cmp  ecx, 1                   ;we're at the end so don't write a comma!
          je   finish
          mov  al, ','
          call WriteChar
          add  esi, 4                   ;go to next number
     loop addSum                        ;loop accumulates the sum
     
     finish:
          call CrLf
          mov  eax, ebx
          mov  sum, eax
     
     displayString display_sum     ;display string "The sum of these numbers is: "
     
     push OFFSET string_array
     push sum 
     call writeVal                 ;display sum
     call CrLf

     displayString  display_avg    ;display string "The average is: "

     mov  ebx, NUM_INTS
     xor  edx, edx

     div  ebx                      ;divide sum/10 (NUM_INTS)
     mov  avg, eax                 ;save quotient to avg, always round down so just take the quotient

     push OFFSET string_array
     push avg                          
     call WriteVal                 ;display average
     call CrLf
     call CrLf

     displayString  goodbye        ;say goodbye
     call CrLf

     exit                          ;exit to operating system
main ENDP

; ****************************************************************
; Procedure to display the program, author, and introduction
; receives: none
; returns: none
; preconditions: none
; registers changed: edx (by macro displayString)
; ****************************************************************
intro     PROC
     push ebp
     mov  ebp, esp
     
     pop ebp
     ret  8
intro     ENDP

; ********************************************************************
; Procedure to get user's input as a string of digits by invoking
;    the getString macro, the converts the digit string to numeric,
;    while validating the user's input.
; receives: address of the array and length of array on system stack.
; returns: none
; preconditions: none
; registers changed: none
; ********************************************************************
readVal     PROC
     push ebp
     mov ebp, esp
     pushad

     loopStart:
     mov  edx, [ebp + 12]     ;address of input_buffer
     mov  ecx, [ebp + 8]      ;LENGTHOF input_buffer to ecx

     getString prompt_num, edx, ecx     ;get the input
     
     mov  esi, edx            ;prepare for lodsb
     xor  eax, eax
     xor  ecx, ecx
     mov  ebx, 10

     loadString:
     lodsb                    ;load esi into al
     cmp  ax, 0
     je   done

     validate:           ;validate input is a number in ASCII
     cmp  ax, 48
     jl   error
     cmp  ax, 57
     jg   error

     sub  ax, 48         ;convert to integer
     xchg eax, ecx
     mul  ebx
     jc   error          ;if carry flag is set, display error
     jnc  isValid

     error:
     displayString prompt_error
     jmp  loopStart

     isValid:
     add  eax, ecx
     xchg eax, ecx
     jmp  loadString

     done:
     xchg ecx, eax
     mov  DWORD PTR input_buffer, eax
     
     popad
     pop ebp
     ret  8
readVal   ENDP

; ****************************************************************
; Procedure to convert a numeric value to a string of digits, and
;    invoke the displayString macro to produce the output.
; receives: address of the array and value of global constant 
;    NUM_INTS on system stack
; returns: displays elements of array as a string
; preconditions: NUM_INTS is initialized
; registers changed: none
; *****************************************************************
writeVal  PROC
     push ebp
     mov  ebp, esp
     pushad

     mov  edi, [ebp + 12]     ;address of array to edi
     mov  eax, [ebp + 8]      ;NUM_INTS to eax
     mov  ebx, 10
     push 0

     convertToString:
     xor  edx, edx
     div  ebx
     add  edx, 48
     push edx

     cmp eax, 0
     jne convertToString

     popStack:
     pop  [edi]
     mov  eax, [edi]
     inc  edi
     cmp  eax, 0
     jne  popStack
     
     mov  edx, [ebp + 8]
     displayString  OFFSET string_array
     printString:
     ;cmp  edx, 0
     ;je   done
     ;mov  al, ','
     ;call WriteChar

     done:
     popad
     pop  ebp
     ret  8
writeVal ENDP

; ****************************************************************
; Procedure to sum integers in an array
; receives: address of the array value of NUM_INT and value of 
;    sum on the system stack.
; returns: sum of integers in a array in the variable sum.
; preconditions: array is initialized
; registers changed: eax, ebx, ecx, edi
; *****************************************************************
calcSum   PROC
     push ebp
     mov  ebp, esp
     pushad

     popad
     mov  esp, ebp
     pop  ebp
     ret 16
calcSum   ENDP

END main
