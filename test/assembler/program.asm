        .org $8000       ; Set the start address to $8000

start:  LDA #5          ; Load the value 5 into the accumulator
        ADC #2          ; Add the value 2 to the accumulator

loop:   JMP loop        ; Infinite loop to keep the program running

        .org $FFFC      ; Set the reset vector address
        .word start     ; Reset vector points to the start of our program
