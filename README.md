# DontAttract
A Nintendo Classic Mini like layout for Attract Mode.

It is functional, but still a work in progress.

## Prerequisites
This layout uses extra modules not included in Attract Mode. You can download them from this repository: [WAFAM](https://github.com/Ryback2501/wafam)

The instructions about how to setup the modules are on the [Readme.md](https://github.com/Ryback2501/wafam/blob/master/Readme.md) file of the WAFAM project.

## How to add customizations?
1. Create a folder inside the **UI** folder of the layout with all the images (as in the Nintendont folder already included).
2. If you need to, add a flag image in the **UI/Flags** folder of the layout.
3. Open the **definitions.nut** file with a text editor
4. At the begining of the file, add a line inside the Regions table. It should look like this:
    ````squirrel
    Famicom = { platform = "Famicom", flag = "JAP" },
    ````
    The value of *platform* is the name of the folder and the value of *flag* is the name of the image file of the flag without extension.