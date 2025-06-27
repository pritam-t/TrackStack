import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'BMI_final.dart';

class BMIScreen extends StatefulWidget {
  const BMIScreen({super.key});

  @override
  State<BMIScreen> createState() => _BMIScreenState();
}

class _BMIScreenState extends State<BMIScreen>
{

  InputDecoration myInputDecoration(String label, IconData icon,String info)
  {
    return InputDecoration(
      label: Text(label ,style: TextStyle(color: Colors.black54,),),
      hintText: info,
      fillColor: Colors.black,
      prefixIcon: Icon(icon,color: Colors.black,),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black,width: 2.0,style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(2),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black,width: 2.0,style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black,width: 2.0,style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(5),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black,width: 2.0,style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(5),
      ),

    );
  }

  var nameController = TextEditingController();
  var heightController = TextEditingController();
  var weightController = TextEditingController();



  @override
  Widget build(BuildContext context)
  {
    return SafeArea(
      child: Scaffold(
        // backgroundColor: Color.fromRGBO(199, 220, 225, 1.0),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container( 
                margin: EdgeInsetsGeometry.symmetric(vertical: 0,horizontal: 40),
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
                    Colors.white70
                  ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    transform: GradientRotation(math.pi/4)
                  ),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

                    Container(
                      margin: EdgeInsetsGeometry.symmetric(vertical: 0,horizontal: 30),
                      width: double.infinity,

                      child: TextField(
                        style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
                        controller: nameController,

                        decoration: myInputDecoration('Enter Name',Icons.person,'User_Name'),
                      ),
                    ),

                    Container(
                      margin: EdgeInsetsGeometry.symmetric(vertical: 0,horizontal: 30),
                      width: double.infinity,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
                        controller: heightController,
                        decoration: myInputDecoration('Height',Icons.height,'In cm'),
                      ),
                    ),

                    Container(
                      margin: EdgeInsetsGeometry.symmetric(vertical: 0,horizontal: 30),
                      width: double.infinity,

                      child: TextField(
                        style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
                        keyboardType: TextInputType.number,
                        controller: weightController,
                        decoration: myInputDecoration('Weight',Icons.monitor_weight,'In Kg'),
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () => handleSubmit(context),
                      style: ButtonStyle(
                        minimumSize: WidgetStateProperty.all(Size(130, 50)),
                        elevation: WidgetStateProperty.all(0),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                      child: Text("Submit",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void handleSubmit(BuildContext context) {
    final name = nameController.text.trim();
    final heightText = heightController.text.trim();
    final weightText = weightController.text.trim();

    final height = double.tryParse(heightText);
    final weight = double.tryParse(weightText);

    // Check if any field is empty or invalid
    if (name.isEmpty || height == null || weight == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Invalid Input'),
          content: Text('Please enter valid Name, Height (in feet), and Weight (in kg).'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            )
          ],
        ),
      );
    } else {
      // Inputs are valid, navigate to result screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BMI_Result(
            username: name,
            height: height,
            weight: weight,
          ),
        ),
      );
    }
  }

}
