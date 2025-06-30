import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskModel {
  final String date;
  bool wokeUpEarly;
  bool learnedDsa;
  String note;

  TaskModel({
    required this.date,
    required this.wokeUpEarly,
    required this.learnedDsa,
    required this.note,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      date: json['date'],
      wokeUpEarly: json['wokeUpEarly'],
      learnedDsa: json['learnedDsa'],
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'wokeUpEarly': wokeUpEarly,
    'learnedDsa': learnedDsa,
    'note': note,
  };
}

class DailyPages extends StatefulWidget {
  const DailyPages({super.key});

  @override
  State<DailyPages> createState() => _DailyPagesState();
}

class _DailyPagesState extends State<DailyPages> with TickerProviderStateMixin {
  final List<TaskModel> _tasks = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  // Animation controllers
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _isAnimating = false;
  bool _isNextCard = true;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Initialize with default animation (right to left)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    _initializeTasks();
  }

  Future<void> _initializeTasks() async {
    setState(() => _isLoading = true);
    final loadedTasks = await _loadTasks();
    final today = DateFormat('dd MMM yy').format(DateTime.now());

    if (loadedTasks.isEmpty) {
      _tasks.add(TaskModel(
        date: today,
        wokeUpEarly: false,
        learnedDsa: false,
        note: '',
      ));
      await _saveTasks();
    } else {
      _tasks.addAll(loadedTasks);
      _currentIndex = _tasks.indexWhere((task) => task.date == today);
      if (_currentIndex == -1) {
        _tasks.insert(0, TaskModel(
          date: today,
          wokeUpEarly: false,
          learnedDsa: false,
          note: '',
        ));
        _currentIndex = 0;
        await _saveTasks();
      }
    }

    setState(() => _isLoading = false);
  }

  Future<List<TaskModel>> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('daily_tasks') ?? [];
    return jsonList.map((json) => TaskModel.fromJson(jsonDecode(json))).toList();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList('daily_tasks', jsonList);
  }

  void _updateCurrentTask(TaskModel updatedTask) {
    setState(() {
      _tasks[_currentIndex] = updatedTask;
    });
    _saveTasks();
  }

  Future<void> _addNextDay() async {
    final currentDate = DateFormat('dd MMM yy').parse(_tasks[_currentIndex].date);
    final nextDate = DateFormat('dd MMM yy').format(currentDate.add(const Duration(days: 1)));

    setState(() {
      _tasks.add(TaskModel(
        date: nextDate,
        wokeUpEarly: false,
        learnedDsa: false,
        note: '',
      ));
    });

    await _saveTasks();
  }

  Future<void> _addPreviousDay() async {
    final currentDate = DateFormat('dd MMM yy').parse(_tasks[_currentIndex].date);
    final prevDate = DateFormat('dd MMM yy').format(currentDate.subtract(const Duration(days: 1)));

    setState(() {
      _tasks.insert(0, TaskModel(
        date: prevDate,
        wokeUpEarly: false,
        learnedDsa: false,
        note: '',
      ));
      _currentIndex++;
    });

    await _saveTasks();
  }

  Future<void> _goToNextCard() async {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
      _isNextCard = true;
      _slideAnimation = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeInOut,
      ));
    });

    _slideController.reset();
    await _slideController.forward();

    if (_currentIndex < _tasks.length - 1) {
      setState(() {
        _currentIndex++;
        _isAnimating = false;
      });
    } else {
      await _addNextDay();
      setState(() {
        _currentIndex++;
        _isAnimating = false;
      });
    }
  }

  Future<void> _goToPreviousCard() async {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
      _isNextCard = false;
      _slideAnimation = Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeInOut,
      ));
    });

    _slideController.reset();
    await _slideController.forward();

    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isAnimating = false;
      });
    } else {
      await _addPreviousDay();
      setState(() => _isAnimating = false);
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: 80,
          title: const Text("Learnings",
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.w400, color: Colors.black)),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade600,
                  Colors.blue.shade400,
                  Colors.blue.shade300,
                  Colors.blue.shade100,
                  Colors.blue.shade50,
                  Colors.white70,
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(4.0),
            child: Divider(height: 4.0, color: Colors.black12),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Expanded(
              child: SlideTransition(
                position: _slideAnimation,
                child: TaskCard(
                  key: ValueKey(_tasks[_currentIndex].date),
                  task: _tasks[_currentIndex],
                  onChanged: _updateCurrentTask,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _goToPreviousCard,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Previous"),
                  ),
                  ElevatedButton.icon(
                    onPressed: _goToNextCard,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text("Next"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final ValueChanged<TaskModel> onChanged;

  const TaskCard({
    super.key,
    required this.task,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _TaskCardContent(
      task: task,
      onChanged: onChanged,
    );
  }
}

class _TaskCardContent extends StatefulWidget {
  final TaskModel task;
  final ValueChanged<TaskModel> onChanged;

  const _TaskCardContent({
    required this.task,
    required this.onChanged,
  });

  @override
  State<_TaskCardContent> createState() => _TaskCardContentState();
}

class _TaskCardContentState extends State<_TaskCardContent> {
  late bool wokeUpEarly;
  late bool learnedDsa;
  late TextEditingController noteController;

  @override
  void initState() {
    super.initState();
    wokeUpEarly = widget.task.wokeUpEarly;
    learnedDsa = widget.task.learnedDsa;
    noteController = TextEditingController(text: widget.task.note);
    noteController.addListener(_updateTask);
  }

  @override
  void didUpdateWidget(covariant _TaskCardContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task != widget.task) {
      wokeUpEarly = widget.task.wokeUpEarly;
      learnedDsa = widget.task.learnedDsa;
      noteController
        ..removeListener(_updateTask)
        ..text = widget.task.note
        ..addListener(_updateTask);
    }
  }

  void _updateTask() {
    widget.onChanged(TaskModel(
      date: widget.task.date,
      wokeUpEarly: wokeUpEarly,
      learnedDsa: learnedDsa,
      note: noteController.text,
    ));
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isProductive = wokeUpEarly && learnedDsa;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isProductive
            ? const Color.fromRGBO(131, 234, 255, 1.0)
            : const Color.fromRGBO(222, 241, 255, 1.0),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.shade400,
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
                "📅 ${widget.task.date}",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          const Divider(thickness: 1, height: 30),
          CheckboxListTile(
            value: wokeUpEarly,
            onChanged: (value) {
              setState(() {
                wokeUpEarly = value!;
                _updateTask();
              });
            },
            title: const Text("Woke up early",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            value: learnedDsa,
            onChanged: (value) {
              setState(() {
                learnedDsa = value!;
                _updateTask();
              });
            },
            title: const Text("Learned DSA today",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 10),
          const Text("📝 Notes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            // height: 200,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),

            ),
            child: TextField(
              controller: noteController,
              minLines: 4,
              maxLines: 6,
              onTapOutside: (value){
                FocusScope.of(context).unfocus();
              },
              decoration: const InputDecoration.collapsed(
                hintText: "Write your thoughts, achievements, or ideas...",
              ),
            ),
          ),
          if (isProductive)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Center(
                child: Text(
                  "✅ Awesome! You're productive today!",
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}