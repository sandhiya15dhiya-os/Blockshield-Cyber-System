from scapy.all import sniff
import requests

API_URL = "http://127.0.0.1:5000/attack"

def detect(packet):
    if packet.haslayer("IP"):
        ip = packet["IP"].src

        attack = {
            "ip": ip,
            "type": "TCP" if packet.haslayer("TCP") else "Other"
        }

        print("[DETECTED]", attack)

        try:
            requests.post(API_URL, json=attack)
        except:
            print("[ERROR] API not running")

def start():
    print("Monitoring started...")
    sniff(prn=detect, store=False)

if __name__ == "__main__":
    start()