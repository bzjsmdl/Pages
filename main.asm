section .data
    lengh dd 0
    s db "Program Start",13,10,0 
    sl equ $ - s - 1
    e db 13,10,"Program End",13,10,0
    el equ $ - e - 1
    newline db 13, 10
    
    qf db "Please enter a file's path or file's name(the path'lengh or the name's lengh cannot above the 1024 bytes): ", 0
    flen equ $ - qf - 1
    MPEP db "Miss Program Entry Point: Can you look for ':' in your code?", 0
    Mlen equ $ - MPEP - 1
    ATM db "Abnormal Termination: Can you look for ';' in your code?", 0
    Alen equ $ - ATM - 1
    Alloc_Memory equ 0x20000000
section .bss
    hOut resd 1
    hIn resd 1
    hFile resd 1
    size resd 1
    entry_point resd 1
    exit resd 1
    Alloc_Memory_Base resd 1
    filename resb 1025
section .text
    global _main
    extern _ReadConsoleA@20, _ExitProcess@4, _CreateFileA@28, _ReadFile@20, _CloseHandle@4, _GetStdHandle@4, _WriteConsoleA@20
    extern _VirtualAlloc@16, _GetFileSize@8
    extern _Interpreter
    _main:
        .init:
            push 0x04
            push 0x3000
            push Alloc_Memory    
            push 0
            call _VirtualAlloc@16
            mov edi, eax
            mov dword [Alloc_Memory_Base], eax

            push -11
            call _GetStdHandle@4
            mov dword [hOut], eax

            push -10
            call _GetStdHandle@4
            mov dword [hIn], eax
        .read:      
            push 0
            push 0
            push flen
            push qf
            push dword [hOut]
            call _WriteConsoleA@20

            push 0
            push lengh
            push 1024
            push filename
            push dword [hIn]
            call _ReadConsoleA@20   
            mov ebx, dword [lengh]
            sub ebx, 2
            mov byte [filename + ebx], 0
            
            push 0
            push 0x80
            push 3
            push 0
            push 0x00000001
            push 0x80000000
            push filename
            call _CreateFileA@28
            mov dword [hFile], eax

            push 0
            push dword [size]
            push Alloc_Memory
            push dword [Alloc_Memory_Base]
            push dword [hFile]
            call _ReadFile@20
            mov ebx, dword [size]
            mov byte [edi + ebx + 1], 0

            push dword [hFile]
            call _CloseHandle@4
        .Interpreter_Main:
            xor ebx, ebx
            push 0
            push 0  
            push sl            
            push s         
            push dword [hOut]
            call _WriteConsoleA@20
            
            mov al, ':'
            mov ecx, dword [size]
            cld
            repne scasb
            jne .Miss_Program_Entry_Point
            dec edi
            mov dword [entry_point], edi
            je .call_main

            mov al, ';'
            mov ecx, dword [size]
            cld
            repne scasb
            jne .Abnormal_Termination
            dec edi
            mov dword [exit], edi
            je .call_main

            .call_main:
                nop
                jmp .no_error
        
        .error:
            .Abnormal_Termination:
                push 0
                push 0  
                push Alen           
                push ATM
                push dword [hOut]
                call _WriteConsoleA@20
                jmp .pe
            .Miss_Program_Entry_Point:
                push 0
                push 0  
                push Mlen           
                push MPEP
                push dword [hOut]
                call _WriteConsoleA@20
                jmp .pe
            .pe:    
                push 0
                push 0  
                push el            
                push e   
                push dword [hOut]
                call _WriteConsoleA@20

                push 1
                call _ExitProcess@4
        .no_error:
            push 0
            push 0  
            push el            
            push e   
            push dword [hOut]
            call _WriteConsoleA@20

            push 0
            call _ExitProcess@4