Installation
============
Install Ultibo for your platform.

On Windows, install Git for Windows to obtain the required bash shell and related tools.

On Linux, install qemu-system-arm (on Windows, this is already installed with Ultibo.) If mawk in installed, you will need to install gawk instead.

Operation
=========

In a bash console:

    cd ultibo-examples-explorer
    ./run-kernel.sh |& awk -f color.awk

which will build Ultibo Example 04 - KeyboardInput and run it in QEMU. The example has been modified only to include the explorer unit.

QEMU will remain running in this console. The ultibo log is printed in color in this console. Each pascal statement executed in the program will be logged in this console.
