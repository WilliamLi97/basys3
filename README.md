# Basys 3
This repository contains personal projects for the Basys 3. Each directory contains a makefile with targets to lint, elaborate, synthesize, place, route, generate bitstream, and program the design. The makefile targets simply call Vivado in batch mode. I prefer to use Vivado in non-project batch mode and execute tcl scripts found in the `scripts` directory, but there are some exceptions: elaboration requires opening the GUI to check the schematic, and simulation requires a temporary project to be set up (this is something I will have to look into further when switching to UVM simulations).

## Environment
Editing of the HDL is done in Visual Studio Code on WSL 2 (Ubuntu). Synthesis and implementation are done using Vivado. Icarus Verilog and GTKWave are currently used for verification, but this is subject to change as I continue to learn UVM (Vivado's simulator supports UVM). Makefile (GNU Make) is used to automate the workflow.

As a personal reminder (and for anyone interested in replicating this environment), here are some notes regarding environment setup:

### Add Vivado to PATH
This will allow `vivado` (and other tools such as `xsim`) to be used in the terminal from any directory. Append the following to `~/.bashrc` (may have to change depending on the installation directory and version of Vivado):

```bash
export PATH="$PATH:/tools/Xilinx/Vivado/2023.2/bin"
```

Some resources online say that this step should be done automatically as part of the Vivado installation process, but this was not the case for me, and I had to do this manually.

### Install usbipd-win
This is a tool used to share usb devices with WSL 2. Without this, the board will not be recognized in WSL 2 when plugged in (`lsusb` will list connected USB devices). The usbipd-win repository can be found [here](https://github.com/dorssel/usbipd-win), and contains notes regarding installation and usage.

To find the bus ID of the board, look for the difference between the outputs of `usbipd list` before and after turning on the board.

### USBIP Connect Extension
This is an extension for Visual Studio Code which creates a button to attach and detach devices to / from WSL 2. Note that it still requires usbipd-win to be installed to work, but it no longer requires opening a CLI in Windows to manage USB connections to WSL 2. 

Note that when attaching a USB device to WSL 2 for the first time, Visual Studio Code will need to be restarted with administrator privileges. This is probably because under the hood, usbipd-win still requires administrator privileges to share the USB connection with WSL 2.
