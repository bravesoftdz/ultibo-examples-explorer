               {other = 1}
/Script: /     {printf "\033[37;44m%s\033[0m\n", $0
                other = 0}
/ Trace:/      {printf "\033[32m%s\033[0m\n", $0
                other = 0}
/^ALSA[: ]/    {other = 0}
/^alsa[: ]/    {other = 0}
/^audio:/      {other = 0}
/^pulseaudio:/ {other = 0}
other          {print}
               {fflush()}
