# pip install paho-mqtt pynput

import paho.mqtt.client as mqtt
from pynput.keyboard import Controller
import json
# ip = '169.254.57.236'
ip = '192.168.0.164'

sens = 2

def on_connect(client, userdata, flags, rc):
    print("Connected with result code "+str(rc))
    client.subscribe("test")

def on_message(client, userdata, msg):
    # print(msg.topic+" "+ msg.payload.decode('utf-8'))
    key = None
    # keyboard.press(key)
    # keyboard.release(key)
    # m = msg.payload
    data = json.loads(msg.payload.decode('utf-8'))
    print(data['x'])
    if data['y'] <= -sens:
        # left
        key = 'a'
    elif data['y'] >= sens:
        # right
        key = 'd'
    elif data['x'] <= -sens:
        # up
        key = 'w'
    elif data['x'] >= sens:
        key = 's'

    if key != None:
        keyboard.press(key)
        keyboard.release(key)
        print(f'enter {key}')

    pass

client   = mqtt.Client()
keyboard = Controller()

client.on_connect = on_connect
client.on_message = on_message

client.connect(ip, 1883, 60)
client.loop_forever()
