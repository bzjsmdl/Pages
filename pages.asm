section .text
    global _Interpreter        
    _Interpreter:
        cmp byte [esi], '<'
        je read
        cmp byte [esi], '!'
        je force_write
        cmp byte [esi], '{'
        je lmov
        cmp byte [esi], '}'
        je rmov
        cmp byte [esi], '+'
        je increment_buffer
        cmp byte [esi], '-'
        je decrement_buffer
        cmp byte [esi], '.'
        je output
        cmp byte [esi], ','
        je input
        cmp byte [esi], 0
        je program_end
        cmp byte [esi], 13
        jmp next
        cmp byte [esi], 10
        jmp next
            
        increment_buffer:
            inc eax
            jmp next  
        decrement_buffer:
            dec eax
            jmp next

        lmov:
            sub edi, 1
            jmp next
        rmov:
            add edi, 1
            jmp next
        
        read:
            mov eax, dword [edi]
            jmp next
        force_write:
            mov byte [edi], al
            jmp next

        output:
            mov dword [buffer], eax
            push 0
            push 0  
            push 4             
            push buffer         
            push dword [hOut]
            call _WriteConsoleA@20

            test eax,eax
            jz Output_Error
            jmp next
        input:
            push 0
            push 0
            push 4
            push buffer
            push dword [hIn]
            call _ReadConsoleA@20
            mov al, byte [buffer]
            jmp next

        next:
            inc esi
            jmp _Interpreter
            
        program_end:
            