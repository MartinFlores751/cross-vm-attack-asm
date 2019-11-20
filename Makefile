# Default target creates non debug versions
all: receiver sender

# Debug target creates debugable versions of the normal targets
debug: receiver-debug sender-debug

### Normal Compilation stuff...
receiver : receiver.o
	  gcc -m32 -lpthread -o receiver receiver.o

receiver.o : receiver.asm
	    nasm -f elf32 receiver.asm

sender : sender.o
	gcc -m32 -lpthread -o sender sender.o

sender.o : sender.asm
	  nasm -f elf32 sender.asm

### Debug Targets
receiver-debug : receiver-debug.o
		gcc -m32 -lpthread -g -o receiver-debug receiver-debug.o

receiver-debug.o : receiver.asm
		  nasm -f elf32 -gdwarf -o receiver-debug.o receiver.asm 

sender-debug : sender-debug.o
		gcc -m32 -lpthread -g -o sender-debug sender-debug.o

sender-debug.o : sender.asm
		nasm -f elf32 -gdwarf -o sender-debug.o sender.asm

# Proper(?) clean target
.PHONY : clean
clean :
	-rm sender receiver sender.o receiver.o receiver-debug receiver-debug.o sender-debug sender-debug.o
