import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:learn_phase/TODO/todopage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'appBar.dart';
import 'daily_page.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  List<TaskModel> _tasks = [];
  bool _isLoading = true;
  final Color _wakeUpColor = Colors.blue;
  final Color _learnDsaColor = Colors.green;
  String _selectedMonth = DateFormat('MMMM').format(DateTime.now());
  final ScrollController _scrollController = ScrollController();


  double _calculateHabitCorrelation(List<TaskModel> tasks) {
    if (tasks.length < 3) return 0.0;

    int n = tasks.length;
    int both = 0, wakeUpOnly = 0, dsaOnly = 0;

    for (final task in tasks) {
      if (task.wokeUpEarly && task.learnedDsa) both++;
      else if (task.wokeUpEarly) wakeUpOnly++;
      else if (task.learnedDsa) dsaOnly++;
    }

    double phi = (both * (tasks.length - wakeUpOnly - dsaOnly - both) -
        wakeUpOnly * dsaOnly) /
        sqrt((wakeUpOnly + both) *
            (dsaOnly + both) *
            (tasks.length - wakeUpOnly - both) *
            (tasks.length - dsaOnly - both));

    return phi.isNaN ? 0.0 : phi;
  }

  int _calculateCurrentStreak(List<TaskModel> tasks, bool Function(TaskModel) habitSelector) {
    // First sort all tasks by date (newest first)
    final sortedTasks = List<TaskModel>.from(tasks)
      ..sort((a, b) => DateFormat('dd MMM yy').parse(b.date)
          .compareTo(DateFormat('dd MMM yy').parse(a.date)));

    int streak = 0;
    DateTime? previousDate;

    for (final task in sortedTasks) {
      final currentDate = DateFormat('dd MMM yy').parse(task.date);

      // Check if this is consecutive with previous day
      if (previousDate != null &&
          !_isConsecutiveDay(previousDate, currentDate)) {
        break;
      }

      if (habitSelector(task)) {
        streak++;
        previousDate = currentDate;
      } else {
        break;
      }
    }

    return streak;
  }

  bool _isConsecutiveDay(DateTime laterDate, DateTime earlierDate) {
    return laterDate.difference(earlierDate).inDays == 1;
  }  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('daily_tasks') ?? [];
    final loadedTasks = jsonList
        .map((json) => TaskModel.fromJson(jsonDecode(json)))
        .toList();

    loadedTasks.sort(
      (a, b) => DateFormat(
        'dd MMM yy',
      ).parse(b.date).compareTo(DateFormat('dd MMM yy').parse(a.date)),
    );

    setState(() {
      _tasks = loadedTasks;
      _isLoading = false;
    });
  }

  List<TaskModel> _getTasksForSelectedMonth() {
    final now = DateTime.now();
    final month = DateFormat('MMMM').parse(_selectedMonth).month;
    final year = _selectedMonth == DateFormat('MMMM').format(now)
        ? now.year
        : (now.month < month ? now.year - 1 : now.year);

    return _tasks.where((task) {
      final taskDate = DateFormat('dd MMM yy').parse(task.date);
      return taskDate.month == month && taskDate.year == year;
    }).toList();
  }

  int _getDaysInSelectedMonth() {
    final now = DateTime.now();
    if (_selectedMonth == DateFormat('MMMM').format(now)) {
      return now.day; // Current month - show days up to today
    }

    final month = DateFormat('MMMM').parse(_selectedMonth).month;
    final year = now.month < month ? now.year - 1 : now.year;
    return DateTime(year, month + 1, 0).day; // Days in the month
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildFancyAppBar(
      context: context,
      title: '🎯Productivity',
      onBack: () => Navigator.pop(context,MaterialPageRoute(
          builder:(context)=> DailyPages()
      )),
      onNext: () => Navigator.push(context,MaterialPageRoute(
          builder:(context)=> ToDoPage()
      )),
      backicon: Icons.arrow_back_sharp,
        nexticon: Icons.insights_sharp
        // You can use any icon here
    ),


      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMonthSelector(),
            const SizedBox(height: 16),
            _buildSuccessRateCards(),
            const SizedBox(height: 24),
            _buildChartSection(),
            const SizedBox(height: 24),
            _buildDetailedListSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    final now = DateTime.now();
    final months = [
      DateFormat('MMMM').format(DateTime(now.year, now.month)),
      DateFormat('MMMM').format(DateTime(now.year, now.month - 1)),
      DateFormat('MMMM').format(DateTime(now.year, now.month - 2)),
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Colors.black,
          width: 0.3,
        ),
        borderRadius: BorderRadius.circular(12.0), // border radius
      ),

      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text(
              'Select Month',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: months.map((month) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(month),
                      selected: _selectedMonth == month,
                      onSelected: (selected) {
                        setState(() {
                          _selectedMonth = month;
                        });
                      },
                      selectedColor: Colors.blue,
                      labelStyle: TextStyle(
                        color: _selectedMonth == month
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessRateCards() {
    final monthTasks = _getTasksForSelectedMonth();
    final daysInMonth = _getDaysInSelectedMonth();
    final wakeUpSuccess = monthTasks.where((t) => t.wokeUpEarly).length;
    final dsaSuccess = monthTasks.where((t) => t.learnedDsa).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 12) / 2;
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: constraints.maxWidth),
          child: Row(
            children: [
              SizedBox(
                width: cardWidth,
                child: _buildStatCard(
                  'Wake Up',
                  Icons.wb_sunny,
                  '$wakeUpSuccess/$daysInMonth',
                  _wakeUpColor,
                  wakeUpSuccess / daysInMonth,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: cardWidth,
                child: _buildStatCard(
                  'DSA',
                  Icons.school,
                  '$dsaSuccess/$daysInMonth',
                  _learnDsaColor,
                  dsaSuccess / daysInMonth,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      String title,
      IconData icon,
      String value,
      Color color,
      double successRate,
      ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Colors.black,
          width: 0.3,
        ),
        borderRadius: BorderRadius.circular(12.0), // border radius
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: successRate,
              backgroundColor: Colors.grey[200],
              color: color,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 4),
            Text(
              '${(successRate * 100).toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    final monthTasks = _getTasksForSelectedMonth();
    final daysInMonth = _getDaysInSelectedMonth();
    final hasData = monthTasks.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Habit Completion - $_selectedMonth',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${monthTasks.length}/$daysInMonth days',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Colors.black,
              width: 0.3,
            ),
            borderRadius: BorderRadius.circular(12.0), // border radius
          ),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            height: 280,
            padding: const EdgeInsets.all(16),
            child: hasData
                ? _buildScrollableChart(monthTasks)
                : const Center(
              child: Text(
                'No data for selected month',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScrollableChart(List<TaskModel> tasks) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tasks.length * 50.0,
              child: BarChart(
                BarChartData(
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final task = tasks[groupIndex];
                        final habit = rodIndex == 0 ? '🌅 Wake Up' : '📚 DSA';
                        final status = rod.toY == 1 ? 'Completed' : 'Missed';
                        return BarTooltipItem(
                          '$habit\n$status\n${task.date}',
                          const TextStyle(color: Colors.white, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final day = DateFormat('d').format(
                            DateFormat('dd MMM yy').parse(tasks[value.toInt()].date),
                          );
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              day,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                        reservedSize: 20,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: tasks.asMap().entries.map((entry) {
                    final index = entry.key;
                    final task = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: task.wokeUpEarly ? 1 : 0,
                          width: 14,
                          color: _wakeUpColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        BarChartRodData(
                          toY: task.learnedDsa ? 1 : 0,
                          width: 14,
                          color: _learnDsaColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                  alignment: BarChartAlignment.spaceBetween,
                  maxY: 1.2,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Divider(thickness: 2, height: 10),
        _buildCompactDailyNotes(tasks),
      ],
    );
  }

  Widget _buildCompactDailyNotes(List<TaskModel> tasks) {
    // Filter tasks to only include those with notes
    final tasksWithNotes = tasks.where((task) => task.note.isNotEmpty).toList();

    return SizedBox(
      height: tasksWithNotes.isNotEmpty ? 80 : 0, // Only take height if there are notes
      child: tasksWithNotes.isNotEmpty
          ? ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tasksWithNotes.length,
        itemBuilder: (context, index) {
          final task = tasksWithNotes[index];
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 10 ),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black,width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  task.date,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task.note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          );
        },
      )
          : const SizedBox.shrink(), // Show nothing if no notes exist
    );
  }

  Widget _buildDetailedListSection() {
    final monthTasks = _getTasksForSelectedMonth();
    if (monthTasks.isEmpty) {
      return const SizedBox.shrink();
    }

    final wakeUpStreak = _calculateCurrentStreak(monthTasks, (task) => task.wokeUpEarly);
    final dsaStreak = _calculateCurrentStreak(monthTasks, (task) => task.learnedDsa);
    final correlation = _calculateHabitCorrelation(monthTasks);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: const Text(
            'Performance Insights',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
          side: BorderSide(
    color: Colors.black,
    width: 0.3,
    ),
    borderRadius: BorderRadius.circular(12.0), // border radius
    ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Current Streaks',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStreakCard('🌅 Wake Up', wakeUpStreak, _wakeUpColor, monthTasks),
                    _buildStreakCard('📚 DSA', dsaStreak, _learnDsaColor, monthTasks),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                const Text(
                  'Habit Synergy',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _buildCorrelationInsight(correlation),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard(String habit, int streak, Color color, List<TaskModel> tasks) {
    final isWakeUp = habit == '🌅 Wake Up';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black,width: 0.5),
          ),
          child: Text(
            streak > 3 ? '🔥' : streak > 0 ? '⭐' : '❄️',
            style: const TextStyle(fontSize: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          habit,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          streak > 0 ? '$streak day${streak != 1 ? "s" : ""}' : 'No streak',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (streak > 0) ...[
          const SizedBox(height: 4),
          Text(
            'since ${_getStreakStartDate(tasks, isWakeUp)}',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ],
    );
  }

  String _getStreakStartDate(List<TaskModel> tasks, bool isWakeUp) {
    // Sort tasks from newest to oldest
    final sortedTasks = List<TaskModel>.from(tasks)
      ..sort((a, b) => DateFormat('dd MMM yy').parse(b.date)
          .compareTo(DateFormat('dd MMM yy').parse(a.date)));

    DateTime? lastCompletedDate;

    for (final task in sortedTasks) {
      final completed = isWakeUp ? task.wokeUpEarly : task.learnedDsa;
      if (completed) {
        lastCompletedDate = DateFormat('dd MMM yy').parse(task.date);
      } else {
        break;
      }
    }

    return lastCompletedDate != null
        ? DateFormat('MMM d').format(lastCompletedDate)
        : 'N/A';
  }

  Widget _buildCorrelationInsight(double correlation) {
    correlation = _calculateHabitCorrelation(_getTasksForSelectedMonth());

    Map<String, dynamic> insightData;

    if (correlation > 0.6) {
      insightData = {
        'text': 'Power Combo! 🚀\nEarly rises boost DSA success',
        'color': Colors.green,
        'icon': Icons.trending_up,
      };
    } else if (correlation > 0.3) {
      insightData = {
        'text': 'Positive Link 📈\nGood habit reinforcement',
        'color': Colors.lightGreen,
        'icon': Icons.thumb_up,
      };
    } else if (correlation > -0.3) {
      insightData = {
        'text': 'No Strong Link\nHabits work independently',
        'color': Colors.grey,
        'icon': Icons.horizontal_rule,
      };
    } else {
      insightData = {
        'text': 'Watch Out ⚠️\nMiss one when doing the other',
        'color': Colors.orange,
        'icon': Icons.warning,
      };
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: insightData['color'].withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black,
          width: 0.2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            insightData['icon'],
            size: 32,
            color: insightData['color'],
          ),
          const SizedBox(height: 12),
          Text(
            insightData['text'],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: insightData['color'].withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: correlation.abs().clamp(0.0, 1.0),
            backgroundColor: Colors.grey[200],
            color: insightData['color'],
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}
