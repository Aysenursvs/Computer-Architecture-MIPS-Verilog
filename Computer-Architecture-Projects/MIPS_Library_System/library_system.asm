# =========================================================
# CENG311 - Library Management System
# QtSpim
# =========================================================

.data

nl:						.asciiz "\n"
arrow:					.asciiz " -> "
left_arrow:				.asciiz " <- "
empty_wl:				.asciiz "(empty)\n"
msg_full:				.asciiz "Array full!\n"
msg_id:					.asciiz "ID: "
msg_year:				.asciiz "  Year: "
msg_title:				.asciiz "Title: "
msg_status:				.asciiz "Status: "
msg_categories:			.asciiz "Categories: "
msg_nonecats:			.asciiz "(none)\n"
msg_avail:				.asciiz "Available\n"
msg_loan:				.asciiz "On Loan to "
msg_wait:				.asciiz "Waitlist: "
msg_checked_out:		.asciiz "Checked out: "
msg_returned:			.asciiz "Returned: "
msg_noholds:			.asciiz "No holds\n"
msg_already_avail:		.asciiz "Already available: "
msg_already_for:		.asciiz "Already on loan: "
msg_held_by:			.asciiz " - held by "
msg_noholds_for:		.asciiz "No holds for: "
msg_wait_added:			.asciiz "Added to waitlist: "
msg_catalog_header:		.asciiz "===== BOOK CATALOGUE ====="
msg_separator:			.asciiz "---------------------------"
msg_booklist_created:	.asciiz "Book list created (capacity=4, count=0)\n"
msg_added_prefix:		.asciiz "Book added to list: "
comma_space:			.asciiz ", "

t_clean:	.asciiz "Clean Code"
t_os:		.asciiz "Operating Systems"
t_net:		.asciiz "Computer Networks"

c_prog:		.asciiz "programming"
c_best:		.asciiz "best-practices"
c_sys:		.asciiz "systems"
c_edu:		.asciiz "education"
c_net:		.asciiz "networks"

p_Alice:	.asciiz "Alice"
p_Bob:		.asciiz "Bob"
p_Jane:		.asciiz "Jane"
p_Charlie:	.asciiz "Charlie"
p_David:	.asciiz "David"
p_Emma:		.asciiz "Emma"
p_Frank:	.asciiz "Frank"
p_Grace:	.asciiz "Grace"
p_Henry:	.asciiz "Henry"
p_Isla:		.asciiz "Isla"
p_Jack:		.asciiz "Jack"
p_Kate:		.asciiz "Kate"
p_Liam:		.asciiz "Liam"

.text


# --------------------- initBookArray ---------------------
initBookArray:
	subu $sp, $sp, 4 
    sw   $ra, 0($sp)

	jal initArray
	move $t0, $v0

	li $v0, 4
	la $a0, msg_booklist_created
	syscall

	lw $ra, 0($sp)
	addu $sp, $sp, 4

	move $v0, $t0

	jr   $ra

# --------------------- initCategoryArray ---------------------
initCategoryArray:
	subu $sp, $sp, 4  
    sw   $ra, 0($sp)  # store return address

	jal initArray
	move $t0, $v0

	lw $ra, 0($sp)  # restore return address
	addu $sp, $sp, 4

	move $v0, $t0

	jr   $ra

# --------------------- initArray ---------------------
initArray:

	li $v0, 9
	li $a0, 16      # size of array 
	syscall	
	move $t0, $v0   # t0 = array base address

	li $v0, 9
	li $a0, 12      # size of array header
	syscall			
	move $t1, $v0   # t1 = header address

	sw $t0, 0($t1)    # store array base address in header
	li $t2, 4			
	sw $t2, 4($t1)  	# store capacity in header
	sw $zero, 8($t1)  	# store count = 0 in header
	
	move $v0, $t1    # return header address in v0

	jr $ra

# --------------------- putOnCategory ---------------------
# a0 = category_hdr
# a1 = str_ptr
putOnCategory:
	lw $t0, 8($a0)       # load count
	lw $t1, 4($a0)       # load capacity
	beq $t0, $t1, cat_full  # if count == capacity, array full

	lw $t2, 0($a0)       # load array base address
	sll $t3, $t0, 2       # t3 = count * 4 (word size)
	add $t4, $t2, $t3     # t4 = address to store new category
	sw  $a1, 0($t4)       # store str_ptr in array
	addi $t0, $t0, 1      # increment count
	sw $t0, 8($a0)        # store updated count
	j cat_done

	cat_full:
		li $v0, 4
		la $a0, msg_full
		syscall	
	cat_done:
		jr  $ra

