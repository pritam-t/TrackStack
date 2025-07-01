import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:learn_phase/pages/statePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../TODO/todopage.dart';

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
  bool _isKeyboardVisible = false;
  final FocusNode _noteFocusNode = FocusNode();

  // Animation controllers
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Initialize animation to show card immediately
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    _noteFocusNode.addListener(() {
      setState(() {
        _isKeyboardVisible = _noteFocusNode.hasFocus;
      });
    });

    _initializeTasks();
  }

  Future<void> _initializeTasks() async {
    setState(() => _isLoading = true);

    final today = DateFormat('dd MMM yy').format(DateTime.now());
    final loadedTasks = await _loadTasks();

    _tasks.clear();

    // Add today's card (create if doesn't exist)
    final todayTask = loadedTasks.firstWhere(
          (task) => task.date == today,
      orElse: () => TaskModel(
        date: today,
        wokeUpEarly: false,
        learnedDsa: false,
        note: '',
      ),
    );
    _tasks.add(todayTask);

    // Add any existing previous days
    _tasks.addAll(loadedTasks.where((task) => task.date != today));

    // Sort tasks by date (newest first)
    _tasks.sort((a, b) => DateFormat('dd MMM yy').parse(b.date).compareTo(
        DateFormat('dd MMM yy').parse(a.date)));

    // Ensure we have the last 30 days
    final now = DateTime.now();
    final earliestAllowedDate = now.subtract(const Duration(days: 30));
    final earliestTaskDate = _tasks.isNotEmpty
        ? DateFormat('dd MMM yy').parse(_tasks.last.date)
        : now;

    if (earliestTaskDate.isAfter(earliestAllowedDate)) {
      // Add missing days
      final newTasks = <TaskModel>[];
      var currentDate = earliestTaskDate;
      while (currentDate.isAfter(earliestAllowedDate)) {
        currentDate = currentDate.subtract(const Duration(days: 1));
        final dateStr = DateFormat('dd MMM yy').format(currentDate);
        if (!_tasks.any((task) => task.date == dateStr)) {
          newTasks.add(TaskModel(
            date: dateStr,
            wokeUpEarly: false,
            learnedDsa: false,
            note: '',
          ));
        }
      }
      _tasks.addAll(newTasks);
      _tasks.sort((a, b) => DateFormat('dd MMM yy').parse(b.date).compareTo(
          DateFormat('dd MMM yy').parse(a.date)));
    }

    // Set to today's card
    _currentIndex = _tasks.indexWhere((task) => task.date == today);
    if (_currentIndex == -1) _currentIndex = 0;

    await _saveTasks();
    setState(() => _isLoading = false);

    // Show card immediately
    _slideController.forward();
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

    // Only add if next day doesn't exist
    if (!_tasks.any((task) => task.date == nextDate)) {
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
  }

  Future<void> _addPreviousDay() async {
    if (_tasks.isEmpty) return;

    final currentDate = DateFormat('dd MMM yy').parse(_tasks[0].date);
    final now = DateTime.now();
    final earliestAllowedDate = now.subtract(const Duration(days: 30));

    // Don't add if we already have the earliest allowed date
    if (currentDate.isBefore(earliestAllowedDate)) return;

    // Calculate how many days to add (up to 30)
    final daysToAdd = currentDate.difference(earliestAllowedDate).inDays;

    if (daysToAdd <= 0) return;

    // Generate all previous days at once
    final newTasks = <TaskModel>[];
    for (int i = 1; i <= daysToAdd; i++) {
      final prevDate = DateFormat('dd MMM yy').format(currentDate.subtract(Duration(days: i)));
      if (!_tasks.any((task) => task.date == prevDate)) {
        newTasks.add(TaskModel(
          date: prevDate,
          wokeUpEarly: false,
          learnedDsa: false,
          note: '',
        ));
      }
    }

    if (newTasks.isNotEmpty) {
      setState(() {
        _tasks.insertAll(0, newTasks);
        _currentIndex += newTasks.length;
      });
      await _saveTasks();
    }
  }

  Future<void> _goToNextCard() async {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
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

    if (_currentIndex < _tasks.length - 1) {
      setState(() {
        _currentIndex++;
        _isAnimating = false;
      });
    } else {
      await _addNextDay();
      setState(() {
        _currentIndex = _tasks.length - 1;
        _isAnimating = false;
      });
    }
  }

  Future<void> _goToPreviousCard() async {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
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

    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isAnimating = false;
      });
    } else {
      await _addPreviousDay(); // Changed from _addPreviousDay
      setState(() => _isAnimating = false);
    }
  }
  @override
  void dispose() {
    _slideController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          title: const Text("Learnings",
            style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w400,
                color: Colors.black
            ),),
          centerTitle: true,
          leading: IconButton(onPressed: ()
          {
            Navigator.push(context, MaterialPageRoute(builder:(context)=> ToDoPage()));
          },
            icon: const Icon(Icons.navigate_before_outlined,size: 50,color: Colors.black,),),
          actions: [
            IconButton(onPressed: ()
            {
              Navigator.push(context, MaterialPageRoute(builder:(context)=> StatsPage()));
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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _tasks.isNotEmpty
                      ? SlideTransition(
                    position: _slideAnimation,
                    child: TaskCard(
                      key: ValueKey(_tasks[_currentIndex].date),
                      task: _tasks[_currentIndex],
                      onChanged: _updateCurrentTask,
                      focusNode: _noteFocusNode,
                    ),
                  )
                      : const Center(child: Text('No tasks available')),
                ),
              ),
            ),
            if (!_isKeyboardVisible && _tasks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 80),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _goToNextCard,
                      icon: const Icon(Icons.arrow_back, size: 24),
                      label: const Text("Prev", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8FFDF7), // Soft teal
                        foregroundColor: Colors.black87,
                        elevation: 4,
                        shadowColor: Colors.lightBlueAccent.shade400,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _goToPreviousCard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8FFDF7),
                        foregroundColor: Colors.black87,
                        elevation: 4,
                        shadowColor: Colors.lightBlueAccent.shade400,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text("Next", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 24),
                        ],
                      ),
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
  final FocusNode focusNode;

  const TaskCard({
    super.key,
    required this.task,
    required this.onChanged,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return _TaskCardContent(
      task: task,
      onChanged: onChanged,
      focusNode: focusNode,
    );
  }
}

class _TaskCardContent extends StatefulWidget {
  final TaskModel task;
  final ValueChanged<TaskModel> onChanged;
  final FocusNode focusNode;

  const _TaskCardContent({
    required this.task,
    required this.onChanged,
    required this.focusNode,
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
    final isKeyboardVisible = widget.focusNode.hasFocus;

    return Container(
      margin: const EdgeInsets.symmetric(vertical:40,horizontal:20),
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
              "🗓️ ${widget.task.date}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
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
            title: const Text(
              "Woke up early",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
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
            title: const Text(
              "Learned DSA today",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 10),
          const Text(
            "📝 Notes",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 100,
              maxHeight: 200,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                },
                focusNode: widget.focusNode,
                controller: noteController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration.collapsed(
                  hintText: "Write your thoughts, achievements, or ideas...",
                ),
              ),
            ),
          ),
          if (isProductive && !isKeyboardVisible)
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