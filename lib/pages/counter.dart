import 'package:flutter/material.dart';

class CounterPage extends StatefulWidget
{
  const CounterPage({super.key});
  @override
  State<CounterPage> createState() => _CounterPageState();
}
class _CounterPageState extends State<CounterPage>
{
  var value = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical:0,horizontal: 40),
              child: Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black,width: 3)
                ),
                child:
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 15),
                    child: Text('$value',style:
                    TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                    ),overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 30,),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60.0),
                child: InkWell(
                  child: Center(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.red,
                          border: Border.all(color: Colors.black,width: 3)
                      ),
                      child: Center(
                        child: Icon(
                          Icons.add_circle_outlined,size: 50,),
                      ),
                    ),
                  ),
                  onTap: (){
                    setState(() {
                      value++;
                    });
                  },
                  onLongPress: (){
                    setState(() {
                      value = value+10;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60.0),
                child: InkWell(
                  child: Center(
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.red,
                          border: Border.all(color: Colors.black,width: 3)
                      ),
                      child: Center(
                        child: Icon(
                          Icons.remove_circle_outlined,size: 50,),
                      ),
                    ),
                  ),
                  onTap: (){
                    setState(() {
                      value--;
                    });
                  },
                  onLongPress: (){
                    setState(() {
                      value = value-10;
                    });
                  },
                ),
              ),
          ]
          ),
        ],
      ),
    );
  }
}
