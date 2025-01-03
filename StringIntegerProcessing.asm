TITLE Project6                         (Proj6_singrajv.asm)

; Author: Rajveer Singh
; Last Modified: 06/09/2024
; OSU email address: singrajv@oregonstate.edu
; Course number/section: CS271 Section 400
; Project Number:   6              Due Date: 06/09/2024
; Description: This program collects 10 signed integers from the user, ensuring each input is valid and correctly converts it from a string to an integer. 
;              It stores these integers in an array, then displays the list of numbers, their total sum, and the truncated average. 
;              Macros are used for handling input and output, while procedures manage the conversion and validation processes

INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Reads user input in the form of a string of digits
;
; Preconditions: do not use eax, ecx, esi as arguments
;
; Postconditions: The registers EAX, ECX, and EDX are changed.
;
; Receives:
; promptMessage - Address of the prompt message to be displayed
; userBuffer - Address of the buffer to store the user input
; bytesRead - Variable to store the number of bytes read from user input
;
; returns: bytesRead - The number of bytes read from the user input
; ---------------------------------------------------------------------------------
mGetString MACRO promptMessage, userBuffer, bytesRead
    PUSH    ECX                                                   ; Save the current value of the ECX register, used as a counter, onto the stack
    PUSH    EDX

    MOV     EDX, promptMessage
    CALL    WriteString

    MOV     ECX, 50                                               ; Set the maximum input length to 50 characters
    MOV     EDX, userBuffer                                       ; Load the address of the buffer to store user input into EDX.
    CALL    ReadString
    MOV     bytesRead, EAX

    POP     EDX
    POP     ECX                                                   ; Restore the original value of the ECX register
ENDM

; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Displays a string message.
;
; Preconditions: do not use eax, ecx, esi as arguments
; 
; Postconditions: The EDX register is changed
;
; Receives:
; displayMessage - Address of the message to be displayed
;
; Returns: None 
; ---------------------------------------------------------------------------------

mDisplayString MACRO displayMessage
    PUSH    EDX

    MOV     EDX, displayMessage
    CALL    WriteString                                          ; Display the message using WriteString

    POP     EDX
ENDM

.data
NUM_COUNT        EQU  10                                         ; Define constant for the number of integers to be input by the user

programTitle     BYTE "PROGRAMMING ASSIGNMENT 6: Designing low-level I/O", 0Ah, 0
programAuthor    BYTE "Created by: Rajveer Singh", 0Ah, 0
instructions     BYTE "Enter 10 signed integers within 32-bit range.", 0Ah
                 BYTE "The program will display the numbers, their sum, and the average.", 0Ah, 0
inputPrompt      BYTE "Please input a signed integer: ", 0
errorMessage     BYTE "ERROR: Invalid input or number too large.", 0Ah, 0
enteredNumbers   BYTE "The numbers you entered are: ", 0Ah, 0
separator        BYTE ", ", 0
sumMessage       BYTE "Sum of the entered numbers: ", 0
avgMessage       BYTE "The truncated average is: ", 0
endMessage       BYTE "Thank you for using this unique program!", 0Ah, 0

userInputBuffer  BYTE 50 DUP(?)
outputBuffer     BYTE 50 DUP(?)
inputLength      DWORD ?
negativeFlag     DWORD ?
inputAttempts    DWORD ?
validNumber      DWORD ?
totalSum         DWORD ?
averageValue     DWORD ?
integerArray     DWORD NUM_COUNT DUP(?)                          ; Initialize array to store the valid integers input by the user, with a size of NUM_COUNT

.code

main PROC
    ; Display program introduction directly in main
    mDisplayString OFFSET programTitle
    mDisplayString OFFSET programAuthor
    CALL    CRLF
    mDisplayString OFFSET instructions                           ; Display the instructions for the user.
    CALL    CRLF

    ; Collect integers from the user
    MOV     EDI,   OFFSET integerArray                           ; Load the address of integerArray into the EDI register to use it as a pointer to hold user input
    MOV     ECX,   NUM_COUNT                                     ; ECX is used as loop counter that ensures that only 10 (NUM_COUNT) integers are gathered.

