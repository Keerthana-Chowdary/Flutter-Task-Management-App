import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'add_task_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TaskScreen(),
    );
  }
}

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List tasks = [];

  String searchQuery = "";
  String selectedStatus = "All";
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  void loadTasks() async {
    final data = await ApiService.getTasks();
    setState(() => tasks = data);
  }

  // 🔍 Debounced Search
  void onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        searchQuery = value;
      });
    });
  }

  // 🔗 Find parent task
  Map? getTaskById(int? id) {
    if (id == null) return null;
    try {
      return tasks.firstWhere((t) => t['id'] == id);
    } catch (_) {
      return null;
    }
  }

  // 🚫 Block logic (correct)
  bool isTaskBlocked(Map task) {
    if (task['blocked_by'] == null) return false;
    final parent = getTaskById(task['blocked_by']);
    return parent != null && parent['status'] != 'Done';
  }

  // 🔍 Filter logic
  List get filteredTasks {
    return tasks.where((t) {
      final matchesSearch = t['title']
          .toLowerCase()
          .contains(searchQuery.toLowerCase());

      final matchesStatus =
          selectedStatus == "All" || t['status'] == selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  Future<void> deleteTask(int id) async {
    await ApiService.deleteTask(id);
    loadTasks();
  }

  // ✨ Highlight search match
  Widget highlightText(String text) {
    if (searchQuery.isEmpty) {
      return Text(text,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500));
    }

    final lower = text.toLowerCase();
    final query = searchQuery.toLowerCase();
    final start = lower.indexOf(query);

    if (start == -1) {
      return Text(text,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500));
    }

    final end = start + query.length;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
              text: text.substring(0, start),
              style: const TextStyle(color: Colors.white)),
          TextSpan(
            text: text.substring(start, end),
            style: const TextStyle(
              color: Colors.black,
              backgroundColor: Colors.cyanAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
              text: text.substring(end),
              style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget glassCard(Map task) {
    final isBlocked = isTaskBlocked(task);
    final parent = getTaskById(task['blocked_by']);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          if (!isBlocked)
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.25),
              blurRadius: 20,
            )
        ],
      ),
      child: Opacity(
        opacity: isBlocked ? 0.45 : 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                    color: Colors.white.withOpacity(0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE + ACTIONS
                  Row(
                    children: [
                      Expanded(child: highlightText(task['title'])),

                      // STATUS CHIP (glass-like)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: task['status'] == "Done"
                              ? Colors.orangeAccent.withOpacity(0.8)
                              : Colors.cyanAccent.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(task['status'],
                            style:
                                const TextStyle(color: Colors.black)),
                      ),

                      const SizedBox(width: 6),

                      IconButton(
                        icon: const Icon(Icons.edit,
                            color: Colors.white),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddTaskScreen(
                                  task: task, allTasks: tasks),
                            ),
                          );
                          loadTasks();
                        },
                      ),

                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red),
                        onPressed: () =>
                            deleteTask(task['id']),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(task['description'],
                      style:
                          const TextStyle(color: Colors.white70)),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 16, color: Colors.white70),
                      const SizedBox(width: 5),
                      Text(task['due_date'],
                          style: const TextStyle(
                              color: Colors.white70)),
                    ],
                  ),

                  // 🚫 BLOCK INFO
                  if (isBlocked && parent != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        "Blocked by: ${parent['title']}",
                        style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget searchBar() {
    return TextField(
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.cyanAccent,
      decoration: InputDecoration(
        hintText: "Search tasks...",
        hintStyle: const TextStyle(color: Colors.white60),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      onChanged: onSearchChanged,
    );
  }

  Widget statusFilter() {
    return DropdownButton<String>(
      value: selectedStatus,
      dropdownColor: Colors.black,
      items: ["All", "To-Do", "In Progress", "Done"]
          .map((s) => DropdownMenuItem(
                value: s,
                child: Text(s,
                    style:
                        const TextStyle(color: Colors.white)),
              ))
          .toList(),
      onChanged: (val) =>
          setState(() => selectedStatus = val!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌈 Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2A0A5E),
                  Color(0xFF1B4F9C),
                  Color(0xFF2EC4B6),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text("My Tasks",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),

                  const SizedBox(height: 12),

                  searchBar(),

                  const SizedBox(height: 10),

                  statusFilter(),

                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView(
                      children: filteredTasks
                          .map<Widget>(
                              (t) => glassCard(t))
                          .toList(),
                    ),
                  )
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor:
                  Colors.purpleAccent.withOpacity(0.8),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddTaskScreen(allTasks: tasks),
                  ),
                );
                loadTasks();
              },
              child: const Icon(Icons.add),
            ),
          )
        ],
      ),
    );
  }
}