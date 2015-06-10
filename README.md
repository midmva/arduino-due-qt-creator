# arduino-due-qt-creator
It's templates wizard for fast create project for board Arduino DUE (on ARM CortexM3 ATSAM3X8E controller based) with using the Qt Creator(with or without using FreeRTOS) .
Template based on the Makefile for ARM and based on the QBS.(4 templates)

Prepare to work: install Arduino IDE with support Arduino DUE, install Qt Creator

Connect your Arduino board in the Programming port (with use Native port you needed clear and reset your devise manually)

Copy this templates in (path-to-qt)/Tools/QtCreator/share/qtcreator/templates/wizards/

If you work with FreeRTOS, download port FreeRTOS for Arduino DUE and copy dir FreeRTOS-ARM in (path-to-arduino)/libraries

Copy(or move) contents (home-dir)/.arduino15/packages/arduino/hardware/sam/1.6.4/ in (path-to-arduino)/hardware/arduino/sam

Copy(or move) contents (home-dir)/.arduino15/packages/arduino/tools/ in (path-to-arduino)/hardware/tools

After that run QtCreator, choose newFile>ARM

Choose string with needed configuration and press Choose

After that write the path whith Arduino IDE, Arduino libraries and Arduino port (for example "/dev/ttyACM0")

This templates containts blink project.

Press "Run" for generate %yourProjectName%.bin file.

If You will send .bin file to Arduino DUE, write to Qt progect install settings command "stty -F %Your-Arduino-port% cs8 1200 hupcl" and write to Qt progect run settings (path-to-arduino)/hardware/tools/bossac/1.3a-arduino/bossac -U false -e -w -v -b %yourProjectName%.bin -R

This templates make with using github/pauldreik/arduino-due-makefile project and github/cleitonsouza01/qt-creator-arduino project

Tested in Arduino IDE 1.6.4 with Qt Creator 3.3.1
