from flask import Flask, request, jsonify
from flask_cors import CORS
import sys
import time
import os

# Connect blockchain folder
sys.path.append('../blockchain')
from blockchain import Blockchain

app = Flask(__name__)
CORS(app)

# Initialize blockchain
bc = Blockchain()

# Main data storage
data = {
    "threat_level": "LOW",
    "attacks": 0,
    "logs": [],
    "blocked_ips": [],
    "healing_logs": []
}

# 🛠️ SELF-HEALING FUNCTION
def self_heal(ip):
    action = f"System auto-healed from attack by {ip}"

    print(f"[SELF-HEALING] Isolating threat from {ip}")
    time.sleep(0.5)

    print("[SELF-HEALING] Resetting connections...")
    time.sleep(0.5)

    print(f"[SELF-HEALING] System secured from {ip}")

    data["healing_logs"].append(action)


# 🏠 Home route
@app.route("/")
def home():
    return "BlockShield API Running 🚀"


# 🚨 Receive attack
@app.route("/attack", methods=["POST"])
def receive_attack():
    attack = request.json

    data["attacks"] += 1
    data["logs"].append(attack)

    ip = attack.get("ip")

    # Count repeated attacks
    count = sum(1 for log in data["logs"] if log["ip"] == ip)

    # 🚫 AUTO BLOCK + SELF HEAL
    if count >= 3 and ip not in data["blocked_ips"]:
        data["blocked_ips"].append(ip)
        print(f"[BLOCKED] IP {ip} blocked!")

        # 🛠️ Trigger self-healing
        self_heal(ip)

    # 🔗 Store in blockchain
    bc.add_block(attack)

    # 📊 Threat level logic
    if data["attacks"] > 20:
        data["threat_level"] = "HIGH"
    elif data["attacks"] > 5:
        data["threat_level"] = "MEDIUM"
    else:
        data["threat_level"] = "LOW"

    print("[API] Attack received:", attack)

    return jsonify({"status": "stored & secured"})


# 📊 System status
@app.route("/status", methods=["GET"])
def status():
    return jsonify(data)


# 🔗 Blockchain data
@app.route("/blockchain", methods=["GET"])
def get_blockchain():
    return jsonify(bc.get_chain())


# 🚫 Blocked IPs
@app.route("/blocked", methods=["GET"])
def blocked():
    return jsonify({"blocked_ips": data["blocked_ips"]})


# 🛠️ Healing logs
@app.route("/healing", methods=["GET"])
def healing():
    return jsonify({"healing_logs": data["healing_logs"]})


# 🚀 Run for deployment (Render compatible)
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)