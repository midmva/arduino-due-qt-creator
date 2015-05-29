# arduino-due-qt-creator
templates wizard for fast create project for board Arduino DUE whith using the Qt Creator

Connect your Arduino board in the Programming port (with use Native port you needed clear and reset your devise manually)
Copy this templates in path_to_qt/Tools/QtCreator/share/qtcreator/templates/wizards/
For work you need to install arduino ide whith support Arduino Due.
If you work with freertos, download port and copy dir FreeRTOS-ARM in (path-arduino)/libraries
Copy(or move) contents (home-dir)/.arduino15/packages/arduino/hardware/sam/1.6.4/ in (path-to-arduino)/hardware/arduino/sam
Copy(or move) contents (home-dir)/.arduino15/packages/arduino/tools/ in (path-to-arduino)/hardware/tools
After that run QtCreator choose newFile>ARM
Choose string with needed configuration and press Choose
After that write the path whith Arduino IDE and Arduino libraries

This templates containts blink project.

This templates make with using github/pauldreik/arduino-due-makefile project and github/cleitonsouza01/qt-creator-arduino project
