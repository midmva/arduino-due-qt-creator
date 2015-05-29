#!/usr/bin/make
# makefile for the arduino due whith using FreeRTOS.
# 
# modified for Ubuntu
#
#
# USAGE: put this file in the same dir as your .ino file is.
# configure the PORT variable and ADIR at the top of the file
# to match your local configuration.
# Type make upload to compile and upload.
# Type make monitor to watch the serial port with gnu screen.
#
# TODO: split into user specific settings and the rest
#
# LICENSE: GPLv2 or later (at your option)
#
# This file can be found at https://github.com/pauldreik/arduino-due-makefile
#
# By Paul Dreik 20130503 http://www.pauldreik.se/

#user specific settings:
#where to find the IDE
ADIR:=%ARDUINO_DIR%
#ADIR:=/home/midv/Arduino

#where to find the Libraries
LIBDIR:=%ARDUINO_LIBS%
LIBDIR:+=$(ADIR)/libraries

#where to find the hardware
HWDIR:=$(ADIR)/hardware
#where to find the Tools
TOOLSDIR:=$(HWDIR)/tools
#where to find the Compilator for ARM
COMPDIR:=$(TOOLSDIR)/arm-none-eabi-gcc/bin
#which serial port to use
PORT:=%ARDUINO_PORT%
#PORT:=/dev/ttyACM0
#if we want to verify the bossac upload, define this to -v
VERIFY:=-v


#then some general settings. They should not be necessary to modify.
CXX:=$(COMPDIR)/arm-none-eabi-g++
CC:=$(COMPDIR)/arm-none-eabi-gcc
C:=$(CC)
AR:=$(COMPDIR)/arm-none-eabi-ar
SAM:=/arduino/sam
CMSIS:=/arduino/sam/system/CMSIS
LIBSAM:=/arduino/sam/system/libsam
# for windows, we compile in an subdirectory of the current dir. oooh, always run from the same place...:
TMPDIR:=$(PWD)/build



#all these values are hard coded and should maybe be configured somehow else,
#like olikraus does in his makefile.
DEFINES:=-Dprintf=iprintf -DF_CPU=84000000L -DARDUINO=152 -D__SAM3X8E__ -DUSB_PID=0x003e -DUSB_VID=0x2341 -DUSBCON

# where are included header files. we use the local directory for '#include "..."', while '#include <...> goes to the specified directories. The Arduino IDE include LIBSAM, but not  LIBSAM/Include saving a lot of trouble - udp.h from Atmel seems to be broken (it is nearly empty) thus leading to compile errors. by not including LIBSAM/Include the compiler finds the correct udp.h. thsu, we omit LIBSAM/Include as well.
INCLUDES:=-iquote. 
INCLUDES+=-I$(HWDIR)/$(LIBSAM)
INCLUDES+=-I$(HWDIR)/$(CMSIS)/CMSIS/Include/
INCLUDES+=-I$(HWDIR)/$(CMSIS)/Device/ATMEL/
INCLUDES+=-I$(HWDIR)/$(SAM)/cores/arduino
INCLUDES+=-I$(HWDIR)/$(SAM)/variants/arduino_due_x
INCLUDES+=-I$(HWDIR)/$(SAM)/libraries/SPI
INCLUDES+=-I$(HWDIR)/$(SAM)/cores/arduino/avr
INCLUDES+=-I$(LIBDIR)/FreeRTOS_ARM
INCLUDES+=-I$(LIBDIR)/FreeRTOS_ARM/utility


#compilation flags common to both c and c++
# replace -w with -v if you want to get a talkative compiler
COMMON_FLAGS:=-g -Os -w -ffunction-sections -fdata-sections -nostdlib --param max-inline-insns-single=500 -mcpu=cortex-m3 -mthumb

CFLAGS:=$(COMMON_FLAGS)
CXXFLAGS:=$(COMMON_FLAGS) -fno-rtti -fno-exceptions

#let the results be named after the project
PROJNAME:=$(shell basename *.pro .pro)

#we will make a new mainfile from the ino file.
NEWMAINFILE:=$(TMPDIR)/$(PROJNAME).ino.cpp

#our own sourcefiles is the (converted) ino file and any local cpp files
MYSRCFILES:=$(NEWMAINFILE) $(shell ls *.cpp 2>/dev/null)
MYOBJFILES:=$(addsuffix .o,$(addprefix $(TMPDIR)/,$(notdir $(MYSRCFILES))))

