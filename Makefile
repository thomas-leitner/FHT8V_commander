###########################################################
# AVR top-level Makefile
#
# $Revision$
# $Author$
# $Date$
###########################################################
# $Id$
# $HeadURL$
###########################################################


# MCU name
MCU = atmega328
MCU_dude = atmega328p # m328p # HB


# Fuse settings
# EXT - 0x06
# BODLEVEL[2:0] = 6 (1.8 V)
#
# HIGH - 0xd9
# RSTDISBL = 1 (external reset enabled)
# DWEN = 1 (debugwire disabled)
# SPIEN = 0 (SPI programming enabled)
# WDTON = 1 (WDT not forced on)
# EESAVE = 1 (EEPROM not preserved through programming)
# BOOTSZ[1:0] = 0 (1K)
# BOOTRST = 1 (normal reset vector)
#
# LOW - 0xd2
# CKDIV8 = 1 (don't divide clock by 8)
# CKOUT = 1 (disable clock output)
# SUT[1:0] = 1 (BOD enabled)
# CKSEL[3:0] = 2 (internal 8 MHz oscillator)
# 
FUSES_EXT = 0x06
FUSES_HIGH = 0xd9
FUSES_LOW = 0xd2

# Target clock frequency (Hz)
CLOCK = 8000000

# Programmer type
#PROG = avrispv2 # HB
PROG = stk500v1 # HB
# Programmer port
PROGPORT = /dev/tty.SLAB_USBtoUART
# AVRDUDE extra flags
AVRDUDEFLAGS = -v -v -v -b19200

# Output format. (can be srec, ihex, binary)
FORMAT = ihex

# Target file name (without extension).
TARGET = fhtexample

# List C source files here. (C dependencies are automatically generated.)
SRC = main.c debug.c si443x_min.c fht.c cli.c fht_eeprom.c temp.c

# List Assembler source files here.
# Make them always end in a capital .S.  Files ending in a lowercase .s
# will not be considered source files but generated files (assembler
# output from the compiler), and will be deleted upon "make clean"!
# Even though the DOS/Win* filesystem matches both .s and .S the same,
# it will preserve the spelling of the filenames, and gcc itself does
# care about how the name is spelled on its command-line.
ASRC = 

# Optimization level, can be [0, 1, 2, 3, s]. 
# 0 = turn off optimization. s = optimize for size.
# (Note: 3 is not always the best optimization level. See avr-libc FAQ.)
OPT = s

# List any extra directories to look for include files here.
#     Each directory must be seperated by a space.
EXTRAINCDIRS = 

# Compiler flag to set the C Standard level.
CSTANDARD_C89 = c89
CSTANDARD_GNU89 = gnu89
CSTANDARD_C99 = c99
CSTANDARD_GNU99 = gnu99
CSTANDARD = -std=$(CSTANDARD_GNU99)



# Compiler flags.
#  -g:           generate debugging information
#  -O*:          optimization level
#  -f...:        tuning, see GCC manual and avr-libc documentation
#  -Wall...:     warning level
#  -Wa,...:      tell GCC to pass this to the assembler.
#    -adhlns...: create assembler listing
CFLAGS = -g
CFLAGS += -O$(OPT)
CFLAGS += -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums
CFLAGS += -Wall -Wstrict-prototypes
CFLAGS += -Wa,-adhlns=$(<:.c=.lst)
CFLAGS += $(patsubst %,-I%,$(EXTRAINCDIRS))
CFLAGS += $(CSTANDARD)
CFLAGS += -DF_CPU=$(CLOCK)
CFLAGS += -DDEBUG=1



# Assembler flags.
#  -Wa,...:   tell GCC to pass this to the assembler.
#  -ahlms:    create listing
#  -gstabs:   have the assembler create line number information; note that
#             for use in COFF files, additional information about filenames
#             and function names needs to be present in the assembler source
#             files -- see avr-libc docs [FIXME: not yet described there]
ASFLAGS = -Wa,-adhlns=$(<:.S=.lst),-gstabs 



#Additional libraries.

PRINTF_LIB_NONE = 

# Minimalistic printf version
PRINTF_LIB_MIN = -Wl,-u,vfprintf -lprintf_min

