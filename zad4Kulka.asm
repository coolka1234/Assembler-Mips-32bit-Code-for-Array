.eqv STACK_SIZE 2048
.data
sys_stack_addr: .word 0
stack: .space STACK_SIZE
global_array: .word 1,2,3,4,5,6,7,8,9,10
global_array_size:
.word 10
.globl main
.text
# inicjalizacja adres stosu i jego zapis
	sw $sp, sys_stack_addr 		# zachowanie adresu stosu systemowego
	la $sp, stack+STACK_SIZE 	# zainicjowanie obszaru stosu
main:
	sub $sp, $sp, 4                 #rezerwacja dla stosu miejsca na s koncowe (4 bajty)
	sub $sp, $sp, 8                 #rezerwacja dla argumentow funkcji (8 bajty)
	la $t1, global_array	 	#t0=wskaznik na poczatek tablicy global_array
	sw $t1, 4($sp)		        #pierwszy argument funkcji
	lw $t1, global_array_size	#t0=rozmiar global_array
	sw $t1, 0($sp) 		        #drugi argumnt funkcji
jal sum				        #jump and link dla podprogramu
	lw $t1, ($sp)		        #t= zwrocona wartosc ze stosu
	sw $t1, 12($sp)		        # zapisz s zwrocone do stosu
	add $sp, $sp, 12	        # usuniecie zwroconej wartosci i argumentow ze stosu
	li $v0, 1		        # syscall dla int
	lw $a0, ($sp)                   #wypisz wartosc s
	syscall
	add $sp, $sp, 4		        # usuwam zmienna lokalna ze stosu
	#zakoncz program
	lw $sp, sys_stack_addr          #odtworzenie wskaznika systemowego
	li $v0, 10
	syscall
sum:
	sub $sp, $sp, 8 	# zarezerwowanie miejsca na wartosc zwracana i adres powrotu
	sw $ra, ($sp) 		# umieszczenie adresu powrotu na wierzcholku stosu
	sub $sp, $sp, 8		# int i; int s;
#sciaga stosu: 0=s, 4=i, 8=$ra, 12=zwrocona wartosc, 16=rozmiar tablicy, 20=adres tablicy		
	sw $zero, ($sp)		# s = 0;
	lw $t1, 16($sp)		# wczytujemy rozmiar tablicy
	subi $t1, $t1, 1	# dla tablicy zmniejszamy o jeden
	sw $t1, 4($sp)		# zapisujemy zmienna i
petla:
	lw $t1, 4($sp)          # wczytaj i po raz kolejny
bltz $t1, koniecPetli 	        # while (i>=0)	
	sll $t1, $t1, 2		# *4 by otrzymac prawidlowe word boundary	
	lw $t0, 20($sp)		# wczytuje address tablicy
	add $t1, $t0, $t1	# i=i*4+adres
	lw $t1, ($t1)		# t0 to teraz wartosc tablicy dla danego adresu	
	lw $t0, ($sp)		# wczytaj s
	add $t0, $t0, $t1	# oblicz s+array[i]
	sw $t0, ($sp)		# zapisz s na stos	
	lw $t1, 4($sp)		# wczytuje jeszcze raz i
	subi $t1, $t1, 1	# i--
	sw $t1, 4($sp)		# zapisz pomniejszone i do stosu (zgodnie ze specyfikacja)
j petla	
koniecPetli:
	lw $t1, ($sp)		# odczytaj ze stosu
	sw $t1, 12($sp)		# zapisz zwrocona wartosc
	add $sp, $sp, 8		# usun lokalne zmienne ze stosu
	lw $ra, ($sp)		# adres powrotu wczytaj, by wrocic
	add $sp, $sp, 4		# powroc stos do pierwotnej wartosci
jr $ra			        # powrot do main:
