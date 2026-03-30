import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AddTaskScreen extends StatefulWidget {
  final Map? task;
  final List allTasks;

  const AddTaskScreen({super.key, this.task, required this.allTasks});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final dateController = TextEditingController();

  String status = "To-Do";
  int? blockedBy;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // ✅ EDIT MODE (no draft)
    if (widget.task != null) {
      titleController.text = widget.task!['title'] ?? '';
      descController.text = widget.task!['description'] ?? '';
      dateController.text = widget.task!['due_date'] ?? '';
      status = widget.task!['status'] ?? "To-Do";
      blockedBy = widget.task!['blocked_by'];
    } else {
      // ✅ CREATE MODE (load draft)
      loadDraft();
    }
  }

  // ✅ Save draft ONLY for create
  Future<void> saveDraft() async {
    if (widget.task != null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('title', titleController.text);
    await prefs.setString('desc', descController.text);
    await prefs.setString('date', dateController.text);
    await prefs.setString('status', status);
  }

  Future<void> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    titleController.text = prefs.getString('title') ?? '';
    descController.text = prefs.getString('desc') ?? '';
    dateController.text = prefs.getString('date') ?? '';
    status = prefs.getString('status') ?? "To-Do";
    setState(() {});
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      dateController.text =
          DateFormat('yyyy-MM-dd').format(picked);
      await saveDraft();
      setState(() {});
    }
  }

  Future<void> saveTask() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    // ⏳ REQUIRED 2-second delay
    await Future.delayed(const Duration(seconds: 2));

    final data = {
      "title": titleController.text,
      "description": descController.text,
      "due_date": dateController.text,
      "status": status,
      "blocked_by": blockedBy
    };

    if (widget.task != null) {
      await ApiService.updateTask(widget.task!['id'], data);
    } else {
      await ApiService.createTask(data);

      // ✅ clear draft only after creating new task
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }

    Navigator.pop(context);
  }

  InputDecoration inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.white60,
        fontSize: 14,
      ),
      border: InputBorder.none,
    );
  }

  Widget glassField(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await saveDraft();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Task Form"),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: Colors.transparent,
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
                    glassField(TextField(
                      controller: titleController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      cursorColor: Colors.cyanAccent,
                      decoration: inputStyle("Enter task title..."),
                      onChanged: (_) => saveDraft(),
                    )),

                    const SizedBox(height: 12),

                    glassField(TextField(
                      controller: descController,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.cyanAccent,
                      decoration:
                          inputStyle("Enter description..."),
                      onChanged: (_) => saveDraft(),
                    )),

                    const SizedBox(height: 12),

                    glassField(TextField(
                      controller: dateController,
                      readOnly: true,
                      onTap: pickDate,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.cyanAccent,
                      decoration:
                          inputStyle("Select due date..."),
                    )),

                    const SizedBox(height: 12),

                    glassField(DropdownButtonFormField<String>(
                      value: status,
                      dropdownColor: Colors.black,
                      style:
                          const TextStyle(color: Colors.white),
                      items: ["To-Do", "In Progress", "Done"]
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(s),
                              ))
                          .toList(),
                      onChanged: (val) {
                        setState(() => status = val!);
                        saveDraft();
                      },
                      decoration: const InputDecoration(
                          border: InputBorder.none),
                    )),

                    const SizedBox(height: 12),

                    glassField(DropdownButtonFormField<int>(
                      value: blockedBy,
                      dropdownColor: Colors.black,
                      style:
                          const TextStyle(color: Colors.white),
                      hint: const Text("Blocked By",
                          style:
                              TextStyle(color: Colors.white70)),
                      items: widget.allTasks
                          .where((t) =>
                              widget.task == null ||
                              t['id'] != widget.task!['id'])
                          .map<DropdownMenuItem<int>>((t) =>
                              DropdownMenuItem<int>(
                                value: t['id'],
                                child: Text(t['title']),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => blockedBy = val),
                      decoration: const InputDecoration(
                          border: InputBorder.none),
                    )),

                    const SizedBox(height: 20),

                    isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white)
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.cyanAccent,
                                foregroundColor: Colors.black,
                                padding:
                                    const EdgeInsets.symmetric(
                                        vertical: 14),
                              ),
                              onPressed: saveTask,
                              child: Text(widget.task != null
                                  ? "Update Task"
                                  : "Save Task"),
                            ),
                          )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}