import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String id;
  String name;
  bool completed;
  String userId;

  Task({
    required this.id,
    required this.name,
    this.completed = false,
    required this.userId,
  });

  factory Task.fromFirestore(Map<String, dynamic> data, String id) {
    return Task(
      id: id,
      name: data['name'],
      completed: data['completed'] ?? false,
      userId: data['userId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'completed': completed,
      'userId': userId,
    };
  }
}

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _tasksCollection => _firestore.collection('tasks');

  Future<void> addTask(Task task) async {
    await _tasksCollection.add(task.toMap());
  }

  Future<void> toggleTaskCompletion(Task task) async {
    await _tasksCollection.doc(task.id).update({
      'completed': !task.completed,
    });
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }

  Stream<List<Task>> getTasksForUser(String userId) {
    return _tasksCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Task.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }
}
