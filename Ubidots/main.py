from network import WLAN
import urequests as requests
import machine
import time

TOKEN = "XXXXX" #FILL IN YOUR UBIDOTS TOKEN
DELAY = 900  # Delay in seconds

adc = machine.ADC()
apin = adc.channel(pin='P16')

wlan = WLAN(mode=WLAN.STA)
wlan.antenna(WLAN.INT_ANT)

# FILL IN YOUR WI-FI CREDENTIALS
wlan.connect("XXXXX", auth=(WLAN.WPA2, "XXXXX"), timeout=5000)

while not wlan.isconnected ():
    machine.idle()
print("Connected to Wifi\n")

# Builds the json to send the request
def build_json(variable1, value1):
    try:
        data = {variable1: {"value": value1}}
        return data
    except:
        return None

# Sends the request. Please reference the REST API reference https://ubidots.com/docs/api/
def post_var(device, value1):
    try:
        url = "https://industrial.api.ubidots.com/"
        url = url + "api/v1.6/devices/" + device
        headers = {"X-Auth-Token": TOKEN, "Content-Type": "application/json"}
        data = build_json("temperature", value1)
        if data is not None:
            print(data)
            req = requests.post(url=url, headers=headers, json=data)
            return req.json()
        else:
            pass
    except:
        pass

while True:
    millivolts = apin.voltage()
    celsius = (millivolts - 500.0) / 10.0
    post_var("pycom", celsius)
    time.sleep(DELAY)
