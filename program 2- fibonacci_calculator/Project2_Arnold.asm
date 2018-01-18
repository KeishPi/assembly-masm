TITLE Fibonacci Numbers     (Project2_Arnold.asm)

; Author: Keisha Arnold
; Email: arnoldke@oregonstate.edu
; Course / Project ID: CS 271-400 / Fibonacci Numbers       Due Date: October 16, 2016
; Description: This program will get the users name, greet the user, prompt the user to enter
;    the number of Fibonacci terms to display (1- 46), validate user input, and calculate and
;    display the Fibonacci numbers. 

INCLUDE Irvine32.inc

; (insert constant definitions here)
; term range
LOWER_LIMIT = 1
UPPER_LIMIT = 46

.data
; string variables
intro_program  BYTE "Fibonacci Numbers       by Keisha Arnold", 0
ask_name       BYTE "Hi! What's your name?", 0
user_name      BYTE 33 DUP(0)      ; string to be entered by the user
greet_user     BYTE "Hello, ", 0
prompt_instr   BYTE "Enter the number of Fibonacci terms to be displayed", 0
prompt_range   BYTE "Give the number as an integer in the range [1 .. 46].", 0
prompt_terms   BYTE "How many Fibonacci terms do you want? ", 0
prompt_error   BYTE "Out of range. Enter a number between [1 .. 46]", 0
goodbye        BYTE "Goodbye, ", 0

; integer variables
num_terms      DWORD     ?    ; number of terms entered by the user

; Fibonacci term variables
current   DWORD     ?
previous  DWORD     ?

;EC Options
ec_1      BYTE "**EC: Display the numbers in aligned columns.", 0
;ec_2      BYTE "**EC: Do something incredible.", 0


.code
main PROC
; Introduce the program name and author
     mov       edx, OFFSET intro_program
     call WriteString
     call CrLf

;Print EC statements
     mov       edx, OFFSET ec_1
     call      WriteString
     call      CrLf
     ;mov       edx, OFFSET ec_2
     ;call WriteString
     ;call CrLf
     call CrLf

; Get user's name
     mov       edx, OFFSET ask_name
     call WriteString
     call CrLf
     mov       edx, OFFSET user_name
     mov       ecx, 32
     call ReadString

; Greet the user
     mov       edx, OFFSET greet_user
     call WriteString
     mov       edx, OFFSET user_name
     call WriteString
     call CrLf
     ;jmp getNum

; Display instructions for the user
     mov       edx, OFFSET prompt_instr
     call WriteString
     call CrLf
     mov       edx, OFFSET prompt_range
     call WriteString
     call CrLf
     jmp getNum
     
; ***Data validation post-test loop***
; Display error message if needed
error:
     mov       edx, OFFSET prompt_error
     call WriteString
     call CrLf
     jmp getNum

; Get user number
getNum:
     mov       edx, OFFSET prompt_terms
     call WriteString
     call ReadDec
     mov       num_terms, eax

; Validate user input 
     cmp       num_terms, LOWER_LIMIT
     jb   error
     cmp       num_terms, UPPER_LIMIT
     ja   error

; ***End of validation loop***

; First two terms of Fibonacci sequence
     mov       current, 1
     mov       previous, 0    ; starts at 0 so first two terms will be 1

; ***Display terms loop***
; Initialize Loop counter
     mov       ecx, num_terms

printLoop:
     cmp       ecx, num_terms
     je        firstTwoTerms

; Calculate and display Fibonacci numbers
; printFib
     mov       eax, previous
     mov       ebx, current
     mov       previous, ebx       ;current term is now previous term
     add       eax, current        ;add current and previous terms
     mov       current, eax        ;current now holds the sum of previous two terms
     mov       eax, current
     call WriteDec
     jmp      formatting

; Print first two terms (1, 1)
firstTwoTerms:
     mov       eax, 1
     call WriteDec

formatting:
     mov       eax, num_terms
     mov       ebx, ecx
     dec       ebx
     sub       eax, ebx
     cmp       eax, 35
     ja        tabOver

     mov       al, 9     ; Tab is 9 in ASCII
     call WriteChar

tabOver:
     mov       al, 9
     call WriteChar

newline:
     mov       eax, num_terms
     mov       ebx, ecx
     dec       ebx
     sub       eax, ebx
     cdq                 ; extend the sign into edx
     mov       ebx, 5    ; 5 terms per line
     div       ebx       ; terms/5
     cmp       edx, 0    ; if there is no remainder
     jne  keepLooping

     call CrLf

keepLooping:
     loop printLoop

     call CrLf

; Goodbye
     mov       edx, OFFSET goodbye
     call WriteString
     mov       edx, OFFSET user_name
     call WriteString
     call CrLf

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
