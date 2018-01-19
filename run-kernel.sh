#/bin/bash
set -e

LPR=KeyboardInput
if [[ -e /c/ultibo ]]
then
    WINDOWS=1
    ULTIBOBIN=/c/ultibo/core/fpc/3.1.1/bin/i386-win
    export PATH=/c/ultibo/core/qemu:$ULTIBOBIN:$PATH
elif [[ -e $HOME/ultibo ]]
then
    WINDOWS=0
    ULTIBOBIN=$HOME/ultibo/core/fpc/bin
    export PATH=$ULTIBOBIN:$PATH
else
    echo cannot find ultibo
    exit 1
fi

# compile once to determine svc numbers and generate source.generated.inc
rm -f source.generated.inc
touch source.generated.inc
fpc -s -al -B -O2 -Tultibo -Parm -CpARMV7a -WpQEMUVPB @$ULTIBOBIN/QEMUVPB.CFG $LPR.lpr
mv $LPR.s $LPR.s.in
awk -f insert-svc.awk $LPR.s.in > $LPR.s

# compile a second time to use the accurate source.generated.inc file
fpc -s -al -B -O2 -Tultibo -Parm -CpARMV7a -WpQEMUVPB @$ULTIBOBIN/QEMUVPB.CFG $LPR.lpr
mv $LPR.s $LPR.s.in
awk -f insert-svc.awk $LPR.s.in > $LPR.s

if [[ $WINDOWS == 1 ]]
then
    chmod u+x ppas.bat
    ./ppas.bat
else
    ./ppas.sh
fi

qemu-system-arm -M versatilepb -cpu cortex-a8 -m 256M -kernel kernel.bin -monitor tcp::12000,server,nowait -serial stdio
