import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:http/http.dart' as http;

class Status extends StatefulWidget {
  const Status({Key? key}) : super(key: key);

  @override
  _Status createState() => _Status();
}

class _Status extends State<Status> {
  bool isSecurityActive =
      false; // Default value for the "SECURITY SYSTEM" button
  bool isServerActive = false; // Default value for the "SERVER STATUS" button
  double systemLatency = 0.0;
  double serverLatency = 0.0;
  double sizeStatus = 0.0;
  double ramStatus = 0.0;

  Future<bool> fetchStatus(String endpoint) async {
    try {
      final response = await http.get(Uri.parse(endpoint));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<double> fetchLatency(String endpoint) async {
    try {
      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        // Calculate latency percentage based on your logic
        return 0.75;
      } else {
        return 0.0;
      }
    } catch (e) {
      return 0.0;
    }
  }

  Future<double> fetchData(String endpoint) async {
    try {
      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        return double.parse(response.body);
      } else {
        // Handle error, return a default value, or throw an exception
        return 0;
      }
    } catch (e) {
      // Handle error, return a default value, or throw an exception
      return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch latency values when the widget initializes
    fetchLatencies();
    fetchSizeAndRamStatus();
  }

  Future<void> fetchLatencies() async {
    final systemLatencyResult =
        await fetchLatency('http://your-full-url/getstatus');
    final serverLatencyResult =
        await fetchLatency('http://your-full-url/getDataStatus');

    setState(() {
      systemLatency = systemLatencyResult;
      serverLatency = serverLatencyResult;
    });
  }

  Future<void> fetchSizeAndRamStatus() async {
    final sizeStatusResult =
        await fetchData('http://your-full-url/getsizestatus');
    final ramStatusResult =
        await fetchData('http://your-full-url/getramstatus');

    setState(() {
      sizeStatus = sizeStatusResult;
      ramStatus = ramStatusResult;
    });
  }

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
              Row(
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
                  )
                ],
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildImageSection(),
                    const SizedBox(height: 14),
                    const Center(
                      child: Text(
                        "Status",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Pacifico',
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FutureBuilder<bool>(
                          future: fetchStatus('http://your-full-url/getstatus'),
                          builder: (context, snapshot) {
                            isSecurityActive = snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.data == true;
                            return _roundedButton(
                                title: 'SECURITY SYSTEM',
                                isActive: isSecurityActive);
                          },
                        ),
                        FutureBuilder<bool>(
                          future:
                              fetchStatus('http://your-full-url/getDataStatus'),
                          builder: (context, snapshot) {
                            isServerActive = snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.data == true;
                            return _roundedButton(
                                title: 'SERVER STATUS',
                                isActive: isServerActive);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _cardMenu(
                          title: "System Latency",
                          percentage: systemLatency,
                        ),
                        _cardMenu(
                          title: "Server Latency",
                          percentage: serverLatency,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    _linearProgressIndicator('Size Status', sizeStatus),
                    const SizedBox(
                      height: 18,
                    ),
                    _linearProgressIndicator('Ram Status', ramStatus),
                    const SizedBox(
                      height: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _linearProgressIndicator(String title, double value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: LinearProgressIndicator(
              value: value / 30, // Assuming 30 is the maximum value
              color: Colors.indigo, // Customize the color if needed
              backgroundColor:
                  Colors.grey, // Customize the background color if needed
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardMenu({
    required String title,
    double percentage = 0.0,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 36,
      ),
      width: 156,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 120,
            lineWidth: 14,
            percent: percentage,
            progressColor: Colors.indigo,
            center: Text(
              '${(percentage * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Center(
      child: Image.asset("assets/images/status.gif"),
    );
  }

  Widget _roundedButton({
    required String title,
    bool isActive = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 32,
      ),
      decoration: BoxDecoration(
        color: isActive ? Colors.indigo : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.indigo),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