# --------------------- createBook ---------------------
# a0 = id
# a1 = title_ptr
# a2 = year
# a3 = category_hdr
createBook:
	move $t0, $a0

	li $v0, 9
	li $a0, 24          # size of book struct
	syscall

	sw $t0, 0($v0)        # store id
	sw $a1, 4($v0)        # store Title
	sw $a2, 8($v0)        # store Year
	sw $zero, 12($v0)     # store Status = 0 (available)
	sw $a3, 16($v0)      # store category_hdr
	sw $zero, 20($v0)     # store waitlist_head = 0

	move $v0, $v0        # return book* in v0
	
	jr   $ra

# --------------------- addBook ---------------------
# a0 = catalog_hdr
# a1 = book*
addBook:
	lw $t0, 8($a0)       # load count
	lw $t1, 4($a0)       # load capacity
	beq $t0, $t1, book_full  # if count == capacity, array full

	lw $t2, 0($a0)       # load array base address
	sll $t3, $t0, 2       # t3 = count * 4 (word size)
	add $t4, $t2, $t3     # t4 = address to store new book
	sw  $a1, 0($t4)       # store book* in array
	addi $t0, $t0, 1      # increment count
	sw $t0, 8($a0)        # store updated count

	li $v0, 4
	la $a0, msg_added_prefix	
	syscall
	li $v0, 4
	lw $a0, 4($a1)      # load title
	syscall
	li $v0, 4
	la $a0, nl
	syscall
	jr $ra

	book_full:
		li $v0, 4
		la $a0, msg_full
		syscall
		li $v0, 4
		la $a0, nl
		syscall
		jr  $ra

	
# --------------------- putOnWaitlistAt ---------------------
# a0 = catalog_hdr
# a1 = index
# a2 = name_ptr
putOnWaitlistAt:
	move $t0, $a0       # catalog_hdr

	li $v0, 9
	li $a0, 8           # size of waitlist node
	syscall
	move $t1, $v0       # t1 = new node*
	sw $a2, 0($t1)       # store name_ptr in node
	sw $zero, 4($t1)     # store next = 0 in node

	sll $t2, $a1, 2       # t2 = index * 4
	lw $t3, 0($t0)       # load array base address
	add $t3, $t3, $t2     # t3 = address of book* in array
	lw $t4, 0($t3)       # t4 = book*
	lw $t5, 20($t4)     # t5 = waitlist_head/node*
	beq $t5, $zero, wl_empty   # if waitlist_head == 0, empty list

	wl_not_empty:
		# traverse to end of waitlist
		move $t6, $t5       # t6 = current node
		loop_wl:
			lw $t7, 4($t6)     # t7 = next node
			beq $t7, $zero, wl_add  # if next == 0, at end
			move $t6, $t7       # move to next node
			j loop_wl
		wl_add:
			sw $t1, 4($t6)     # store new node at end
			j added_to_waitlist

	wl_empty:
		sw $t1, 20($t4)     # update waitlist_head to new node
		j added_to_waitlist

	added_to_waitlist:
		li $v0, 4
		la $a0, msg_wait_added
		syscall

		lw $t8, 4($t4)      # load title
		move $a0, $t8       # load title
		li   $v0, 4
		syscall


		li  $v0, 4
		la  $a0, left_arrow
		syscall

		move $a0, $a2       # load name_ptr
		li   $v0, 4
		syscall

		li $v0, 4
		la $a0, nl
		syscall

		jr   $ra

