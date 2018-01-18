#/bin/bash
set -e

LPR=KeyboardInput
export PATH=/c/ultibo/core/qemu:/c/ultibo/core/fpc/3.1.1/bin/i386-win32:$PATH

# compile once to determine svc numbers and generate source.generated.inc
rm -f source.generated.inc
touch source.generated.inc
fpc -al -s -B -O2 -Tultibo -Parm -CpARMV7a -WpQEMUVPB @/c/ultibo/core/fpc/3.1.1/bin/i386-win32/QEMUVPB.CFG -Fi/c/ultibo/core/fpc/source/rtl/ultibo/core $LPR.lpr
mv $LPR.s $LPR.s.in
awk -f insert-svc.awk $LPR.s.in > $LPR.s

# compile a second time to use the accurate source.generated.inc file
fpc -al -s -B -O2 -Tultibo -Parm -CpARMV7a -WpQEMUVPB @/c/ultibo/core/fpc/3.1.1/bin/i386-win32/QEMUVPB.CFG -Fi/c/ultibo/core/fpc/source/rtl/ultibo/core $LPR.lpr
mv $LPR.s $LPR.s.in
awk -f insert-svc.awk $LPR.s.in > $LPR.s

chmod u+x ppas.bat
./ppas.bat
qemu-system-arm -M versatilepb -cpu cortex-a8 -m 256M -kernel kernel.bin -monitor tcp::12000,server,nowait -serial stdio
