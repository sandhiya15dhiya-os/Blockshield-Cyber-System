import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(BlockShieldApp());
}

class BlockShieldApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Map<String, dynamic>? data;
  bool alertShown = false;

  final String baseUrl = "https://blockshield.onrender.com";

  @override
  void initState() {
    super.initState();
    fetchData();

    // 🔄 Auto refresh every 3 sec
    Timer.periodic(Duration(seconds: 3), (timer) {
      fetchData();
    });
  }

  // 📊 FETCH STATUS DATA
  Future<void> fetchData() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/status"));

      if (res.statusCode == 200) {
        final jsonData = json.decode(res.body);

        setState(() {
          data = jsonData;
        });

        // ⚠️ Alert only once
        if (jsonData["threat_level"] == "HIGH" && !alertShown) {
          alertShown = true;
          showAlert();
        }

        if (jsonData["threat_level"] != "HIGH") {
          alertShown = false;
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // 🚨 ALERT POPUP
  void showAlert() {
    Future.delayed(Duration.zero, () {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) {
            Future.delayed(Duration(seconds: 3), () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
            });

            return AlertDialog(
              title: Text("⚠️ ALERT"),
              content: Text("High Threat Detected!"),
            );
          },
        );
      }
    });
  }

  // 🚀 TEST ATTACK API
  Future<void> sendTestAttack() async {
    try {
      await http.post(
        Uri.parse("$baseUrl/attack"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "ip": "192.168.1.${DateTime.now().second}",
          "type": "TEST_ATTACK"
        }),
      );
    } catch (e) {
      print("Attack send error: $e");
    }
  }

  Color getThreatColor(String level) {
    if (level == "HIGH") return Colors.red;
    if (level == "MEDIUM") return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("BlockShield Dashboard 🌐"),
        backgroundColor: Colors.black,
      ),
      body: data == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: ListView(
                children: [
                  // 🔴 Threat Level
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: getThreatColor(data!["threat_level"]),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Text("Threat Level",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        SizedBox(height: 10),
                        Text(
                          data!["threat_level"],
                          style: TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // 📊 Total Attacks
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Attacks", style: TextStyle(fontSize: 18)),
                        Text(data!["attacks"].toString(),
                            style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // 🚫 Blocked IPs
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Blocked IPs 🚫", style: TextStyle(fontSize: 18)),
                        SizedBox(height: 10),
                        if (data!["blocked_ips"].isEmpty)
                          Text("No blocked IPs yet"),
                        ...data!["blocked_ips"].map<Widget>((ip) {
                          return ListTile(
                            leading: Icon(Icons.block, color: Colors.red),
                            title: Text(ip),
                          );
                        }).toList(),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // 🛠️ Healing Logs
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Self-Healing Logs 🛠️",
                            style: TextStyle(fontSize: 18)),
                        SizedBox(height: 10),
                        if (data!["healing_logs"].isEmpty)
                          Text("No healing actions yet"),
                        ...data!["healing_logs"].map<Widget>((log) {
                          return ListTile(
                            leading: Icon(Icons.build, color: Colors.blue),
                            title: Text(log),
                          );
                        }).toList(),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // 🚀 TEST BUTTON
                  ElevatedButton(
                    onPressed: sendTestAttack,
                    child: Text("Simulate Attack 🚀"),
                  ),
                ],
              ),
            ),
    );
  }
}