# --------------------- checkoutBookAt ---------------------
# a0 = catalog_hdr 
# a1 = index
checkoutBookAt:
	move $t0, $a0       # catalog_hdr

	sll $t1, $a1, 2       # t1 = index * 4
	lw $t2, 0($t0)       # load array base address
	add $t2, $t2, $t1     # t2 = address of book* in array
	lw $t3, 0($t2)       # t3 = book*

	lw $t4, 12($t3)     # t4 = status
	lw $t5, 20($t3)     # t5 = waitlist_head
	lw $t6, 4($t3)      # t6 = title

	bne $t4, $zero, book_already_loan  # if status != 0, already on loan
	beq $t5, $zero, book_no_waitlist   # if waitlist_head == 0, no waitlist

		# checkout to first person on waitlist
		lw $t7, 0($t5)       # t7 = name_ptr
		sw $t7, 12($t3)     # update status to name_ptr
		lw $t8, 4($t5)       # t8 = next node
		sw $t8, 20($t3)     # update waitlist_head to next node

		li $v0, 4
		la $a0, msg_checked_out
		syscall

		move $a0, $t6   # load title
		li   $v0, 4
		syscall

		li $v0, 4
		la $a0, arrow
		syscall

		move $a0, $t7   # load name_ptr
		li   $v0, 4
		syscall

		li $v0, 4
		la $a0, nl
		syscall

		jr   $ra

		
	book_already_loan:
		li $v0, 4
		la $a0, msg_already_for
		syscall

		move $a0, $t6   # load title
		li   $v0, 4
		syscall

		li $v0, 4
		la $a0, msg_held_by
		syscall

		move $a0, $t4   # load waitlist_head
		li   $v0, 4
		syscall

		li $v0, 4
		la $a0, nl
		syscall

		jr   $ra

	book_no_waitlist:
		li $v0, 4
		la $a0, msg_noholds_for
		syscall

		move $a0, $t6   # load title
		li   $v0, 4
		syscall

		li $v0, 4
		la $a0, nl
		syscall
		jr   $ra
	
# --------------------- returnBookAt ---------------------
# a0 = catalog_hdr
# a1 = index
returnBookAt:
	move $t0, $a0       # catalog_hdr

	sll $t1, $a1, 2       # t1 = index * 4
	lw $t2, 0($t0)       # load array base address
	add $t2, $t2, $t1     # t2 = address of book* in array
	lw $t3, 0($t2)       # t3 = book*

	lw $t4, 12($t3)     # t4 = status

	beq $t4, $zero, book_already_avail  # if status == 0, already available

		# make book available
		lw $t5, 12($t3)      # load name from status
		sw $zero, 12($t3)     # update status to 0 (available)

		li $v0, 4
		la $a0, msg_returned
		syscall

		lw $t6, 4($t3)      # load title
		move $a0, $t6       
		li   $v0, 4
		syscall

		li $v0, 4
		la $a0, left_arrow
		syscall

		move $a0, $t5       # load name from status
		li   $v0, 4
		syscall

		li $v0, 4
		la $a0, nl
		syscall

		jr   $ra

	

	book_already_avail:
		li $v0, 4
		la $a0, msg_already_avail
		syscall

		lw $t5, 4($t3)      # load title
		move $a0, $t5       # load title
		li   $v0, 4
		syscall

		li $v0, 4
		la $a0, nl
		syscall

		jr   $ra

# ====================== printBookList (calls printBook) ======================
# a0 = catalog_hdr
printBookList:
    subu $sp, $sp, 20
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)    # catalog_hdr 
    sw   $s1, 8($sp)    # count 
    sw   $s2, 12($sp)   # array pointer 
    sw   $s3, 16($sp)   # index (i) 

    move $s0, $a0             # s0 = catalog_hdr 
    
    li   $v0, 4
    la   $a0, msg_catalog_header
    syscall
    li   $v0, 4
    la   $a0, nl
    syscall

    lw   $s1, 8($s0)          # s1 = count ($t1 yerine $s1)
    beq  $s1, $zero, done_books # if count == 0, skip

    lw   $s2, 0($s0)          # s2 = array base address ($t2 yerine $s2)
    li   $s3, 0               # s3 = index ($t3 yerine $s3)

print_book_loop:
    lw   $a0, 0($s2)          # load book* at current index
    
    jal  printBook            

    li   $v0, 4
    la   $a0, nl
    syscall

    addi $s2, $s2, 4          # move to next book* pointer
    addi $s3, $s3, 1          # increment index
    
    blt  $s3, $s1, print_book_loop 

done_books:
    lw   $ra, 0($sp)
    lw   $s0, 4($sp)
    lw   $s1, 8($sp)
    lw   $s2, 12($sp)
    lw   $s3, 16($sp)
    addu $sp, $sp, 20         # deallocate stack space
    
    jr   $ra


