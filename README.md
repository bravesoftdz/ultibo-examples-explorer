Installation
============
Install Ultibo and Git for your platform. Installing Git for Windows installs a bash shell and needed tools.

Operation
=========

In a bash console:

    cd ultibo-examples-explorer
    ./run-kernel.sh | awk -f color.awk

which will build Ultibo Example 04 - KeyboardInput and run it in QEMU. The example has been modified only to include the explorer unit.

QEMU will remain running in this console. The ultibo log is printed in color in this console. Each pascal statement executed in the program will be logged in this console.