collect_input:
    PUSH    OFFSET outputBuffer                                  ; Push output buffer's address onto the stack, which ReadVal will utilize to hold the input's string representation.
    PUSH    negativeFlag
    PUSH    OFFSET errorMessage
    PUSH    inputAttempts
    PUSH    OFFSET validNumber
    PUSH    OFFSET inputPrompt
    PUSH    OFFSET userInputBuffer
    PUSH    inputLength
    CALL    ReadVal                                              ; Call ReadVal procedure to read and validate the user input.
    MOV     EAX, validNumber
    STOSD                                                        ; Store the value in the EAX register into the memory location pointed to by the EDI register
    LOOP    collect_input                                        ; Decrease ECX by 1 and repeat the loop if ECX is not zero, to ensure NUM_COUNT inputs are collected
    CALL    CRLF

    ; Display entered numbers
    MOV     ESI, OFFSET integerArray
    MOV     ECX, NUM_COUNT

    mDisplayString OFFSET enteredNumbers
display_numbers:
    PUSH    OFFSET outputBuffer
    PUSH    [ESI]                                                ; Push the current integer from the array onto the stack to be processed by WriteVal.
    CALL    WriteVal                                             ; Call WriteVal to convert the integer to a string and display it.
    mDisplayString OFFSET separator
    ADD     ESI, TYPE integerArray                               ; Increment ESI by the size of an integer to point to the next element in the array.
    LOOP    display_numbers
    CALL    CRLF

    ; Calculate and display sum
    MOV     ESI, OFFSET integerArray
    MOV     ECX, NUM_COUNT
    XOR     EAX, EAX                                             ; Clear the EAX register to initialize it as an accumulator for the sum.

calculate_sum:
    ADD     EAX, [ESI]                                           ; Add the integer at the address pointed to by ESI to the accumulator in EAX.
    ADD     ESI, TYPE integerArray
    LOOP    calculate_sum                                        ; Decrement ECX and repeat the loop if ECX is not zero, to sum all integers.
    MOV     totalSum, EAX
    mDisplayString OFFSET sumMessage
    PUSH    OFFSET outputBuffer
    PUSH    totalSum
    CALL    WriteVal
    CALL    CRLF

    ; Calculate and display average
    MOV     EAX, totalSum
    MOV     EBX, NUM_COUNT
    CDQ                                                          ; Extend the sign of EAX into EDX to prepare for division by EBX
    IDIV    EBX                                                  ; Divide EAX by EBX to get the average.
    MOV     averageValue, EAX
    mDisplayString OFFSET avgMessage
    PUSH    OFFSET outputBuffer
    PUSH    averageValue
    CALL    WriteVal
    CALL    CRLF

    ; End message
    mDisplayString OFFSET endMessage
    CALL    CRLF

    ; Exit process
    Invoke  ExitProcess, 0
main ENDP

; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; Prompts the user for a valid signed integer input, validates the input, and converts
; the ASCII string representation into an SDWORD integer. If the input is invalid,
; displays an error message and prompts the user to try again.
;
; Preconditions: Assume that mGetString and mDisplayString macros are defined.
;
; Postconditions: The following registers are changed: EAX, EBX, ECX, EDX, ESI, EDI, EBP.
;
; Receives: 
;   [EBP + 28] = errorMessage  - Memory address of the error message to be displayed if the input is invalid.
;   [EBP + 20] = validNumber   - Memory address where the validated integer will be stored.
;   [EBP + 16] = promptMessage - Memory address of the prompt message to be displayed to the user.
;   [EBP + 12] = userBuffer    - Memory address of the buffer to store the raw user input string.
;   [EBP + 8]  = inputLength   - Maximum length of the user input string.
;
; Returns: 
;   Stores the validated integer value at the address provided in validNumber, and 
;   updates the negativeFlag variable to indicate the sign of the input number.
; ---------------------------------------------------------------------------------
ReadVal PROC
    PUSH    EBP
    MOV     EBP, ESP                                            ; Establish a new base pointer for the stack frame
    PUSHAD                                                      ; Save all general-purpose registers to preserve their values

    ; Read user input
    prompt_input:
    mGetString [EBP+16], [EBP+12], [EBP+8]                      ; Use the macro to read the input string into the buffer to store the number of bytes read.

    ; Initialize conversion variables
    CLD                                                         ; Clear the direction flag for string operations processing. 
    MOV     ECX, [EBP+8]                                        ; Load the input length into ECX to control loop
    MOV     ESI, [EBP+12]                                       ; Load the address of the user input buffer into the ESI register for string processing
    MOV     EDI, [EBP+20]
    XOR     EAX, EAX
    XOR     EBX, EBX
    XOR     EDX, EDX                                            ; Clear the EDX register to be used as a sign flag for detecting negative signs.

    ; Iterates through each character in the user input string, 
    ; checking if it is a valid part of a number (digits, spaces, plus, and minus signs). 
    ; It converts valid digits from their ASCII representation to their integer value, accumulates the result in EBX
    validate_loop:
    LODSB                                                       ; Instruction loads the byte at the address in ESI into the AL register
    CMP     AL, 0                                               ; Check if the current character is the end of the string
    JE      check_end                                           ; If it is then jump to label for ending validation.
    CMP     AL, ' '
    JE      next_char  
    CMP     AL, '+'
    JZ      next_char
    CMP     AL, '-'
    JE      handle_negative
    CMP     AL, '0'
    JB      display_error
    CMP     AL, '9'
    JA      display_error
    SUB     AL, '0'                                             ; Convert the ASCII character to its integer value
    IMUL    EBX, 10
    ADD     EBX, EAX
    JMP     next_char

    handle_negative:
    OR      EDX, 1                                              ; Set the least significant bit (LSB) of the EDX register to 1, used as a flag to indicate that a negative sign was detected.
    JMP     next_char

    next_char:
    LOOP    validate_loop

    check_end:
    CMP     EDX, 1                                              ; Check to see if the sign flag indicates a negative number
    JNE     store_valid
    NEG     EBX

    store_valid:
    MOV     EAX, EBX                                            ; Move the valid integer value from EBX to EAX
    MOV     [EDI], EAX
    JMP     end_proc

    display_error:
    mDisplayString [EBP+28]
    JMP     prompt_input

    end_proc:
    POPAD
    POP     EBP
    RET     36
