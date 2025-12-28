section .data
    errorMPEP db "Miss Program Entry Point: Can you look for ':' in your code?", 0
    Mlen equ $ - errorMPEP - 1
    errorAT db "Abnormal Termination: Can you look for ';' in your code?", 0
    Alen equ $ - errorAT - 1
    errorBO db "Buffer Overflow: The buffer is overflow!!!", 0
    Blen equ $ - errorBO - 1
    errorDP db "Dangling Pointer: Emm... EDI is a dangling pointer.", 0
    Dlen equ $ - errorDP - 1
    error dd 0
    errorBuffer times 256 db 0
section .text
    global Miss_Program_Entry_Point, Abnormal_Termination, Buffer_Overflow, Dangling_Pointer, Unkown_Error
    extern _WriteConsoleA@20, _GetLastError@0, _FormatMessageA@28
    extern hOut
    Abnormal_Termination:
        push 0
        push 0  
        push Alen           
        push errorAT
        push dword [hOut]
        call _WriteConsoleA@20
        ret
    Miss_Program_Entry_Point:
        push 0
        push 0  
        push Mlen           
        push errorMPEP
        push dword [hOut]
        call _WriteConsoleA@20
        ret
    Buffer_Overflow:
        push 0
        push 0  
        push Blen           
        push errorBO
        push dword [hOut]
        call _WriteConsoleA@20
        ret
    Dangling_Pointer:
        push 0
        push 0  
        push Dlen           
        push errorDP
        push dword [hOut]
        call _WriteConsoleA@20
        ret
    Unkown_Error:
        call _GetLastError@0
        mov dword [error], eax

        push 0
        push 256
        push errorBuffer
        push 0
        push dword [error]
        push 0
        push 0x1200
        call _FormatMessageA@28

        push 0
        push 0  
        push 256
        push errorBuffer
        push dword [hOut]
        call _WriteConsoleA@20

        call _GetLastError@0
        ret