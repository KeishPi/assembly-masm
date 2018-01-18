TITLE Sorting Random Integers    (Project5_Arnold.asm)

; Author: Keisha Arnold
; Email: arnoldke@oregonstate.edu
; Course / Project ID: CS 271-400 / Sorting Random Integers       Due Date: November 20, 2016
; Description: This program generates random numbers in the range [100 ... 999],
;    displays the original list, sorts the list, and calculates the median value.
;    Finally, it displays the list sorted in descending order. 
 

INCLUDE Irvine32.inc

; (insert constant definitions here)
; term range
MIN = 10            ;number of random integers
MAX = 200
LO = 100            ;range of random numbers
HI = 999

.data
; string variables
intro_program  BYTE "Sorting Random Integers       by Keisha Arnold", 0
display_intro  BYTE "This program generates random numbers in the range [100 ...999], ", 0dh, 0ah
               BYTE "displays the original list, sorts the list, and calculates the ", 0dh, 0ah
               BYTE "median value. Finally, it displays the list sorted in descending order.", 0
prompt_num     BYTE "How many numbers should be generated? [10 ... 200]: ", 0
prompt_error   BYTE "Invalid input. ", 0
display_uns    BYTE "The unsorted random numbers: ", 0
display_sort   BYTE "The sorted list: ", 0
display_med    BYTE "The median is ", 0
goodbye        BYTE "Goodbye! ", 0

; integer variables
request        DWORD      ?             ; number of random integers requested by user
array          DWORD      MAX DUP(?)    ; array of integers
    
; EC Options
;ec_1      BYTE "**EC: Display the numbers ordered by column instead of by row.", 0
;ec_2      BYTE "**EC: Use a recursive sorting algorithm (e.g. Merge Sort, Quick Sort, Heap Sort, etc.)", 0
;ec_3      BYTE "**EC: Implement the program using floating-point numbers and the floating-point processor.", 0
;ec_4      BYTE "**EC: Generate the numbers into a file, then read the file into the array."

.code
main PROC
     call Randomize           ;seed the random integer generator

     call intro               ;intro and programmer's name

     ;call printEc

     push OFFSET request
     call getData             ;get the user's number and validate it

     
     push OFFSET array
     push request
     call fillArray           ;fills an array with random integers [100 ... 999]

     push OFFSET array
     push request
     push OFFSET display_uns
     call printArray          ;prints unsorted list     

     push OFFSET array
     push request   
     call sortList            ;sorts the array in descending order

     push OFFSET array
     push request   
     push OFFSET display_med
     call median              ;finds and displays the median value

     push OFFSET array
     push request
     push OFFSET display_sort
     call printArray          ;prints sorted list
     
     push OFFSET goodbye      ;displays parting message
     call partingMsg

     exit                     ; exit to operating system
main ENDP

; ****************************************************************
; Procedure to introduce the program, author, and introduction
; receives: none
; returns: none
; preconditions: none
; registers changed: edx
; ****************************************************************
intro     PROC
; Introduce the program name/author
     push ebp
     mov  ebp, esp
     mov  edx, OFFSET intro_program
     call WriteString
     call CrLf
     
; Display introduction
     mov  edx, OFFSET display_intro
     call WriteString
     call CrLf
     call CrLf
    
     pop ebp
     ret
intro     ENDP

; ***************************************************************
; Procedure to print the EC statements
; receives: none
; returns: none
; preconditions: none
; registers changed; edx
; ***************************************************************
printEc   PROC
;Print EC statements
     ;mov edx, OFFSET ec_1
     ;call WriteString
     ;call CrLf
     ;mov edx, OFFSET ec_3
     ;call WriteString
     ;call CrLf
     ;mov edx, OFFSET Note
     ;call WriteString
     ;call CrLf
     ;call CrLf

     ret
printEc   ENDP

; **************************************************************
; Procedure to get user's input.
; receives: address of request on system stack
; returns: user input in global request
; preconditions: none
; registers changed: eax, ebx, edx
; **************************************************************
getData     PROC
     push ebp
     mov  ebp, esp
getNum:
     mov  edx, OFFSET prompt_num   
     call WriteString              ;prompt user
     call ReadInt                  ;get user's number
validate:
     cmp  eax, MIN                 ;compare < 10
     jl   error
     cmp  eax, MAX                 ;compare > 200
     jg   error
     jmp  valid
error:
     mov  edx, OFFSET prompt_error
     call WriteString
     call CrLf
     jmp  getNum
valid:          
     mov  ebx, [ebp + 8]           ;address of request in ebx
     mov  [ebx], eax               ;store in global variable
     call CrLf
     
     pop  ebp
     ret  4
getData   ENDP

; ****************************************************************
; Procedure to fill array with random integers
; receives: address of the array and value of request on the
;    system stack.
; returns: first request elements of array contain random
;    integers [100 ... 999].
; preconditions: request is initialized, 10 <= request <= 200
; registers changed: eax, ebx, ecx, edi
; *****************************************************************
fillArray  PROC
     push ebp
     mov  ebp, esp
     mov  ecx, [ebp + 8]      ;request in ecx (as counter)
     mov  edi, [ebp + 12]     ;address of array in edi

     mov  ebx, 0
fillLoop:
;calculate random integer
     mov  eax, ebx            ;get random integer and store in consecutive array elements
     mov  eax, HI             ;999
     sub  eax, LO             ;999 - 100 = 899
     inc  eax                 ;900
     call RandomRange         ;result in eax is [0 ... 899]
     add  eax, LO             ;result in eax is [100 ... 999]