ReadVal ENDP

; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; Converts a signed integer into its ASCII string representation and displays it.
; If the number is negative, the negative sign is added at the beginning of the string.
; The conversion happens by repeatedly dividing the number by 10, then taking the
; digits and storing in reverse order. The final string is then displayed using macro.
;
; Preconditions: Assumes the mDisplayString macro is defined.
;
; Postconditions: The registers that are changed are EAX, EBX, ECX, EDX, ESI, EDI, EBP.
;
; Receives: 
;   [EBP + 12] = Memory address where the string version of the integer will be stored.
;   [EBP + 8]  = The signed integer value that needs to be converted to a string and displayed.
;
; Returns:
;   The converted string is stored in the buffer pointed to by outputBuffer, displayed using the mDisplayString macro.
; ---------------------------------------------------------------------------------
WriteVal PROC
    PUSH    EBP
    MOV     EBP, ESP                                                            
    PUSHAD

    MOV     ESI, [EBP+8]                                        ; Load the number to be converted into ESI
    MOV     EDI, [EBP+12]                                       ; Load the address where the string will be stored into EDI

    MOV     EAX, ESI
    MOV     ECX, 0                                              ; Clear ECX to use it as a counter
    CMP     EAX, 0
    JGE     int_to_str                                          ; If the number is non-negative, jump to int_to_str to be converted into its ASCII string representation

    ; If the number is negative, save it on stack, store '-', retrieve number, convert to positive
    ; Conversion to positive is necessary to convert the number to its string representation as it's easier to handle the conversion for positive numbers, 
    ; and the negative sign has already been accounted for.
    PUSH    EAX
    MOV     AL, '-'                                             ; Move the '-' character to AL
    STOSB
    POP     EAX
    IMUL    EAX, -1                                             ; Convert the number to positive by multiplying it by -1

    ; Each division gives us one digit from the right, which we convert to a character and store to build the complete string representation of the number.
    ; During the conversion process (int_to_str), digits are extracted from the least significant to the most significant (right to left.
    ; and pushed onto the stack in reverse order because the stack operates in a Last-In-First-Out manner.
    ; By pushing the digits onto the stack, we can later retrieve them in the correct order 
    int_to_str:
    MOV     EBX, 10
    CDQ
    IDIV    EBX
    ADD     EDX, '0'                                            ; Convert the remainder to its ASCII character
    PUSH    EDX
    INC     ECX
    CMP     EAX, 0
    JE      convert_remaining                                  ;  If quotient is zero, jump to convert_remaining for final steps of forming complete string representation 
    JMP     int_to_str

    ; The convert_remaining label retrieves the digits from the stack in the correct order for constructing the final string
    convert_remaining:
    POP     EAX                                                ; Pop retreives the least significant digit from the stack (which is the reverse order they were pushed)
    STOSB                                                      ; Places the digit into the output string at the current position and moves to the next position.
    LOOP    convert_remaining

    ; The string is expected to be null terminated with a null character of '0', reason being to avoid reading memory beyond the intended end of a string.
    XOR     AL, AL
    STOSB

    mDisplayString [EBP+12]

    POPAD
    POP     EBP
    RET     8
WriteVal ENDP

END main