# ====================== printBook (calls printCategories & printWaitlist) ======================
# a0 = book*
printBook:
	subu $sp, $sp, 4 
    sw   $ra, 0($sp)
   

	move $t9, $a0
	li $v0, 4
	la $a0, msg_title
	syscall
	lw $a0, 4($t9)      # load title
	li   $v0, 4
	syscall
	li $v0, 4
	la $a0, nl
	syscall

	li $v0, 4
	la $a0, msg_id
	syscall
	lw $a0, 0($t9)      # load id
	li   $v0, 1
	syscall

	li $v0, 4
	la $a0, msg_year
	syscall
	lw $a0, 8($t9)      # load year
	li   $v0, 1
	syscall
	li $v0, 4
	la $a0, nl
	syscall

	li $v0, 4
	la $a0, msg_status	
	syscall	
	lw $t1, 12($t9)     # load status
	beq $t1, $zero, book_available
		li $v0, 4
		la $a0, msg_loan
		syscall
		move $a0, $t1       # load name_ptr
		li   $v0, 4
		syscall
		li $v0, 4
		la $a0, nl
		syscall
		j print_cat_waitlist
	book_available:
		li $v0, 4
		la $a0, msg_avail
		syscall
	print_cat_waitlist:
		lw $a0, 16($t9)     # load category_hdr
		jal printCategories
		li $v0, 4
		la $a0, nl
		syscall

		lw $a0, 20($t9)     # load waitlist_head
		jal printWaitlist
		li $v0, 4
		la $a0, nl
		syscall

	li $v0, 4
	la $a0, msg_separator
	syscall

	lw $ra, 0($sp)
	addu $sp, $sp, 4

	jr   $ra


# ====================== printCategories(category_hdr*) ======================
# a0 = category_hdr
printCategories:
    move $t8, $a0           # t0 = category_hdr

    li   $v0, 4
    la   $a0, msg_categories
    syscall

    lw   $t1, 8($t8)        # count
    beq  $t1, $zero, no_categories

    lw   $t2, 0($t8)        # base array address
    li   $t3, 0              # index

print_cat_loop:
    lw   $a0, 0($t2)        # load category str_ptr
    li   $v0, 4
    syscall

	addi $t2, $t2, 4         # next category*
    addi $t3, $t3, 1		 # increment index

	beq  $t3, $t1, end_print_cat # if index == count, end loop

    li   $v0, 4
    la   $a0, comma_space
    syscall

    
    blt  $t3, $t1, print_cat_loop

end_print_cat:
	jr   $ra

no_categories:
    li $v0, 4
    la $a0, msg_nonecats
    syscall
    jr   $ra



# ====================== printWaitlist(waitlist_head*) ======================
# a0 = head (node* or 0)
printWaitlist:
    move $t7, $a0          # t0 = current node

    li   $v0, 4
    la   $a0, msg_wait
    syscall

    beq  $t7, $zero, wl_empty_print

wl_print_loop:
    lw   $a0, 0($t7)        # load name_ptr
    li   $v0, 4
    syscall

	lw   $t7, 4($t7) 	   # move to next node
	beq  $t7, $zero, wl_print_done

    li   $v0, 4
    la   $a0, arrow
    syscall

    bne  $t7, $zero, wl_print_loop

wl_print_done:
	jr   $ra

wl_empty_print:
    li   $v0, 4
    la   $a0, empty_wl
    syscall
    jr   $ra



