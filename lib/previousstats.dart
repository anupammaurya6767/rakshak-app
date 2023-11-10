import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rakshak/config.dart';
// import 'package:url_launcher/url_launcher.dart';

class PreviousStats extends StatefulWidget {
  const PreviousStats({Key? key}) : super(key: key);

  @override
  _PreviousStatsState createState() => _PreviousStatsState();
}

class _PreviousStatsState extends State<PreviousStats> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 18, left: 24, right: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopRow(),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildImageSection(),
                    const SizedBox(height: 14),
                    const Center(
                      child: Text(
                        "Previous Stats",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Pacifico',
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Divider(
                      height: 2,
                      color: Colors.indigo,
                      thickness: 2,
                      indent: 50,
                      endIndent: 50,
                    ),
                    const SizedBox(height: 22),
                    _buildClickableElement('Entry'),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.indigo,
          ),
        ),
        const RotatedBox(
          quarterTurns: 135,
          child: Icon(
            Icons.bar_chart_outlined,
            color: Colors.indigo,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Center(
      child: Image.asset("assets/images/data.gif"),
    );
  }

  Widget _buildClickableElement(String title) {
    return FutureBuilder(
      future: fetchfromServer(), // Replace with your MongoDB fetch function
      builder: (context, AsyncSnapshot<Object?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          // Check if snapshot.data is Map<String, dynamic>
          if (snapshot.data is Map<String, dynamic>) {
            Map<String, dynamic> data = snapshot.data as Map<String, dynamic>;

            // Access properties with proper casting
            String timestamp = data['timestamp'].toString();
            String link = data['link'].toString();

            return InkWell(
              onTap: () => {
                //              if (await canLaunch($link)) {
                //   await launch($link);
                // } else {
                //   print('Could not launch $link');
                // }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  timestamp,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            );
          } else {
            return Text('Invalid data format');
          }
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchfromServer() async {
    final response = await http.get(Uri.parse(Config.serverEndpoint));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = List.from(json.decode(response.body));
      final List<Map<String, dynamic>> dataList =
          jsonData.map((data) => Map<String, dynamic>.from(data)).toList();
      return dataList;
    } else {
      throw Exception('Failed to load data from Server');
    }
  }
}
