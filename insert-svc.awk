BEGIN                           {counter = 0
                                 proc = 0}
                                {print}
/# Begin asmlist al_procedures/ {proc = 1}
/# End asmlist al_procedures/   {proc = 0}
proc && /#.*\[[0-9][0-9]*\]/    {printf "        svc     #%d\n", counter++
                                 line = gensub(/'/, "''", "g", $0)
                                 printf " AddLine('%s');\n", line >> "source.generated.inc"}