#These source files are the ones forming core.a
CORESRCXX:=$(shell ls ${HWDIR}/${SAM}/cores/arduino/*.cpp)
CORESRCXX-=$(shell ls ${HWDIR}/${SAM}/cores/arduino/main.cpp)
CORESRCXX+=$(shell ls ${HWDIR}/${SAM}/cores/arduino/USB/*.cpp)
CORESRCXX+=$(shell ls ${HWDIR}/${SAM}/libraries/SPI/*.cpp)
CORESRCXX+=$(shell ls ${HWDIR}/${SAM}/variants/arduino_due_x/variant.cpp)
CORESRCXX+=$(shell ls ${LIBDIR}/FreeRTOS_ARM/*.cpp)
CORESRC:=$(shell ls ${HWDIR}/${SAM}/cores/arduino/*.c)
CORESRC+=$(shell ls ${HWDIR}/${SAM}/cores/arduino/avr/*.c)
CORESRC+=$(shell ls ${LIBDIR}/FreeRTOS_ARM/*.c)
CORESRC+=$(shell ls ${LIBDIR}/FreeRTOS_ARM/utility/*.c)


#convert the core source files to object files. assume no clashes.
COREOBJSXX:=$(addprefix $(TMPDIR)/core/,$(notdir $(CORESRCXX)) )
COREOBJSXX:=$(addsuffix .o,$(COREOBJSXX))
COREOBJS:=$(addprefix $(TMPDIR)/core/,$(notdir $(CORESRC)) )
COREOBJS:=$(addsuffix .o,$(COREOBJS))

default:
	@echo default rule, does nothing. Try make compile or make upload.

#This rule is good to just make sure stuff compiles, without having to wait
#for bossac.
compile: $(TMPDIR)/$(PROJNAME).elf

#This is a make rule template to create object files from the source files.
# arg 1=src file
# arg 2=object file
# arg 3= XX if c++, empty if c
define OBJ_template
$(2): $(1)
	$(C$(3)) -MD -c $(C$(3)FLAGS) $(DEFINES) $(INCLUDES) $(1) -o $(2)
endef
#now invoke the template both for c++ sources
$(foreach src,$(CORESRCXX), $(eval $(call OBJ_template,$(src),$(addsuffix .o,$(addprefix $(TMPDIR)/core/,$(notdir $(src)))),XX) ) )
#...and for c sources:
$(foreach src,$(CORESRC), $(eval $(call OBJ_template,$(src),$(addsuffix .o,$(addprefix $(TMPDIR)/core/,$(notdir $(src)))),) ) )

#and our own c++ sources
$(foreach src,$(MYSRCFILES), $(eval $(call OBJ_template,$(src),$(addsuffix .o,$(addprefix $(TMPDIR)/,$(notdir $(src)))),XX) ) )


clean:
	test ! -d $(TMPDIR) || rm -rf $(TMPDIR)

.PHONY: upload default

$(TMPDIR):
	mkdir -p $(TMPDIR)

$(TMPDIR)/core:
	mkdir -p $(TMPDIR)/core

#creates the cpp file from the .ino file
$(NEWMAINFILE): $(PROJNAME).pro
	cat /home/midv/Projects/untitled/src/main.cpp > $(NEWMAINFILE)
	echo 'extern "C" void __cxa_pure_virtual() {while (true);}' >> $(NEWMAINFILE)

#include the dependencies for our own files
-include $(MYOBJFILES:.o=.d)

#create the core library from the core objects. Do this EXACTLY as the
#arduino IDE does it, seems *really* picky about this.
#Sorry for the hard coding.
$(TMPDIR)/core.a: $(TMPDIR)/core $(COREOBJS) $(COREOBJSXX)
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/FreeRTOS_ARM.c.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/basic_io_arm.cpp.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/assertMsg.cpp.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/event_groups.c.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/queue.c.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/heap_3.c.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/timers.c.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/tasks.c.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/port.c.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/croutine.c.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/list.c.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/wiring_shift.c.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/wiring_analog.c.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/itoa.c.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/cortex_handlers.c.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/hooks.c.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/wiring.c.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/WInterrupts.c.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/syscalls_sam3.c.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/iar_calls_sam3.c.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/wiring_digital.c.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/dtostrf.c.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/Print.cpp.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/USARTClass.cpp.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/WString.cpp.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/USBCore.cpp.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/CDC.cpp.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/HID.cpp.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/wiring_pulse.cpp.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/UARTClass.cpp.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/main.cpp.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/abi.cpp.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/Stream.cpp.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/RingBuffer.cpp.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/IPAddress.cpp.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/Reset.cpp.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/WMath.cpp.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/variant.cpp.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/SPI.cpp.o
	$(AR) rcs $(TMPDIR)/core.a $(TMPDIR)/core/new.cpp.o
	
#link our own object files with core to form the elf file
$(TMPDIR)/$(PROJNAME).elf: $(TMPDIR)/core.a $(TMPDIR)/core/syscalls_sam3.c.o $(MYOBJFILES)
	$(CXX) -Os -Wl,--gc-sections -mcpu=cortex-m3 -T$(HWDIR)/$(SAM)/variants/arduino_due_x/linker_scripts/gcc/flash.ld -Wl,-Map,$(NEWMAINFILE).map -o $@ -L$(TMPDIR) -lm -lgcc -mthumb -Wl,--cref -Wl,--check-sections -Wl,--gc-sections -Wl,--entry=Reset_Handler -Wl,--unresolved-symbols=report-all -Wl,--warn-common -Wl,--warn-section-align -Wl,--warn-unresolved-symbols -Wl,--start-group $(TMPDIR)/core/syscalls_sam3.c.o $(MYOBJFILES) $(HWDIR)/$(SAM)/variants/arduino_due_x/libsam_sam3x8e_gcc_rel.a $(TMPDIR)/core.a -Wl,--end-group


#copy from the hex to our bin file (why?)
$(TMPDIR)/$(PROJNAME).bin: $(TMPDIR)/$(PROJNAME).elf
	$(COMPDIR)/arm-none-eabi-objcopy -O binary $< $@


#upload to the arduino by first resetting it (stty) and the running bossac
upload: $(TMPDIR)/$(PROJNAME).bin
	stty -F $(PORT) cs8 1200 hupcl
# above is the unix command, for windows the following will work:
	$(TOOLSDIR)/bossac/1.3a-arduino/bossac -U false -e -w $(VERIFY) -b $(TMPDIR)/$(PROJNAME).bin -R




#to view the serial port with screen.
monitor:
	screen $(PORT) 115200

