.section .data
    incremento: .quad 4096
    topoInicioHeap: .quad 0
    atualHeap: .quad 0
    fimHeap: .quad 0
    strNull: .string "********** Trabalho realizado por Enzo Piolla e Luan Bernardt **********\n "
    str0: .string "################"
    str1: .string "\n"
    str2: .string "+"
    str3: .string "-"
.section .text
    .globl iniciaAlocador
    .globl finalizaAlocador
    .globl alocaMem
    .globl liberaMem
    .globl imprimeMapa
    
iniciaAlocador:
    pushq %rbp
    movq %rsp, %rbp
    call iniciaBuffer
    movq $0, %rdi
    movq $12, %rax
    syscall
    movq %rax, topoInicioHeap
    movq %rax, atualHeap
    movq %rax, fimHeap
    popq %rbp
    ret

finalizaAlocador:
    pushq %rbp
    movq %rsp, %rbp
    movq topoInicioHeap, %rdi
    movq $12, %rax
    syscall
    popq %rbp
    ret

alocaMem:
    pushq %rbp
    movq %rsp, %rbp
    movq %rdi, %rsi #numbytes
    movq topoInicioHeap, %rdi #aux
    movq $0, %rdx #worstfit
    movq topoInicioHeap, %rcx #i
    movq atualHeap, %r8 #atualHeap
    movq $0, %r9 #0 do if
    cmpq %r8, %rcx #compara i com atualHeap
    jge poswhile1alocaMem
while1alocaMem: #compara valor apontado por aux com 0
    movq (%rdi), %r10
    cmpq %r10, %r9 #compara *aux com 0
    jne durwhile1alocaMem
    pushq %rdi #salva rdi
    addq $8, %rdi
    movq (%rdi), %r10 #%r10 = *(aux+1)
    popq %rdi #restaura rdi
    cmpq %rsi, %r10 #compara *(aux+1) com numbytes
    jl durwhile1alocaMem
    cmpq %rdx, %r9 #compara worstfit com 0
    jne elseif3alocaMem
    movq %rdi, %rdx #guarda o aux no worstfit
    jmp durwhile1alocaMem
elseif3alocaMem: #compara o tamanho de *(worstfit+1) com *(aux+1)
    pushq %rdx #salva rdx
    addq $8, %rdx
    movq (%rdx), %r11 #%r11 = *(worstfit+1)
    popq %rdx #restaura rdx
    cmpq %r10, %r11 #compara *(worstfit+1) com *(aux+1)
    jge durwhile1alocaMem
    movq %rdi, %rdx #worstfit = aux
durwhile1alocaMem: # incrementa i e atualiza aux
    pushq %rdi #salva rdi
    addq $8, %rdi
    movq (%rdi), %r10 #%r10 = *(aux+1)
    popq %rdi #restaura rdi
    addq $16, %r10 # %r10 = *(aux+1) + 16
    addq %r10, %rcx #incrementa o i
    movq %rcx, %rdi #atualiza o aux
    cmpq %r8, %rcx #compara i com atualHeap
    jl while1alocaMem #volta ao loop
poswhile1alocaMem: # após o while 1 no alocaMem
    cmpq %rdx, %r9
    je elseif5alocaMem
    movq $1, (%rdx) # *worstfit = 1
    addq $16, %rdx
    movq %rdx, %rax #%rax = *(worstfit+2)
    popq %rbp
    ret
elseif5alocaMem: #aumenta o brk e aloca na heap
    movq fimHeap, %r9
    subq %r8, %r9 # %r9 = fimHeap-atualHeap
    addq $16, %rsi # %rsi = numbytes+16
    cmpq %rsi, %r9
    jge poselseif5alocaMem
while2alocaMem: #aloca memória
    pushq %rsi #salva %rsi, numbytes+16
    pushq %r8 #salva %r8, atualHeap
    pushq %rdi #salva rdi, o aux
    movq incremento, %rdi
    movq fimHeap, %r11
    addq %r11, %rdi #%rdi = fimHeap+incremento
    movq $12, %rax
    syscall
    movq %rax, fimHeap #atualiza fimHeap
    movq %rax, %r9
    popq %rdi #restaura rdi, o aux
    popq %r8 #restaura %r8, atualHeap
    popq %rsi #restaura %rsi, numbytes+16
    subq %r8, %r9 #%r9 = fimHeap-atualHeap
    cmpq %rsi, %r9
    jl while2alocaMem
poselseif5alocaMem: #altera os valores e retorna
    subq $16, %rsi # %rsi = numbytes
    movq $1, (%rdi) #*aux = 1
    addq $8, %rdi
    movq %rsi, (%rdi) #*(aux+1) = numbytes
    addq %rsi, %r8 #%r8 = atualHeap+numbytes
    addq $16, %r8 #%r8 = atualHeap+numbytes+16
    movq %r8, atualHeap #atualiza atualHeap
    addq $8, %rdi
    movq %rdi, %rax #%rax = aux+2
    popq %rbp
    ret

liberaMem:
    pushq %rbp
    movq %rsp, %rbp
    subq $16, %rdi #%rdi = bloco-2
    movq $0, (%rdi) # *(bloco-2) = 0
    popq %rbp
    ret

iniciaBuffer:
    pushq %rbp
    movq %rsp, %rbp
    movq $strNull, %rdi
    call printf
    popq %rbp
    ret

imprimeMapa:
    pushq %rbp
    movq %rsp, %rbp
    movq $str1, %rdi # printf("\n")
    movq $0, %rax
    call printf
    movq topoInicioHeap, %rbx #i
    movq atualHeap, %rcx
while:
    cmpq %rcx, %rbx # i - atualHeap
    jge fim_while
    pushq %rcx
    movq $0, %rax
    movq $str0, %rdi # %rdi = "###############"
    call printf
    movq (%rbx), %rdx # %rbx = *(aux) 
    cmpq $0, %rdx
    jne else
    movq $str3, %rdi # %rdi = "-"
    jmp fim_if
else:
    movq $str2, %rdi # %rdi = "+"
fim_if:
    movq $0, %r10 # k = 0
    addq $8, %rbx
    movq (%rbx), %rdx # %rdx = *(aux+1)
for:
    cmpq %rdx, %r10 # %rdx - k
    jge fim_for
    pushq %rdx
    pushq %r10
    pushq %rdi
    movq $0, %rax
    call printf
    popq %rdi
    popq %r10
    addq $1, %r10
    popq %rdx
    jmp for
fim_for:
    addq $8, %rdx
    addq %rdx, %rbx
    popq %rcx
    jmp while
fim_while:
    movq $str1, %rdi # printf("\n")
    movq $0, %rax
    call printf
    popq %rbp
    ret
