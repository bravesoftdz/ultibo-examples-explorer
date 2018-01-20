unit Explorer;
{$mode delphi}{$h+}

interface

implementation
 uses GlobalConfig,GlobalTypes,Devices,Keyboard,Logging,Platform,Serial,Threads,SysUtils;

procedure StartLogging;
begin
 LOGGING_INCLUDE_COUNTER:=False;
 SERIAL_REGISTER_LOGGING:=True;
 SerialLoggingDeviceAdd(SerialDeviceGetDefault);
 SERIAL_REGISTER_LOGGING:=False;
 LoggingDeviceSetDefault(LoggingDeviceFindByType(LOGGING_TYPE_SERIAL));
end;

const
 MaxSourceLines=10*1000;

var
 SourceLines:Array[0..MaxSourceLines - 1] of String;
 LineCount:LongWord;

procedure AddLine(Line:String);
begin
 SourceLines[LineCount]:=Line;
 Inc(LineCount);
end;

const
 TraceLength = 1*1024*1024; // power of 2 for easy wrapping

type
 TCoverageMeter = record
  TraceCounter:LongWord;
  TraceBuffer:Array[0..TraceLength - 1] of LongWord;
 end;

var
 CoverageMeter:TCoverageMeter;

procedure CoverageSvcHandler; assembler; nostackframe;
asm
 stmfd r13!,{r0-r4,r14}
 ldr   r3,=CoverageMeter                    // r3 CoverageMeter
 ldr   r2,[r3,#TCoverageMeter.TraceCounter]
 add   r2,#1                                // r2 incremented TraceCounter
 ldr   r1,=TraceLength-1
 and   r1,r2                                // r1 wrapped incremented TraceCounter
 add   r4,r3,#TCoverageMeter.TraceBuffer
 add   r4,r4,r1,lsl #2                      // r4 points to entry
 ldr   r0,[r14,#-4]
 bic   r0,#0xFF000000                       // r0 has svc code number
 str   r0,[r4]                              // store code number
 str   r2,[r3,#TCoverageMeter.TraceCounter] // store incremented TraceCounter
 ldmfd r13!,{r0-r4,r15}^
end;

var
 TraceConsumptionThreadHandle:TThreadHandle;

function TraceConsumptionThread(Parameter:Pointer):PtrInt;
var
 ConsumedEvents:LongWord;
 Event:LongWord;
begin
 Result:=0;
 ConsumedEvents:=0;
 while True do
  begin
   if CoverageMeter.TraceCounter <> ConsumedEvents then
    begin
     Event:=CoverageMeter.TraceBuffer[ConsumedEvents and (TraceLength - 1)];
     Inc(ConsumedEvents);
     LoggingOutput(Format('Trace: %3d %s',[ConsumedEvents,SourceLines[Event]]));
    end;
   Sleep(10);
  end;
end;

initialization
 DEVICE_LOG_ENABLED:=False;
 LineCount:=0;
 {$i source.generated.inc}
 while LineCount < MaxSourceLines do
  AddLine(Format('entry %5d',[LineCount]));
 StartLogging;
 CoverageMeter.TraceCounter:=0;
 VectorTableSetEntry(VECTOR_TABLE_ENTRY_ARM_SWI,PtrUInt(@CoverageSvcHandler));
 BeginThread(@TraceConsumptionThread,nil,TraceConsumptionThreadHandle,THREAD_STACK_DEFAULT_SIZE)
end.
