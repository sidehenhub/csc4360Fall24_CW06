import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'task_manager.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final AuthService _authService = AuthService();
  final TaskService _taskService = TaskService();
  final TextEditingController _controller = TextEditingController();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _authService.user.listen((user) {
      setState(() {
        _userId = user?.uid;
      });
    });
  }

  void _addTask() async {
    if (_controller.text.isNotEmpty && _userId != null) {
      Task newTask = Task(
        id: '',
        name: _controller.text,
        userId: _userId!,
      );
      await _taskService.addTask(newTask);
      _controller.clear();
    }
  }

  void _toggleTaskCompletion(Task task) {
    _taskService.toggleTaskCompletion(task);
  }

  void _deleteTask(String taskId) {
    _taskService.deleteTask(taskId);
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('crud_firebase'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => _authService.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter task name',
                border: OutlineInputBorder(),
                hintText: 'Enter a task name',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: _addTask,
              child: Text('Add Task'),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: _taskService.getTasksForUser(_userId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No tasks available.'));
                }

                final tasks = snapshot.data!;

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      title: Text(
                        task.name,
                        style: TextStyle(
                          decoration: task.completed ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      leading: Checkbox(
                        value: task.completed,
                        onChanged: (_) => _toggleTaskCompletion(task),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteTask(task.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