# Floating point printf version (requires MATH_LIB = -lm below)
PRINTF_LIB_FLOAT = -Wl,-u,vfprintf -lprintf_flt

PRINTF_LIB = $(PRINTF_LIB_MIN)

MATH_LIB = -lm



# Linker flags.
#  -Wl,...:     tell GCC to pass this to linker.
#    -Map:      create map file
#    --cref:    add cross reference to  map file
LDFLAGS = -Wl,-Map=$(TARGET).map,--cref $(PRINTF_LIB) $(MATH_LIB)



# Output directory for Doxygen documentation
# (must match Doxyfile configuration)
DOCSDIR = docs

# Define programs and commands.
SHELL = sh
CC = avr-gcc
OBJCOPY = avr-objcopy
OBJDUMP = avr-objdump
SIZE = avr-size
NM = avr-nm
AVRDUDE = avrdude
REMOVE = rm -rf
COPY = cp
DOXYGEN = doxygen




# Define Messages
# English
MSG_ERRORS_NONE = Errors: none
MSG_BEGIN = -------- begin --------
MSG_END = --------  end  --------
MSG_SIZE_BEFORE = Size before: 
MSG_SIZE_AFTER = Size after:
MSG_COFF = Converting to AVR COFF:
MSG_EXTENDED_COFF = Converting to AVR Extended COFF:
MSG_FLASH = Creating load file for Flash:
MSG_EEPROM = Creating load file for EEPROM:
MSG_EXTENDED_LISTING = Creating Extended Listing:
MSG_SYMBOL_TABLE = Creating Symbol Table:
MSG_LINKING = Linking:
MSG_COMPILING = Compiling:
MSG_ASSEMBLING = Assembling:
MSG_CLEANING = Cleaning project:
MSG_DOCS = Generating documentation


# Define all object files.
OBJ = $(SRC:.c=.o) $(ASRC:.S=.o) 

# Define all listing files.
LST = $(ASRC:.S=.lst) $(SRC:.c=.lst)


# Compiler flags to generate dependency files.
GENDEPFLAGS = -Wp,-M,-MP,-MT,$(*F).o,-MF,.dep/$(@F).d


# Combine all necessary flags and optional flags.
# Add target processor to flags.
ALL_CFLAGS = -mmcu=$(MCU) -I. $(CFLAGS) $(GENDEPFLAGS)
ALL_ASFLAGS = -mmcu=$(MCU) -I. -x assembler-with-cpp $(ASFLAGS)


# Default target.
all: gccversion sizebefore build sizeafter

#build: elf hex eep lss sym
build: elf hex lss sym

elf: $(TARGET).elf
hex: $(TARGET).hex
eep: $(TARGET).eep
lss: $(TARGET).lss 
sym: $(TARGET).sym


# Display size of file.
HEXSIZE = $(SIZE) --target=$(FORMAT) $(TARGET).hex
ELFSIZE = $(SIZE) -A $(TARGET).elf
sizebefore:
	@if [ -f $(TARGET).elf ]; then echo; echo $(MSG_SIZE_BEFORE); $(ELFSIZE); echo; fi

sizeafter:
	@if [ -f $(TARGET).elf ]; then echo; echo $(MSG_SIZE_AFTER); $(ELFSIZE); echo; fi



# Display compiler version information.
gccversion: 
	@$(CC) --version


# Program the fuses
program_fuses:
	$(AVRDUDE) -p $(MCU_dude) -c $(PROG) -P $(PROGPORT) $(AVRDUDEFLAGS) -U efuse:w:$(FUSES_EXT):m
	$(AVRDUDE) -p $(MCU_dude) -c $(PROG) -P $(PROGPORT) $(AVRDUDEFLAGS) -U hfuse:w:$(FUSES_HIGH):m
	$(AVRDUDE) -p $(MCU_dude) -c $(PROG) -P $(PROGPORT) $(AVRDUDEFLAGS) -U lfuse:w:$(FUSES_LOW):m

# Program the flash.  
program_flash: $(TARGET).hex
	$(AVRDUDE) -p $(MCU_dude) -c $(PROG) -P $(PROGPORT) $(AVRDUDEFLAGS) -U flash:w:$(TARGET).hex

