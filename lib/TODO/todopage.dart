import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/daily_page.dart';

class ToDoPage extends StatefulWidget {
  const ToDoPage({super.key});

  @override
  State<ToDoPage> createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {

  final Map<String,String> arrTask = {};

  void saveTaskToPrefs() async{
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(arrTask);
    await prefs.setString('task_data', jsonString);
  }

  void loadTaskFromPrefs() async{
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('task_data');
    if(jsonString!= null)
    {
      final Map<String,dynamic> jsonMap = jsonDecode(jsonString);
      setState((){
        arrTask.clear();
        jsonMap.forEach((key,value){
          arrTask[key]= value.toString();
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadTaskFromPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
        title: const Text("To-Do App",
          style: TextStyle(
          fontSize: 35,
          fontWeight: FontWeight.w400,
            color: Colors.black
        ),),
          centerTitle: true,
          leading: IconButton(onPressed: (){}, icon: const Icon(Icons.navigate_before_outlined,size: 50,color: Colors.black,),),
          actions: [
            IconButton(onPressed: ()
            {
              Navigator.push(context, MaterialPageRoute(builder:(context)=> DailyPages()));
            },
              icon: const Icon(Icons.navigate_next_outlined,size: 50,color: Colors.black,),)
          ],
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade600,
                    Colors.blue.shade400,
                    Colors.blue.shade300,
                    Colors.blue.shade100,
                    Colors.blue.shade50,
                    Colors.white70
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  transform: GradientRotation(math.pi/3)
              ),
            ),
          ),
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4.0),
              child: Container(
                color: Colors.black12,
                height: 4.0,
              )),
        ),

          body: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: InkWell(
                    onTap: () {
                      showAddTaskDialog(context);
                    },
                    splashColor: Colors.blueAccent,
                    splashFactory: InkSparkle.splashFactory,
                    child: Container(
                      height: 50,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue.shade200,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Add ",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(Icons.add_circle_outlined, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ), //Add Icon

              Expanded(
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                      elevation: 20,
                      color: Color.fromRGBO(188, 235, 255, 1.0),
                      shadowColor: Color.fromRGBO(92, 101, 106, 1.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                      ),

                      child: arrTask.isEmpty?
                      const Center(
                        child: Text('No Tasks Yet',style: TextStyle(fontSize: 18),),
                      ):
                      ListView.builder(
                        itemCount: arrTask.length,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context,index)
                      {
                        final key = arrTask.keys.elementAt(index);
                        final value = arrTask[key]!;
                        return InkWell(
                          onLongPress: (){
                            showDeleteTaskDialog(context,key);
                          },
                          child: TaskContainer(
                            task: key,
                            info: value
                          ),

                        );
                      }),
                    ),
                  )
                ],),
      ),);
  }



//----------------------Add Dialogue box------------------------------------------------------
  void showAddTaskDialog(BuildContext context)
  {
    final taskController = TextEditingController();
    final infoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskController,
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: infoController,
                decoration: InputDecoration(
                  labelText: 'Additional Info',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final task = taskController.text.trim();
                final info = infoController.text.trim();

                if (task.isNotEmpty) {
                  setState(() {
                      arrTask[task] = info;
                  });
                  saveTaskToPrefs();
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void showDeleteTaskDialog(BuildContext context, String taskKey)
  {
    showDialog(context: context, builder: (context){
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text("Delete Task"),
        content: Text("Are you sure you want to delete $taskKey?"),
        actions: [
          TextButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: Text("Cancel"),
          ),
          ElevatedButton(
              onPressed: (){
                  setState(() {
                    arrTask.remove(taskKey);
                    saveTaskToPrefs();
                  });
                  Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text("Delete"),
          ),
        ],
      );
    });
  }
}
// ----------------------List Generator-----------------------------------------------------
class TaskContainer extends StatefulWidget
{
  final String info;
  final String task;

  const TaskContainer({
    super.key,
    required this.info,
    required this.task,
  });

  @override
  State<TaskContainer> createState() => _TaskContainerState();
}

class _TaskContainerState extends State<TaskContainer>
{

  bool isChecked = false;
  bool status = false;


  Color boxColor= Color.fromRGBO(222, 241, 255, 1.0);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: boxColor,
        border: Border.all(color: Colors.black, width: 0.3),
      ),

      child: Padding(
        padding: const EdgeInsets.all(8.0), // optional padding inside container
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent
          ),
          child: CheckboxListTile(
            contentPadding: EdgeInsets.zero, // removes default padding
            value: isChecked,
            activeColor: Colors.green, // Change box color to green when checked
            checkColor: Colors.black,
          
            onChanged: (bool? newValue) {
              setState(() {
                isChecked = newValue!;
                status = !status;
               boxColor =  (newValue == true)?
               Color.fromRGBO(131, 234, 255, 1.0) :
               Color.fromRGBO(222, 241, 255, 1.0);
              });
            },
            title: Text(
              widget.task,
              style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
            ),
            subtitle: Text(widget.info,style: TextStyle(fontSize: 16),),
          ),
        ),
      ),
    );


  }
}
//------------------------------------------------------------------------------------------



