import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ShadowAdjuster(),
    );
  }
}

class ShadowAdjuster extends StatefulWidget {
  @override
  _ShadowAdjusterState createState() => _ShadowAdjusterState();
}

class _ShadowAdjusterState extends State<ShadowAdjuster> {
  double leftShadowOffset = -12;
  double rightShadowOffset = 12;
  double bottomShadowOffset = 12;
  double blurRadius = 32;
  double spreadRadius = -2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adjust Container Shadow'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Placeholder(),
                Container(
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: Offset(leftShadowOffset, 0),
                        blurRadius: blurRadius,
                        spreadRadius: spreadRadius,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: Offset(rightShadowOffset, 0),
                        blurRadius: blurRadius,
                        spreadRadius: spreadRadius,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: Offset(0, bottomShadowOffset),
                        blurRadius: blurRadius,
                        spreadRadius: spreadRadius,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Adjust Left Shadow Offset: ${leftShadowOffset.toStringAsFixed(1)}'),
            Slider(
              value: leftShadowOffset,
              min: -50,
              max: 50,
              divisions: 100,
              onChanged: (value) {
                setState(() {
                  leftShadowOffset = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Text('Adjust Right Shadow Offset: ${rightShadowOffset.toStringAsFixed(1)}'),
            Slider(
              value: rightShadowOffset,
              min: -50,
              max: 50,
              divisions: 100,
              onChanged: (value) {
                setState(() {
                  rightShadowOffset = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Text('Adjust Bottom Shadow Offset: ${bottomShadowOffset.toStringAsFixed(1)}'),
            Slider(
              value: bottomShadowOffset,
              min: -50,
              max: 50,
              divisions: 100,
              onChanged: (value) {
                setState(() {
                  bottomShadowOffset = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Text('Adjust Blur Radius: ${blurRadius.toStringAsFixed(1)}'),
            Slider(
              value: blurRadius,
              min: 0,
              max: 50,
              divisions: 50,
              onChanged: (value) {
                setState(() {
                  blurRadius = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Text('Adjust Spread Radius: ${spreadRadius.toStringAsFixed(1)}'),
            Slider(
              value: spreadRadius,
              min: -10,
              max: 10,
              divisions: 20,
              onChanged: (value) {
                setState(() {
                  spreadRadius = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