# Program the EEPROM
program_eeprom: $(TARGET).eep
	$(AVRDUDE) -p $(MCU_dude) -c $(PROG) -P $(PROGPORT) $(AVRDUDEFLAGS) -U eeprom:w:$(TARGET).eep

# Program all
#program: program_fuses program_flash program_eeprom
program: program_fuses program_flash

# Convert ELF to COFF for use in debugging / simulating in AVR Studio or VMLAB.
COFFCONVERT=$(OBJCOPY) --debugging \
--change-section-address .data-0x800000 \
--change-section-address .bss-0x800000 \
--change-section-address .noinit-0x800000 \
--change-section-address .eeprom-0x810000 


coff: $(TARGET).elf
	@echo
	@echo $(MSG_COFF) $(TARGET).cof
	$(COFFCONVERT) -O coff-avr $< $(TARGET).cof


extcoff: $(TARGET).elf
	@echo
	@echo $(MSG_EXTENDED_COFF) $(TARGET).cof
	$(COFFCONVERT) -O coff-ext-avr $< $(TARGET).cof



# Create final output files (.hex, .eep) from ELF output file.
%.hex: %.elf
	@echo
	@echo $(MSG_FLASH) $@
	$(OBJCOPY) -O $(FORMAT) -R .eeprom $< $@

%.eep: %.elf
	@echo
	@echo $(MSG_EEPROM) $@
	-$(OBJCOPY) -j .eeprom --set-section-flags=.eeprom="alloc,load" \
	--change-section-lma .eeprom=0 -O $(FORMAT) $< $@

# Create extended listing file from ELF output file.
%.lss: %.elf
	@echo
	@echo $(MSG_EXTENDED_LISTING) $@
	$(OBJDUMP) -h -S $< > $@

# Create a symbol table from ELF output file.
%.sym: %.elf
	@echo
	@echo $(MSG_SYMBOL_TABLE) $@
	$(NM) -n $< > $@



# Link: create ELF output file from object files.
.SECONDARY: $(TARGET).elf
.PRECIOUS: $(OBJ)
%.elf: $(OBJ)
	@echo
	@echo $(MSG_LINKING) $@
	$(CC) $(ALL_CFLAGS) $(OBJ) --output $@ $(LDFLAGS)


# Compile: create object files from C source files.
%.o: %.c
	@echo
	@echo $(MSG_COMPILING) $<
	$(CC) -c $(ALL_CFLAGS) $< -o $@ 


# Compile: create assembler files from C source files.
%.s: %.c
	$(CC) -S $(ALL_CFLAGS) $< -o $@


# Assemble: create object files from assembler source files.
%.o: %.S
	@echo
	@echo $(MSG_ASSEMBLING) $<
	$(CC) -c $(ALL_ASFLAGS) $< -o $@

version.o: FORCE

# Create Doxygen documentation
docs:
	@echo
	@echo $(MSG_DOCS)
	$(DOXYGEN) 
	

# Target: clean project.
clean: clean_list

clean_list:
	@echo
	@echo $(MSG_CLEANING)
	$(REMOVE) $(TARGET).hex
	$(REMOVE) $(TARGET).eep
	$(REMOVE) $(TARGET).obj
	$(REMOVE) $(TARGET).cof
	$(REMOVE) $(TARGET).elf
	$(REMOVE) $(TARGET).map
	$(REMOVE) $(TARGET).obj
	$(REMOVE) $(TARGET).a90
	$(REMOVE) $(TARGET).sym
	$(REMOVE) $(TARGET).lnk
	$(REMOVE) $(TARGET).lss
	$(REMOVE) $(OBJ)
	$(REMOVE) $(LST)
	$(REMOVE) $(SRC:.c=.s)
	$(REMOVE) $(SRC:.c=.d)
	$(REMOVE) .dep
	$(REMOVE) $(DOCSDIR)


# Include the dependency files.
-include $(shell mkdir .dep 2>/dev/null) $(wildcard .dep/*)


# Listing of phony targets.
.PHONY: all sizebefore sizeafter gccversion \
build elf hex eep lss sym coff extcoff \
clean clean_list program docs \
FORCE

