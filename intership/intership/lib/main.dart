import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'ar_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  List<CameraDescription> cameras = await availableCameras();

  runApp(
    MaterialApp(
      home: YourAppHome(cameras: cameras),
    ),
  );
}

class YourAppHome extends StatelessWidget {
  final List<CameraDescription> cameras;

  YourAppHome({required this.cameras});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CameraScreen(cameras: cameras)),
                );
              },
              child: Text('Open Camera'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ARScreen()),
                );
              },
              child: Text('Open AR View'),
            ),
          ],
        ),
      ),
    );
  }
}
