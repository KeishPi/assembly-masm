TITLE Integer Accumulator     (Project3_Arnold.asm)

; Author: Keisha Arnold
; Email: arnoldke@oregonstate.edu
; Course / Project ID: CS 271-400 / Integer Accumulator       Due Date: October 30, 2016
; Description: This program will get the users name, greet the user, prompt the user to enter
;    negative integers they would like accumulated [-100, -1], validate user input, then calculate 
;    and display the number of negative numbers entered, the sum, the average rounded to the nearest
;    integer, and a parting message. 

INCLUDE Irvine32.inc

; (insert constant definitions here)
; term range
LOWER_LIMIT = -100
UPPER_LIMIT = -1

.data
; string variables
intro_program  BYTE "Integer Accumulator       by Keisha Arnold", 0
display_intro  BYTE "This program will ask you for a series of negative integers, ", 0dh, 0ah
               BYTE "then display the sum and rounded average of those integers.", 0
ask_name       BYTE "Hi! What's your name?", 0
user_name      BYTE 33 DUP(0)      ; string to be entered by the user
greet_user     BYTE "Hello, ", 0
prompt_instr   BYTE "Enter the numbers in [-100, -1].", 0
prompt_range   BYTE "Enter a non-negative number when you are finished to see the results.", 0
prompt_num     BYTE "Enter number: ", 0
prompt_error   BYTE "Out of range. Enter a number between [-100, -1]", 0
display_valid1 BYTE "You entered ", 0
display_valid2 BYTE " valid numbers.", 0
display_noNum  BYTE "There were no valid numbers entered.", 0
display_sum    BYTE "The sum of your valid numbers is ", 0
display_avg    BYTE "The rounded average is ", 0
goodbye        BYTE "Goodbye, ", 0

; integer variables
neg_int        SDWORD     ?    ; negative integer entered by the user
num_count      DWORD      1    ; number of neg integers entered by the user
accumulator    SDWORD     0    ; adds up the neg integers
sum            SDWORD     0    ; sum of valid neg integers
avg            SDWORD     ?    ; avg of valid neg integers

; EC Options
ec_1      BYTE "**EC: Number the lines during user input.", 0
;ec_2      BYTE "**EC: Calculate and display the average as a floating point number.", 0
;ec_3      BYTE "**EC: Do something astoundingly creative.", 0

.code
main PROC
; Introduce the program name and author
intro:
     mov  edx, OFFSET intro_program
     call WriteString
     call CrLf
     mov  edx, OFFSET display_intro
     call WriteString
     call CrLf
     call CrLf

;Print EC statements
     mov edx, OFFSET ec_1
     call WriteString
     call CrLf
     ;mov edx, OFFSET ec_2
     ;call WriteString
     ;call CrLf
     call CrLf

; Get user's name
getName:
     mov  edx, OFFSET ask_name
     call WriteString
     call CrLf
     mov  edx, OFFSET user_name
     mov  ecx, 32
     call ReadString

; Greet the user
greeting:
     mov  edx, OFFSET greet_user
     call WriteString
     mov  edx, OFFSET user_name
     call WriteString
     call CrLf
     ;jmp getNum

; Display instructions for the user
instructions:
     mov  edx, OFFSET prompt_instr
     call WriteString
     call CrLf
     mov  edx, OFFSET prompt_range
     call WriteString
     call CrLf
     jmp getNum
     
; ***Data validation loop***
; Display error message if needed (out of range)
error:
     mov  edx, OFFSET prompt_error
     call WriteString
     call CrLf
     jmp  getNum

; Get user number
getNum:
     mov  eax, num_count
     call WriteDec
     mov  al, 9               ; Tab is 9 in ASCII
     call WriteChar
     mov  edx, OFFSET prompt_num
     call WriteString
     call ReadInt
     mov  neg_int, eax

; Validate user input [-100, -1]
lowerLimit:
     cmp  neg_int, LOWER_LIMIT   ; if < -100 display error, ask again
     jl   error

upperLimit:
     test neg_int, UPPER_LIMIT   ; if signed and <= -1 keep asking for integers
     js   accum
     cmp  neg_int, UPPER_LIMIT   ; if not signed and > -1 get out of loop
     jns  printCount

; Count and accumulate valid numbers
accum: 
     add  sum, eax               ; add neg int to the accumulator (sum)
     inc  num_count
     loop getNum

; ***End of validation loop***

; Display number count
printCount:
     dec num_count                      ; subtract 1 from num_count because you started at 1
     cmp  num_count, 0                  ; if user didn't enter any neg #'s, display noNum message
     je   noNum
     mov  edx, OFFSET display_valid1    ; else display count of valid number's
     call WriteString
     mov  eax, num_count
     call WriteDec
     mov  edx, OFFSET display_valid2
     call WriteString
     call CrLf
     jmp  printSum

noNum:
     mov  edx, OFFSET display_noNum     ; no valid numbers entered, goodbye
     call WriteString
     call CrLf
     jmp  partingMsg

; Display sum
printSum:
     mov  edx, OFFSET display_sum
     call WriteString
     mov  eax, sum
     call WriteInt
     call CrLf

; Calculate average
calcAvg:
     mov  eax, sum
     cdq                      ; extend the sign into edx
     mov  ebx, num_count
     idiv ebx                 ; sum/num_count, quotient is in eax, rem is in edx

; Average rounded to the nearest integer
roundAvg:
     imul edx, -1        ; make the remainder positive
     add  edx, edx       
     cmp  edx, num_count
     jl   printAvg       ; if remainder < count, no rounding needed
     dec  eax            ; else, decrement the quotient

; Display average
printAvg:
     mov  edx, OFFSET display_avg
     call WriteString
     ;call CrLf
     mov  avg, eax
     mov  eax, avg
     call WriteInt
     call CrLf

; Parting message
partingMsg:
     mov  edx, OFFSET goodbye
     call WriteString
     mov  edx, OFFSET user_name
     call WriteString
     call CrLf

	exit	               ; exit to operating system
main ENDP

; (insert additional procedures here)

END main
