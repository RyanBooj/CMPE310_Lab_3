proj3: proj3.lst
	gcc -m32 proj3.o -o proj3
	
proj3.lst: proj3.asm
	nasm -g -f elf -F dwarf proj3.asm

cfunctions: cfunctions.lst
	gcc -m32 cfunctions.o -o cfunctions
	
cfunctions.lst: cfunctions.asm
	nasm -f elf cfunctions.asm
	
debug:
	gdb -tui --args proj3 input.txt