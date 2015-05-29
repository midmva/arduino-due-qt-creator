# arduino-due-qt-creator
templates wizard for fast create project
copy this templates in path_to_qt/Tools/QtCreator/share/qtcreator/templates/wizards/
for work you need to install arduino ide whith support Arduino Due
if you work with freertos, download port and copy dir FreeRTOS_ARM in (path_arduino)/libraries
Copy(or move) contents (home_dir)/.arduino15/packages/arduino/hardware/sam/1.6.4/ in (path_to_arduino)/hardware/arduino/sam
Copy(or move) contents (home_dir)/.arduino15/packages/arduino/tools/ in (path_to_arduino)/hardware/tools
After that run QtCreator choose newFile>ARM
Choose string with needed configuration and press Choose
After that write the path whith Arduino IDE and Arduino libraries

This templates containts blink project.

This templates make with using github/pauldreik/arduino-due-makefile project and github/cleitonsouza01/qt-creator-arduino project
