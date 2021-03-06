program KeyboardInput;

{$mode objfpc}{$H+}

{ Example 04 Keyboard Input                                                    }
{                                                                              }
{  Example 03 showed some of the screen output capabilities, now we want to    }
{  read from a connected keyboard and print the typed characters on the screen.}
{                                                                              }
{  To compile the example select Run, Compile (or Run, Build) from the menu.   }
{                                                                              }
{  Once compiled select Tools, Run in QEMU ... from the Lazarus menu to launch }
{  the application in a QEMU session.                                          }
{                                                                              }
{  QEMU VersatilePB version                                                    }
{   What's the difference? See Project, Project Options, Config and Target.    }

{Declare some units used by this example.}
uses
  QEMUVersatilePB,
  GlobalConfig,
  GlobalConst,
  GlobalTypes,
  Platform,
  Threads,
  Console,
  Framebuffer,
  SysUtils,
  Explorer,
  Keyboard; {The QEMUVersatilePB unit includes the Keyboard driver for QEMU}

{We'll need a window handle again.}
var
 Character:Char;
 WindowHandle:TWindowHandle;


begin
 {Create a console window at full size}
 WindowHandle:=ConsoleWindowCreate(ConsoleDeviceGetDefault,CONSOLE_POSITION_FULL,True);

 {Output some welcome text on the console window}
 ConsoleWindowWriteLn(WindowHandle,'Welcome to Example 04 Keyboard Input');
 ConsoleWindowWriteLn(WindowHandle,'Make sure QEMU is the active window and start typing some characters');

 {Loop endlessly while checking for Keyboard characters}
 while True do
  begin
   {Read a character from the global keyboard buffer. If multiple keyboards are
    connected all characters will end up in a single buffer and be received here}
   if ConsoleGetKey(Character,nil) then
    begin
     {Before we print the character to the screen, check what was pressed}
     if Character = #0 then
      begin
       {If a control character like a function key or one of the arrow keys was pressed then
        ConsoleGetKey will return 0 first to let us know, we need to read the next character
        to get the key that was pressed}
       ConsoleGetKey(Character,nil);
      end
     else if Character = #13 then
      begin
       {If the enter key was pressed, write a new line to the console instead of a
        character}
       ConsoleWindowWriteLn(WindowHandle,'');
      end
     else
      begin
       {Something other than enter was pressed, print that character on the screen}
       ConsoleWindowWriteChr(WindowHandle,Character);
      end;
    end;

   {No need to sleep on each loop, ConsoleGetKey will wait until a key is pressed}
  end;

 {No need to halt, we never reach this point}
end.

