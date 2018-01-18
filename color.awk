BEGIN       {other=1}
/ Trace:/   {printf "\033[32m%s\033[0m\n", $0
             other=0}
other       {print}
            {fflush()}
