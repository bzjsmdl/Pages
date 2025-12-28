section .data
    buffer db 0
section .text
    global _Interpreter
    extern _VirtualAlloc@16, _WriteConsoleA@20
    extern entry_point, exit, hOut
    _Interpreter:
        .init:
            xor ebx, ebx
            xor edx, edx
            mov esi, entry_point

            push 0x04
            push 0x3000
            push 0x10000000
            push 0
            call _VirtualAlloc@16
            test eax, eax
            je .AMI
            mov edi, eax
            .AMI:
                mov eax, 5
                jmp .return

        .main:
            lea ecx, byte [esi + ebx]
            cmp ecx, dword [exit]
            je .return

            cmp byte [esi + ebx], '+'
            je .increment
            cmp byte [esi + ebx], '-'
            je .decrement
            cmp byte [esi + ebx], '<'
            je .pointer_move_left
            cmp byte [esi + ebx], '>'
            je .pointer_move_right
            cmp byte [esi + ebx], 'r'
            je .read
            cmp byte [esi + ebx], '!'
            je .force
            cmp byte [esi + ebx], '.'
            je .output
            jne .next

            .increment:
                cmp dl, 0xFF
                ja .BO
                inc byte [buffer]
                jmp .next
                .BO:
                    mov eax, 3
                    jmp .return
                
            .decrement:
                dec byte [buffer]
                jmp .next

            .pointer_move_right:
                cmp edx, 0x30000000
                ja .DP
                inc edi
                inc edx
                jmp .next

            .pointer_move_left:
                cmp edx, -1
                jng .DP
                dec edi
                dec edx
                jmp .next
            .DP:
                mov eax, 4
                jmp .return
            .read:
                mov ah, byte [edi]
                mov byte [buffer], ah
                jmp .next
            .force:
                mov ah, byte [buffer]
                mov ah, byte [edi]
                jmp .next
            
            .output:
                push 0
                push 0
                push 1
                push buffer
                push dword [hOut]
                call _WriteConsoleA@20
                jmp .next
            
            .next:
                xor eax, eax
                inc ebx
                jmp .main
            .return:
                ret