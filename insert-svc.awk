BEGIN                           {counter = 0
                                 proc = 0}
                                {print}
/# Begin asmlist al_procedures/ {proc = 1}
/# End asmlist al_procedures/   {proc = 0}
proc && /#.*\[[0-9][0-9]*\]/    {print "        svc     #", counter++
                                 line = gensub(/'/, "''", "g", $0)
                                 print " AddLine('", line, "');" >> "source.generated.inc"}
