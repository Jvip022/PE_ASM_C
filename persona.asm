section .data
    ; Formatos para printf
    fmt_persona      db "-> Nombre: %s, Edad: %d, Altura: %.2fm", 10, 0
    fmt_header       db "--- Lista de Personas (%d registros) ---", 10, 0
    fmt_empty        db "No hay personas registradas.", 10, 0
    fmt_error        db "Error: memoria insuficiente", 10, 0
    
    ; Variables del sistema
    cantidad_personas dd 0
    primera_persona   dd 0

section .bss
    ; No se necesitan reservas adicionales

section .text
    global inicializarSistema, limpiarSistema, crearPersona
    global mostrarPersona, mostrarTodasLasPersonas, liberarPersona
    global liberarPersonaInterna, obtenerCantidadPersonas, obtenerPersonaPorIndice
    global mostrarPersonaPorIndice
    extern printf, malloc, free, strlen, strcpy

; Estructura Persona en memoria:
; offset 0:  puntero a nombre (4 bytes)
; offset 4:  edad (4 bytes)  
; offset 8:  altura (4 bytes, float)
; offset 12: puntero a siguiente persona (4 bytes) - para lista enlazada
; total: 16 bytes

; void inicializarSistema()
inicializarSistema:
    push ebp
    mov ebp, esp
    mov dword [cantidad_personas], 0
    mov dword [primera_persona], 0
    pop ebp
    ret

; void limpiarSistema()
limpiarSistema:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    
    mov esi, [primera_persona]      ; esi = primera persona
    
.limpiar_lista:
    test esi, esi
    jz .lista_limpia
    
    mov ebx, [esi+12]               ; ebx = siguiente persona
    
    push esi
    call liberarPersonaInterna
    add esp, 4
    
    mov esi, ebx
    jmp .limpiar_lista
    
.lista_limpia:
    mov dword [primera_persona], 0
    mov dword [cantidad_personas], 0
    
    pop esi
    pop ebx
    pop ebp
    ret

; Persona crearPersona(const char* nombre, int edad, float altura)
crearPersona:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    push 16
    call malloc
    add esp, 4
    test eax, eax
    jz .error
    
    mov esi, eax                    ; esi = nueva estructura
    
    mov dword [esi+4], 0            ; edad inicial 0
    mov dword [esi+8], 0         ; altura inicial 0
    mov dword [esi+12], 0           ; siguiente = NULL
    
    mov eax, [ebp+8]                ; nombre original
    test eax, eax
    jz .sin_nombre
    
    push eax
    call strlen
    add esp, 4
    inc eax                         ; +1 para null terminator
    
    push eax
    call malloc
    add esp, 4
    test eax, eax
    jz .error_nombre
    
    mov edi, eax                    ; edi = nuevo nombre
    mov ebx, [ebp+8]                ; ebx = nombre original
    push ebx
    push edi
    call strcpy
    add esp, 8
    
    mov [esi], edi                  ; guardar puntero al nombre
    jmp .configurar_datos
    
.sin_nombre:
    mov dword [esi], 0              ; nombre = NULL
    
.configurar_datos:
    mov eax, [ebp+12]               ; edad
    mov [esi+4], eax
    
    mov eax, [ebp+16]               ; altura
    mov [esi+8], eax
    
    mov eax, [primera_persona]
    mov [esi+12], eax               ; siguiente = primera actual
    mov [primera_persona], esi      ; nueva primera = esta persona
    
    mov eax, [cantidad_personas]
    inc eax
    mov [cantidad_personas], eax
    
    mov eax, esi                    ; retornar la persona
    jmp .fin
    
.error_nombre:
    push esi
    call free
    add esp, 4
    
.error:
    xor eax, eax                    ; retornar NULL
    
