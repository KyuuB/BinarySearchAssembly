.data 

original_list: .space 100 
sorted_list: .space 100

str0: .asciiz "Enter size of list (between 1 and 25): "
str1: .asciiz "Enter one list element: "
str2: .asciiz "Content of original list: "
str3: .asciiz "Enter a key to search for: "
str4: .asciiz "Content of sorted list: "
strYes: .asciiz "Key found!"
strNo: .asciiz "Key not found!"
newLine: .asciiz "\n"


.text 

#This is the main program.
#It first asks user to enter the size of a list.
#It then asks user to input the elements of the list, one at a time.
#It then calls printList to print out content of the list.
#It then calls inSort to perform insertion sort
#It then asks user to enter a search key and calls bSearch on the sorted list.
#It then prints out search result based on return value of bSearch
main: 
	addi $sp, $sp -8
	sw $ra, 0($sp)
	li $v0, 4 
	la $a0, str0 
	syscall 
	li $v0, 5	#read size of list from user
	syscall
	move $s0, $v0
	move $t0, $0
	la $s1, original_list
loop_in:
	li $v0, 4 
	la $a0, str1 
	syscall 
	sll $t1, $t0, 2
	add $t1, $t1, $s1
	li $v0, 5	#read elements from user
	syscall
	sw $v0, 0($t1)
	addi $t0, $t0, 1
	bne $t0, $s0, loop_in
	move $a0, $s1
	move $a1, $s0
	
	jal inSort	#Call inSort to perform insertion sort in original list
	
	sw $v0, 4($sp)
	li $v0, 4 
	la $a0, str2 
	syscall 
	la $a0, original_list
	move $a1, $s0
	jal printList	#Print original list
	li $v0, 4 
	la $a0, str4 
	syscall 
	lw $a0, 4($sp)
	jal printList	#Print sorted list
	
	li $v0, 4 
	la $a0, str3 
	syscall 
	li $v0, 5	#read search key from user
	syscall
	move $a3, $v0
	lw $a0, 4($sp)
	jal bSearch	#call bSearch to perform binary search
	
	beq $v0, $0, notFound
	li $v0, 4 
	la $a0, strYes 
	syscall 
	j end
	
notFound:
	li $v0, 4 
	la $a0, strNo 
	syscall 
end:
	lw $ra, 0($sp)
	addi $sp, $sp 8
	li $v0, 10 
	syscall
	
	
#printList takes in a list and its size as arguments. 
#It prints all the elements in one line.
printList:
	#Your implementation of printList here	
	
	move $t0, $0		#$t0 = 0
	add $s0, $zero, $a0	#$s0 = address space
	
	print_loop:		#for loop for print
	sll $t1, $t0, 2		#$t1 = i * 4
	add $t1, $t1, $s0	#t1 = i*4 + address of array
	lw $a0, 0($t1)		# $a0 = address of array + i*4
	li $v0, 1		#Print integer stored in $a0
	syscall	
	li $a0, 32		#Space ASCII code 32 = space
	li $v0, 11		#Print character
	syscall 		
	addi $t0, $t0, 1	#i++
	bne $t0, $a1, print_loop#Once i++ = list_Size then loop stops
	li $v0, 4
	la $a0, newLine
	syscall
	jr $ra			#Return from jump and link
	
	
#inSort takes in a list and it size as arguments. 
#It performs INSERTION sort in ascending order and returns a new sorted list
#You may use the pre-defined sorted_list to store the result
inSort:
	#Your implementation of inSort here
	
	
	addi $t0, $zero, 0	#$t0 = i, i = 0		    $a1 = list Size 
				#Unsorted list address in   $a0
	la $v0, sorted_list	#Sorted list address in     $v0
	
copyFor_loop:			# I first copy unsorted array into sorted array
	sll $t1, $t0, 2		#i*4
	add $t2, $v0, $t1	# t2 = i*4 + Sorted address 
	add $t1, $a0, $t1	# t1 = i*4 + Unsorted address
	lw $t3, 0($t1)		#Grab integer in unsorted address
	sw $t3, 0($t2)		#Place integer in sorted address
	addi $t0, $t0, 1
	bne $t0, $a1, copyFor_loop
	
	# For loop begins
	addi $t0, $zero, 1	#t0 = i, i = 1	
inFor_loop:			
	sll $t1, $t0, 2		# $t1 = i * 4
	add $t1, $t1, $v0	# $t1 = i * 4 + sorted address
	lw $t1, 0($t1)		# $t1 = sorted_address[i] = Key 
	addi $t2, $t0, -1	# $t2 = j = i - 1
		
inWhile_loop: # While loop begins 
	
	sll $t3, $t2, 2		# $t3 = j * 4
	add $t3, $t3, $v0 	# $t4 = j*4 + sorted address
	lw $t5, 0($t3)		# $t5 = sorted[j]
	
	slt $t4, $t2, $zero 	#If $t2 is less than zero, then $t4 = 1, else $t4 = 0
	beq $t4, $zero, check1	#If $t4 = zero, than jump to inWhile_loop
	j noCheck		#If while loop is false, continue
check1:
	slt $t6, $t1, $t5	# If key is less than sorted[j], $t6 = 1, otherwise = 0
	bne $t6, $zero, check2	# branch when key is less than arr[j]
	j noCheck		# If while loop is false, continue
check2:
	sw $t5, 4($t3)		# store sorted[j] into sorted array[j + 1]
	addi $t2, $t2, -1	# j-- 
	j inWhile_loop		# if both checks for while loop pass then jump back to while loop
	
noCheck:
	sw $t1, 4($t3)		# sorted[j + 1] = key
	addi $t0, $t0, 1
	bne $t0, $a1, inFor_loop	#Jump back to for loop as long as i < list Size 
	jr $ra			
	
#bSearch takes in a list, its size, and a search key as arguments.
#It performs binary search RECURSIVELY to look for the search key.
#It will return a 1 if the key is found, or a 0 otherwise.
#Note: you MUST NOT use iterative approach in this function.
bSearch:
	#Your implementation of bSearch here
	
	add $v0, $zero, $zero	#Base case is Value was not Found
	
recursion:
	addi $sp, $sp -12
	sw $ra, 0($sp)		#Save return address
	sw $a2, 4($sp)		#Save left
	sw $a1, 8($sp)		#Save right 
	
	bgt $a2, $a1, skip	#if l > r skip recursion
	add $t0, $a2, $a1	#Left + right
	div $t0, $t0, 2		# $t0 = l + r / 2  $t0 = mid
	sll $t1, $t0, 2		# $t1 = mid * 4
	add $t1, $t1, $a0	# $t1 = mid * 4 + Sorted Address
	lw $t1, 0($t1)		# $t1 = sorted[mid]
	
	bne $t1, $a3, searchRight#If sorted[mid] is not equal to value start recursion
	addi $v0, $zero, 1		#else sorted[mid] = value, then return value is adjusted
	j skip
	
searchRight:
	blt $a3, $t1 searchLeft# if sorted[mid] < value search left side of array
	
	addi $a2, $t0, 1	#a2 = left = mid + 1
	j recursion
	lw $a2, 4($sp)		#Grab left from stack
	lw $a1, 8($sp)		#Grab right from stack
	j skip
searchLeft:
	
	
	addi $a1, $t0, -1	#a0 = right = mid - 1
	j recursion
	lw $a2, 4($sp)		#Grab left from stack
	lw $a1, 8($sp)		#Grab right from stack
skip:
	lw $ra, 0($sp)
	addi $sp, $sp 12
	jr $ra
	
