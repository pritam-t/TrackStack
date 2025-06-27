import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:learn_phase/BMI/BMI.dart';

class BMI_Result extends StatefulWidget {
  final String username;
  final double height;
  final double weight;

  const BMI_Result({
    super.key,
    required this.username,
    required this.height,
    required this.weight,
  });

  @override
  State<BMI_Result> createState() => _BMI_ResultState();
}

class _BMI_ResultState extends State<BMI_Result> {

  double calculateBMI(double heightInCm, double weightInKg) {
    double heightInMeters = heightInCm / 100;
    double bmi = weightInKg / (heightInMeters * heightInMeters);
    return double.parse(bmi.toStringAsFixed(2));
  }

  String getBMICategory(double bmi) {
    if (bmi < 18.5) return "Underweight";
    else if (bmi < 25) return "Normal";
    else if (bmi < 30) return "Overweight";
    else return "Obese";
  }



  var result = null;

  @override
  void initState() {
    super.initState();
    result = calculateBMI(widget.height, widget.weight);
  }

  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // backgroundColor: Color.fromRGBO(199, 220, 225, 1.0),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                margin: EdgeInsetsGeometry.symmetric(vertical: 0, horizontal: 40,),
                width: double.infinity,
                height: 500,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.tealAccent,
                  gradient: LinearGradient(
                    colors: [
                      Colors.lightBlue.shade300,
                      Colors.lightBlue.shade200,
                      Colors.lightBlue.shade100,
                      Colors.lightBlue.shade50,
                      Colors.white70,
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    transform: GradientRotation(math.pi / 4),
                  ),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Hello ${widget.username}',
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        'Weight:  ${widget.weight}',
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        'Height:  ${widget.height}',
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        'BMI : $result',
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        'Result: ${getBMICategory(result)}',
                          style: TextStyle(
                              fontSize: 19,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                      )
                      ),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BMIScreen(),
                            ),
                          );
                        },
                        style: ButtonStyle(
                          minimumSize: WidgetStateProperty.all(Size(130, 50)),
                          elevation: WidgetStateProperty.all(0),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                        ),
                        child: Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
