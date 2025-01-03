# MASM-Program-for-String-and-Integer-Processing
#### **Project Overview**

This project is a MASM (Microsoft Macro Assembler) program that performs string processing and signed integer operations using macros and procedures. The program leverages Irvine's library for input and output and implements fundamental operations like reading and displaying strings, validating numeric input, and processing integers.

---

#### **Features**

1. **Macros for String Processing**:
   - **`mGetString`**:
     - Prompts the user for input and stores the result in a specified memory location.
     - Parameters:
       - Input: Prompt message, maximum string length.
       - Output: User input string, length of input.
   - **`mDisplayString`**:
     - Displays a string stored at a given memory location.

2. **Procedures for Signed Integer Operations**:
   - **`ReadVal`**:
     - Reads a string input from the user using `mGetString`.
     - Validates the input as a numeric string (with optional sign) and converts it to an SDWORD.
     - Stores the result in a specified memory variable.
   - **`WriteVal`**:
     - Converts an SDWORD value to an ASCII string representation.
     - Displays the string using `mDisplayString`.

3. **Main Program Functionality**:
   - Reads 10 valid integers from the user.
   - Stores the integers in an array.
   - Calculates and displays:
     - The integers.
     - Their sum.
     - Their truncated average.

---

#### **Program Requirements**

1. **Input Validation**:
   - The input must only contain digits and an optional sign (`+` or `-`).
   - Inputs with non-digit characters or values too large for a 32-bit register are rejected with an error message.
   - Empty inputs prompt the user to re-enter a value.

2. **Usage Restrictions**:
   - Direct calls to `ReadInt`, `ReadDec`, `WriteInt`, or `WriteDec` are not allowed.
   - Procedures must pass parameters via the runtime stack (using the `STDCall` convention).
   - Strings must be passed by reference.
   - Global data references within procedures are not allowed (except for constants).

3. **Optimization**:
   - Use `LODSB` and `STOSB` for string processing.
   - Use register indirect addressing for array elements and base+offset addressing for stack parameters.

4. **Output Requirements**:
   - Strings must be displayed using `mDisplayString`.
   - Only the integer part of the average is displayed (truncate fractional parts).

5. **Documentation and Style**:
   - The program must include clear and complete comments, including:
     - A header block describing the program and author details.
     - Detailed procedure headers.
     - Inline comments for clarity.
   - The code must follow the CS271 Style Guide.

---

#### **How to Use**

1. **Setup**:
   - Ensure you have Irvine’s library and MASM tools installed as per the course syllabus.
   - Load the program file into the MASM development environment.

2. **Build and Run**:
   - Assemble the program using MASM.
   - Execute the program to prompt for user input.

3. **User Interaction**:
   - Enter 10 valid integers when prompted.
   - If an invalid input is entered, re-enter the value after the error message.
   - View the displayed integers, their sum, and truncated average.

---

#### **Example Output**

```
Enter integer #1: 15
Enter integer #2: -5
...
Enter integer #10: 25

Integers: 15 -5 10 20 -30 45 -10 50 5 25
Sum: 125
Average: 12
```

---

#### **Notes**

- Ensure the sum of the integers remains within 32-bit signed integer limits.
- The program will handle both positive and negative values.
- Fractional averages will be truncated (e.g., `12.7` → `12`).

---

#### **Files**

- **`Proj6_singrajv.asm`**: The MASM program source code.
- **Irvine’s Library**: Required for string input and output procedures.

---

#### **Acknowledgments**

This program was developed for CS271 to reinforce concepts in low-level string and integer processing, stack management, and assembly programming practices.