# ====================== MAIN ======================
main:
	# Create and fill the catalog
	jal  initBookArray
	move $s0, $v0

	jal  initCategoryArray
	move $s1, $v0
	move $a0, $s1
	la   $a1, c_prog
	jal  putOnCategory
	move $a0, $s1
	la   $a1, c_best
	jal  putOnCategory
	move $a0, $s1
	la   $a1, c_edu
	jal  putOnCategory
	li   $a0, 123
	la   $a1, t_clean
	li   $a2, 1999
	move $a3, $s1
	jal  createBook
	move $a0, $s0
	move $a1, $v0
	jal  addBook

	jal  initCategoryArray
	move $s1, $v0
	move $a0, $s1
	la   $a1, c_sys
	jal  putOnCategory
	move $a0, $s1
	la   $a1, c_edu
	jal  putOnCategory
	li   $a0, 55
	la   $a1, t_os
	li   $a2, 2014
	move $a3, $s1
	jal  createBook
	move $a0, $s0
	move $a1, $v0
	jal  addBook

	jal  initCategoryArray
	move $s1, $v0
	move $a0, $s1
	la   $a1, c_net
	jal  putOnCategory
	move $a0, $s1
	la   $a1, c_edu
	jal  putOnCategory
	li   $a0, 310
	la   $a1, t_net
	li   $a2, 2011
	move $a3, $s1
	jal  createBook
	move $a0, $s0
	move $a1, $v0
	jal  addBook

	# Set up waitlists
	move $a0, $s0
	li   $a1, 0
	la   $a2, p_Alice
	jal  putOnWaitlistAt
	move $a0, $s0
	li   $a1, 0
	la   $a2, p_Bob
	jal  putOnWaitlistAt
	move $a0, $s0
	li   $a1, 0
	la   $a2, p_Charlie
	jal  putOnWaitlistAt
	move $a0, $s0
	li   $a1, 0
	la   $a2, p_David
	jal  putOnWaitlistAt
	move $a0, $s0
	li   $a1, 0
	la   $a2, p_Emma
	jal  putOnWaitlistAt

	move $a0, $s0
	li   $a1, 1
	la   $a2, p_Jane
	jal  putOnWaitlistAt
	move $a0, $s0
	li   $a1, 1
	la   $a2, p_Grace
	jal  putOnWaitlistAt
	move $a0, $s0
	li   $a1, 1
	la   $a2, p_Henry
	jal  putOnWaitlistAt

	move $a0, $s0
	li   $a1, 2
	la   $a2, p_Jack
	jal  putOnWaitlistAt
	move $a0, $s0
	li   $a1, 2
	la   $a2, p_Kate
	jal  putOnWaitlistAt
	move $a0, $s0
	li   $a1, 2
	la   $a2, p_Liam
	jal  putOnWaitlistAt
	move $a0, $s0
	li   $a1, 2
	la   $a2, p_Isla
	jal  putOnWaitlistAt
	move $a0, $s0
	li   $a1, 2
	la   $a2, p_Frank
	jal  putOnWaitlistAt

	# Initial full view
	move $a0, $s0
	jal  printBookList

	# Batch A: checkout #0, checkout #1, return #2, then print once
	move $a0, $s0
	li   $a1, 0
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 1
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 2
	jal  returnBookAt
	move $a0, $s0
	jal  printBookList

	# Batch B: checkout #2, checkout #0, return #1, then print once
	move $a0, $s0
	li   $a1, 2
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 0
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 1
	jal  returnBookAt
	move $a0, $s0
	jal  printBookList

	# Batch C: return #0, checkout #1, checkout #2, then print once
	move $a0, $s0
	li   $a1, 0
	jal  returnBookAt
	move $a0, $s0
	li   $a1, 1
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 2
	jal  checkoutBookAt
	move $a0, $s0
	jal  printBookList

	# Batch D: return #2, checkout #0, checkout #1, return #0, then print once
	move $a0, $s0
	li   $a1, 2
	jal  returnBookAt
	move $a0, $s0
	li   $a1, 0
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 1
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 0
	jal  returnBookAt
	move $a0, $s0
	jal  printBookList

	# Batch E: checkout #0, return #1, checkout #2, return #2, checkout #1, then print once
	move $a0, $s0
	li   $a1, 0
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 1
	jal  returnBookAt
	move $a0, $s0
	li   $a1, 2
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 2
	jal  returnBookAt
	move $a0, $s0
	li   $a1, 1
	jal  checkoutBookAt
	move $a0, $s0
	jal  printBookList

	# Batch F: final shuffle — return #0, checkout #0, checkout #2, return #1, checkout #1, then print once
	move $a0, $s0
	li   $a1, 0
	jal  returnBookAt
	move $a0, $s0
	li   $a1, 0
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 2
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 1
	jal  returnBookAt
	move $a0, $s0
    li   $a1, 1
    jal  checkoutBookAt
	move $a0, $s0
	jal  printBookList

	li   $v0, 10
	syscall