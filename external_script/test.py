from time import sleep
from pynput.keyboard import Controller

# https://www.codegrepper.com/code-examples/python/python+simulate+keyboard+input

keyboard = Controller()
key = "w"

while True:
    keyboard.press(key)
    keyboard.release(key)
    sleep(1)

print('end')