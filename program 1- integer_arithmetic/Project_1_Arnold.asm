TITLE A Simple Calculator     (Program_1.asm)

; Author: Keisha Arnold
; Email: arnoldke@oregonstate.edu
; Course / Project ID: CS 271-400 / A Simple Calculator              Due Date: October 9, 2016
; Description: This program will introduce the program, get two numbers from the user,
;    calculate the sum, difference, product, quotient and remainder of the numbers,
;    and report the result.

INCLUDE Irvine32.inc

; (insert constant definitions here)

.data
;string variables
intro_1   BYTE "A Simple Calculator     by Keisha Arnold", 0
intro_2   BYTE "I'm here to calculate the sum, difference, product, ", 0dh, 0ah
          BYTE "quotient and remainder of two numbers.", 0
prompt_1  BYTE "Please enter your first number: ", 0
prompt_2  BYTE "Please enter your second number: ", 0
prompt_3  BYTE "The second number must be less than the first!", 0
keepLoop    BYTE "Do you want to repeat (1- yes or 2- no)?", 0

;integer variables
num_1     DWORD     ?    ;user entered number 1
num_2     DWORD     ?    ;user entered number 2
sum       DWORD     ?
diff      DWORD     ?
prod      DWORD     ?
quot      DWORD     ?
rem       DWORD     ?
choice    BYTE      ?    ;user entered choice 

;results
results   BYTE "Here are your results... ", 0
resultSum      BYTE "Sum: ", 0
resultDiff     BYTE "Difference: ", 0
resultProd     BYTE "Product: ", 0
resultQuot     BYTE "Quotient: ", 0
resultRem      BYTE "Remainder: ", 0
goodbye   BYTE "Goodbye!", 0

;EC Options
ec_1      BYTE "**EC: Repeat until the user chooses to quit.", 0
ec_2      BYTE "**EC: Program verifies second number is less than the first.", 0


.code
main PROC
;Introduce the program name and author
     mov       edx, OFFSET intro_1
     call WriteString
     call CrLf

;Print EC statements
     mov       edx, OFFSET ec_1
     call      WriteString
     call      CrLf
     mov       edx, OFFSET ec_2
     call WriteString
     call CrLf
     call CrLf

;Display instructions for the user
     mov       edx, OFFSET intro_2
     call WriteString
     call CrLf

;Display error second num not < first
error:
     mov       edx, OFFSET prompt_3
     call WriteString
     call CrLf
     jmp       getNum1

;Prompt the user to enter two numbers
getNum1:
     mov       edx, OFFSET prompt_1
     call WriteString
     call ReadInt
     mov       num_1, eax

getNum2:
     mov       edx, OFFSET prompt_2
     call WriteString
     call ReadInt
     mov       num_2, eax

;EC 2 ** validate input- verifies second number less than first
valInput:
     mov       eax, num_1
     cmp       eax, num_2
     jle       error
     ;mov      num_1, eax

;Calculate the sum
     mov       eax, num_1
     add       eax, num_2
     mov       sum, eax

;Calculate the difference
     mov       eax, num_1
     sub       eax, num_2
     mov       diff, eax

;Calculate the product
     mov       eax, num_1
     mov       ebx, num_2
     mul       ebx
     mov       prod, eax

;Calculate the quotient and remainder
     mov       eax, num_1
     cdq
     mov       ebx, num_2
     div       ebx
     mov       quot, eax
     mov       rem, edx

;Display the results
     mov       edx, OFFSET results
     call WriteString
     call CrLf
     
     mov       edx, OFFSET resultSum
     call WriteString
     mov       eax, sum
     call WriteDec
     call CrLf
     
     mov       edx, OFFSET resultDiff
     call WriteString
     mov       eax, diff
     call WriteDec
     call CrLf
     
     mov       edx, OFFSET resultProd
     call WriteString
     mov       eax, prod
     call WriteDec
     call CrLf
    
     mov       edx, OFFSET resultQuot
     call WriteString
     mov       eax, quot
     call WriteDec
     call CrLf
     
     mov       edx, OFFSET resultRem
     call WriteString
     mov       eax, rem
     call WriteDec
     call CrLf
    
;EC 1 ** Repeat until the user chooses to quit
;Display options to user
     mov       edx, OFFSET keepLoop
     call      WriteString

;If user enters 1-Yes, keep looping
     call      ReadChar
     mov       choice, al
     call      CrLf
     cmp       choice, '1'
     je        getNum1

;Display a terminating message
     mov       edx, OFFSET goodbye
     call WriteString
     call CrLf

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