.fin:
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; void mostrarPersona(Persona p)
mostrarPersona:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp+8]                ; eax = persona
    test eax, eax
    jz .fin

    ;convertir a float a double para  printf
    ;altura
    fld dword [eax+8]               ;cargar float (32 bits) a ST(0)
    sub esp, 8                      ;Resevar espacio para double (64 bits)
    fstp qword [esp]                ;Almacenar como double (64 bits) en la pila
    push dword [eax+4]              ; edad
    push dword [eax]                ; nombre
    push fmt_persona
    call printf
    add esp, 20                     ;Limpiar pila: 4+4+8=16, mas 4 del formato = 20 
    
.fin:
    pop ebp
    ret

; void mostrarTodasLasPersonas()
mostrarTodasLasPersonas:
    push ebp
    mov ebp, esp
    push ebx
    

    push dword [cantidad_personas]
    push fmt_header
    call printf
    add esp, 8
    
    mov ebx, [primera_persona]      ; ebx = primera persona
    
.mostrar_lista:
    test ebx, ebx
    jz .fin
    
    ; altura
    fld dword [ebx+8]               ;Cargar float
    sub esp, 8                      ;Resevar espacio para double 
    fstp qword [esp]                ;Almacenar como double 
    push dword [ebx+4]              ; edad
    push dword [ebx]                ; nombre
    push fmt_persona
    call printf
    add esp, 20
    
    mov ebx, [ebx+12]
    jmp .mostrar_lista
    
.fin:
    pop ebx
    pop ebp
    ret

; void liberarPersona(Persona p)
liberarPersona:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov esi, [ebp+8]                ; esi = persona a liberar
    test esi, esi
    jz .fin
    
    mov ebx, primera_persona
    mov edi, [ebx]                  ; edi = primera persona
    
    cmp edi, esi
    jne .buscar_en_lista
    
    mov eax, [esi+12]               ; eax = siguiente
    mov [ebx], eax                  ; primera_persona = siguiente
    jmp .liberar
    
.buscar_en_lista:
    test edi, edi
    jz .liberar
    
    mov eax, edi
    mov edi, [eax+12]               ; edi = siguiente
    
    cmp edi, esi
    jne .buscar_en_lista
    
    mov ecx, [esi+12]               ; ecx = siguiente de la que eliminamos
    mov [eax+12], ecx               ; anterior->siguiente = siguiente de eliminada
    
.liberar:
    call liberarPersonaInterna
    
    mov eax, [cantidad_personas]
    dec eax
    mov [cantidad_personas], eax
    
.fin:
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; Función interna para liberar una persona
liberarPersonaInterna:
    push esi
    
    mov eax, [esi]
    test eax, eax
    jz .liberar_estructura
    
    push eax
    call free
    add esp, 4
    
.liberar_estructura:
    push esi
    call free
    add esp, 4
    
    pop esi
    ret

; int obtenerCantidadPersonas()
obtenerCantidadPersonas:
    push ebp
    mov ebp, esp
    mov eax, [cantidad_personas]
    pop ebp
    ret

obtenerPersonaPorIndice:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    
    mov eax, [ebp+8]        ; eax = indice solicitado
    cmp eax, 0
    jl .indice_invalido
    
    mov ebx, [primera_persona]  ; ebx = persona actual
    mov ecx, 0                   ; ecx = contador
    
.buscar:
    test ebx, ebx
    jz .indice_invalido
    
    cmp ecx, eax
    je .encontrado
    
    mov ebx, [ebx+12]        ; siguiente persona
    inc ecx
    jmp .buscar

.encontrado:
    mov eax, ebx             ; retornar persona encontrada
    jmp .fin

.indice_invalido:
    xor eax, eax             ; retornar NULL

.fin:
    pop esi
    pop ebx
    pop ebp
    ret

; void mostrarPersonaPorIndice(int indice)
mostrarPersonaPorIndice:
    push ebp
    mov ebp, esp
    push ebx
    
    push dword [ebp+8]       ; pasar índice
    call obtenerPersonaPorIndice
    add esp, 4
    
    test eax, eax
    jz .fin                  ; si es NULL, no hacer nada
    
    push eax                 ; mostrar la persona encontrada
    call mostrarPersona
    add esp, 4

.fin:
    pop ebx
    pop ebp
    ret
