#/bin/bash

LPR=KeyboardInput
if [[ -e /c/ultibo ]]
then
    WINDOWS=1
    ULTIBOBIN=/c/ultibo/core/fpc/3.1.1/bin/i386-win32
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

function checkexit {
    if [[ $1 != 0 ]]
    then
        cat errors.log
        exit 1
    fi
}

function compile {
    fpc -s -al -B -O2 -Tultibo -Parm -CpARMV7a -WpQEMUVPB @$ULTIBOBIN/QEMUVPB.CFG $LPR.lpr >& errors.log
    checkexit $?
    mv $LPR.s $LPR.s.in
    awk -f insert-svc.awk $LPR.s.in > $LPR.s
    rm $LPR.s.in
}

echo Script: compile once to determine svc numbers and generate source.generated.inc
compile

echo Script: compile a second time to use the accurate source.generated.inc file
compile

if [[ $WINDOWS == 1 ]]
then
    chmod u+x ppas.bat
    ./ppas.bat >& errors.log
    checkexit $?
else
    ./ppas.sh >& errors.log
    checkexit $?
fi

echo Script: run qemu
CMDLINE="NETWORK0_IP_CONFIG=STATIC NETWORK0_IP_ADDRESS=10.0.2.15 NETWORK0_IP_NETMASK=255.255.255.0 NETWORK0_IP_GATEWAY=10.0.2.1"
qemu-system-arm -M versatilepb -cpu cortex-a8 -m 256M -kernel kernel.bin -monitor none -serial stdio -monitor tcp::12000,server,nowait -append "$CMDLINE"
