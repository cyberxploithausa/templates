#!/usr/bin/env python3

import time
import os
from pyfiglet import Figlet

def clear():
    os.system('cls' if os.name == 'nt' else 'clear')

def countdown(minutes):
    total_seconds = minutes * 60
    figlet = Figlet(font='big')

    while total_seconds >= 0:
        mins, secs = divmod(total_seconds, 60)
        timer = f"{mins:02}:{secs:02}"

        clear()
        print(figlet.renderText(timer))

        if total_seconds == 0:
            print("\nTIME'S UP!")
            break

        time.sleep(1)
        total_seconds -= 1

if __name__ == "__main__":
    minutes = int(input("Enter countdown time (minutes): "))
    countdown(minutes)
