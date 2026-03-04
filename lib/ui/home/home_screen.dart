import 'package:flutter/material.dart';
import 'package:schedule_generator_ai/models/task.dart';
import 'package:schedule_generator_ai/services/gemini_services.dart';
import 'package:schedule_generator_ai/ui/home/components/add_task_cart.dart';
import 'package:schedule_generator_ai/ui/home/components/schedule_result_card.dart';
import 'package:schedule_generator_ai/ui/home/components/task_list_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // utk proses generating schedule -> AI
  bool isLoading = false;
  final List<Task> tasks = [];
  String scheduleResult = '';
  final GeminiService geminiService = GeminiService();

  Future<void> _generateSchedule() async {
    // proses masih jalan, loading
    setState(() => isLoading = true);

    try {
      // await : nunggu si gemini udh beres apa blm, inikan 2 proses ya
      String schedule = await geminiService.generateSchedule(tasks);
      setState(() => scheduleResult = schedule);
    } catch (e) {
      // klo error muncul di debug consol
      setState(() => scheduleResult = e.toString());
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Generator'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildHeader(),
          // perubahan state
          AddTaskCard(onAddTask: (task) => setState(() => tasks.add(task))),
          SizedBox(height: 16),
          TaskListSession(
            tasks: tasks,
            // ignore: collection_methods_unrelated_type
            onDelete: (index) => setState(() => tasks.removeAt(index)), // menghapus task berdasarkan indexnya
          ),
          SizedBox(height: 16),
          _BUildGenerateButton(),
          SizedBox(height: 16,),
          ScheduleResultCard(schedule: scheduleResult)
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          // emoji sparkling
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          SizedBox(width: 12),
          // biar content memenuhi ruang kosong yang ada (teks nya rapih)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Plan your day faster",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700

                  ),
                ),
                Text(
                  "add tasks and generate",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant
                  ),
                )
              ],
            ),
          ),
          //ini yang kanan atas 
          Chip(label: Text('${tasks.length} task'))
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _BUildGenerateButton() {
    // bisa ini bisa elevated button
    return FilledButton.icon(
      onPressed: (isLoading || tasks.isEmpty) ? null : _generateSchedule,
      icon: isLoading
          ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
          : Icon(Icons.auto_awesome_rounded),
        label: Text(isLoading ? 'Generating...' : 'Generate Schedule'),
    );
  }
}