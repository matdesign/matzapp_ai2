import 'package:flutter/material.dart';
import 'math_tutor_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _matzColorAnimation;
  late Animation<Color?> _appColorAnimation;

  @override
  void initState() {
    super.initState();

    // Set up the animation controller for 3 seconds
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Define the animation for the colors of "Matz" and "App"
    _matzColorAnimation = ColorTween(begin: Colors.white, end: Colors.purple).animate(_controller);
    _appColorAnimation = ColorTween(begin: Colors.white, end: Colors.blue).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueAccent, Colors.purpleAccent], // Gradient background
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Animated "MatzApp" logo
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _matzColorAnimation,
                  builder: (context, child) => Text(
                    'Matz',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: _matzColorAnimation.value,
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _appColorAnimation,
                  builder: (context, child) => Text(
                    'App',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: _appColorAnimation.value,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            // Text below the logo
            Text(
              'Created as part of Nas.io AI Challenge',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 50),
            // Gradient "Proceed" button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => MathTutorScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(0), // Remove default padding to use gradient
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple, Colors.blue],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: 200.0,
                      minHeight: 50.0,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Proceed',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
