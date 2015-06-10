import qbs
Project{
    Product {
        type: "bin"
        Depends{name:"cpp"}
        property string arduinoPath: "%ARDUINO_DIR%"
        property string hardwarePath: arduinoPath + "hardware/"
        property string toolsPath: hardwarePath + "tools/"
        property string libraryPath: "/opt/Arduino/libraries/"
        property string compPath: toolsPath + "arm-none-eabi-gcc/bin/"
        property string SAM: "arduino/sam/"
        property string CMSIS: "arduino/sam/system/CMSIS/"
        property string LibSAM: "arduino/sam/system/libsam/"
        property var includePaths: [
            "src/",
            hardwarePath+LibSAM,
            hardwarePath+CMSIS+"CMSIS/Include/",
            hardwarePath+CMSIS+"Device/ATMEL/",
            hardwarePath+SAM+"cores/arduino/",
            hardwarePath+SAM+"cores/arduino/USB/",
            hardwarePath+SAM+"variants/arduino_due_x/",
            hardwarePath+SAM+"libraries/SPI/",
            hardwarePath+SAM+"cores/arduino/avr/",
        ]
        cpp.includePaths: includePaths
        property var defines: [
            "printf=iprintf ",
            "F_CPU=84000000L",
            "ARDUINO=10604",
            "ARDUINO_SAM_DUE",
            "ARDUINO_ARCH_SAM",
            "__SAM3X8E__",
            "USB_VID=0x2341",
            "USB_PID=0x003e",
            "USBCON",
            "USB_MANUFACTURER=\"Unknown\"",
            "USB_PRODUCT=\"Arduino Due\""
        ]

        property var compilerFlags: [
            "-c",
            "-g",
            "-Os",
            "-w",
            "-ffunction-sections",
            "-fdata-sections",
            "-nostdlib",
            "-fno-threadsafe-statics",
            "--param",
            "max-inline-insns-single=500",
            "-fno-rtti",
            "-fno-exceptions",
            "-MMD",
            "-mcpu=cortex-m3",
            "-mthumb"
        ]

        Group {
            name: "sources"
            prefix: includePaths[0]
            files: ["*.c","*.cpp"]
            fileTags: ['s']
        }
        Group {
            name: "LibSAM"
            prefix: includePaths[1]
            files: ["*.c","*.cpp"]
            fileTags: ['s']
        }
        Group {
            name: "CMSIS_Inc"
            prefix: includePaths[2]
            files: ["*.c","*.cpp"]
            fileTags: ['s']
        }
        Group {
            name: "CMSIS_Atmel"
            prefix: includePaths[3]
            files: ["*.c","*.cpp"]
            fileTags: ['s']
        }

        Group {
            name: "Arduino"
            prefix: includePaths[4]
            files: ["*.c","*.cpp"]
            fileTags: ['s']
        }
        Group {
            name: "USB"
            prefix: includePaths[5]
            files: ["*.c","*.cpp"]
            fileTags: ['s']
        }
        Group {
            name: "Arduino_Due"
            prefix: includePaths[6]
            files: ["*.c","*.cpp"]
            fileTags: ['s']
        }
        Group {
            name: "SPI"
            prefix: includePaths[7]
            files: ["*.c","*.cpp"]
            fileTags: ['s']
        }
        Group {
            name: "AVR"
            prefix: includePaths[8]
            files: ["*.c","*.cpp"]
            fileTags: ['s']
        }


        Rule {
            id: compiler
            inputs: ["s"]
            Artifact {
                fileTags: ['obj']
                filePath: "../build/"+input.fileName + '.o'
            }
            prepare: {
                var args = [];
                for (i in product.compilerFlags)
                    args.push(product.compilerFlags[i]);
                for (i in product.includePaths)
                    args.push('-I' + product.includePaths[i]);
                for (i in product.defines)
                    args.push('-D' + product.defines[i]);
                args.push(input.filePath);
                args.push('-o');
                args.push(output.filePath);
                var compilerPath;
                if (input.fileName.substring(input.fileName.indexOf(".")+1) == "cpp")
                    compilerPath = product.compPath+"arm-none-eabi-g++"
                else
                    compilerPath = product.compPath+"arm-none-eabi-gcc"
                var cmd = new Command(compilerPath, args);
                cmd.description = 'compiling ' + input.fileName;
                cmd.highlight = 'compiler';
                cmd.silent = false;
                return cmd;
            }
        }

        Rule{
            multiplex: true
            inputs: ["obj"]
            Artifact{
                fileTags:['a']
                filePath: '../core.a'
            }
            prepare:{
                var args = []
                args.push("rcs")
                args.push(output.filePath);
                for(i in inputs["obj"]){
                    args.push(inputs["obj"][i].filePath);
                }
                //args.push(input.filePath);
                args.push(output.filePath);
                var compilerPath = product.compPath+"arm-none-eabi-ar"
                var cmd = new Command(compilerPath,args);
                cmd.description = [];
                cmd.description = "packing to core.a";
                return cmd;
            }
        }

        Rule{
            id: linker
            inputs: ["a"]
            Artifact{
                fileTags:['elf']
                filePath: "../"+product.name+ '.elf'
            }
            prepare:{
                var pathBuild = input.filePath.substring(0,input.filePath.length-6);
                var args = []
                args.push("-Os");
                args.push("-Wl,--gc-sections");
                args.push("-mcpu=cortex-m3");
                args.push("-T"+product.hardwarePath+product.SAM+"variants/arduino_due_x/linker_scripts/gcc/flash.ld");
                args.push("-Wl,-Map,"+pathBuild+"build/"+product.name+".map");
                args.push("-o");
                args.push(pathBuild+product.name+".elf");
                args.push("-L"+pathBuild+"build/");
                args.push("-lm");
                args.push("-lgcc");
                args.push("-mthumb");
                args.push("-Wl,--cref");
                args.push("-Wl,--check-sections");
                args.push("-Wl,--gc-sections");
                args.push("-Wl,--entry=Reset_Handler");
                args.push("-Wl,--unresolved-symbols=report-all");
                args.push("-Wl,--warn-common");
                args.push("-Wl,--warn-section-align");
                args.push("-Wl,--warn-unresolved-symbols");
                args.push("-Wl,--start-group");
                args.push(pathBuild+"build/"+"syscalls_sam3.c.o");
                args.push(pathBuild+"build/"+"main.cpp.o");
                args.push(pathBuild+"build/"+"variant.cpp.o");
                args.push(product.hardwarePath+product.SAM+"variants/arduino_due_x/libsam_sam3x8e_gcc_rel.a");
                args.push(pathBuild+"core.a");
                args.push("-Wl,--end-group");
                var linker = product.compPath+"arm-none-eabi-gcc"
                var cmd = new Command(linker,args);
                cmd.description = 'linking '+product.name+'.elf'
                cmd.highlight = 'linker';
                return cmd;
            }
        }

        Rule{
            inputs: ["elf"]
            Artifact{
                fileTags:['bin']
                filePath: "../../"+product.name+ '.bin'
            }
            prepare:{
                var args = []
                args.push("-O")
                args.push("binary")
                args.push(input.filePath)
                args.push(output.filePath)
                var hexcreator = product.compPath+"arm-none-eabi-objcopy"
                var cmd = new Command(hexcreator,args);
                cmd.description = 'convert to '+product.name+'.bin'
                return cmd;
            }
        }
    }
}