;store in array
     mov  [edi], eax
     add  edi, TYPE array
     inc  ebx
     loop fillLoop

     pop  ebp
     ret  8
fillArray ENDP

; ******************************************************************
; Procedure to display array
; receives: address of array, value of request, and address of title
;    (display_uns or display_sort) on system stack
; returns: first request elements of array contain integers 
;    (sorted or unsorted)
; preconditions: request is intialized, 10 <= request <= 200
;    and the first request elements of array initialized
; registers changed: eax, ebx, edx, esi
; ******************************************************************
printArray  PROC
     push ebp
     mov  ebp, esp
     mov  edx, [ebp + 8]           ;title in edx
     call WriteString
     call CrLf
     mov  ecx, [ebp + 12]          ;request in ecx (as loop counter)
     mov  esi, [ebp + 16]          ;address of array in esi
     mov  ebx, 0                   ;edx is element counter
printLoop:
     inc  ebx
     mov  eax, [esi]               ;get current element
     call WriteDec
     add  esi, 4                   ;move to next element
     cmp  ebx, 10                  ;10 elements per line
     jne  noNewline
     call CrLf
     mov  ebx, 0
     jmp  done

noNewline:
     mov  al, 9                    ;put a tab between numbers
     call WriteChar
done:
     loop printLoop
     call CrLf

     pop  ebp     
     ret  12
printArray ENDP

; *****************************************************************
; Procedure to sort values in the array in descending order
; receives: address of array and value of request on system stack.
; returns: first request elements of array are sorted
; preconditions: request is intialized, 10 <= request <= 200
;    and the first request elements of array initialized
; registers changed: eax, ebx, edx, esi
; *****************************************************************
sortList  PROC
     push ebp                      ;set up stack
     ;pushad
     mov  ebp, esp
     mov  ecx, [ebp + 8]           ;request in ecx (as loop counter)
     mov  edi, [ebp + 12]          ;address of array in edi
     dec  ecx                      ;request-1
     mov  ebx, 0
outerLoop:
     mov  eax, ebx                 ;i=k
     mov  edx, eax                 ;set up inner loop
     inc  edx                      ;j = k + 1
     push ecx                      ;preserve outer loop counter
     mov  ecx, [ebp + 8]           ;original value of request in ecx    
innerLoop:
     mov  esi, [edi + edx * 4]     ;point to first element
     cmp  esi, [edi + eax * 4]     ;compare first element to the next element
     jle  lessThan                  
     mov  eax, edx
lessThan:                          ;skip if greater (don't need to swap elements)
     inc  edx
     loop innerLoop
;greaterThan:
     lea  esi, [edi + ebx * 4]     ;assign address of current element to esi
     push esi
     lea  esi, [edi + eax * 4]     ;assign address of current element to esi
     push esi
     call exchange

     pop  ecx
     inc  ebx
     loop outerLoop
     
     pop  ebp
     ;popad
     ret  8
sortList ENDP

; ********************************************************************
; Procedure to swap two elements 
; receives: address of array[i] and address of array[j] on the stack.
; returns: values in array[i] and array[j] are swapped
; preconditions: elements of array initialized
; registers changed: esi, eax, ebx
; ********************************************************************
exchange  PROC
     pushad
     ;push ebp
     mov  ebp, esp
     mov  eax, [ebp + 40]
     mov  ecx, [eax]
     mov  ebx, [ebp + 36]
     mov  edx, [ebx]
     ;xchg ecx, edx
     mov  [eax], edx
     mov  [ebx], ecx
     
     ;pop ebp
     popad
     ret 8
exchange ENDP

; ****************************************************************
; Procedure to find and display the median value
; receives: address of array, value of request and address of the
     title ("The median is ") on system stack.
; returns: the median value of the array
; preconditions: request is intialized, 10 <= request <= 200
;    and the first request elements of array is sorted
; registers changed: eax, ebx, edx, esi
; ****************************************************************
median  PROC
     push ebp
     mov  ebp, esp
     mov  edx, [ebp + 8]           ;title in edx
     call WriteString              ;print title
     mov  eax, [ebp + 12]          ;request in eax 
     mov  esi, [ebp + 16]          ;address of array in edi
findMedian:
     cdq  
     mov  ebx, 2
     div  ebx                      ;divide request by 2
     cmp  edx, 0                   ;quotient in eax, rem in edx
     mov  ecx, eax                 ;move quotient into ecx
     je   isEven
;isOdd:
     mov  eax, [esi + 4 * ecx]      ;esi= pointer to the array, 4= element size, ecx= element index        
     call WriteDec                  
     call CrLf
     call CrLf
     jmp  done
isEven:
     dec ecx                       ;since array is 0 indexed dec 1
     mov eax, [esi + 4 * ecx]      ;esi= pointer to the array, 4= element size, ecx= element index 
     inc ecx
     add eax, [esi + 4 * ecx]      ;next element
     cdq  
     mov  ebx, 2
     div  ebx                      ;get average of middle two elements
     ;add  edx, edx                ;dont need to do this, bc decimal will always be .5
     ;cmp  edx, ecx
     ;jle  printAvg
     ;dec eax
;printAvg:
     call WriteDec
     call CrLf
     call CrLf
done:
     pop ebp
     ret 12
median ENDP

; ******************************************************************
; Procedure to display parting message
; receives: none
; returns: none
; preconditions: none
; registers changed: edx
; ******************************************************************
partingMsg     PROC
     push ebp
     mov  ebp, esp
     mov  edx, [ebp + 8]
     call WriteString
     call CrLf
     
     pop ebp
     ret  4
partingMsg     ENDP

END main
