import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:task_manger/models/quotes_model.dart';
import 'package:task_manger/screens/update_task_screen.dart';
import 'package:task_manger/services/api_service.dart';
import 'package:task_manger/widgets/constant/app_const.dart';
import '../widgets/constant/app_routes.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseFirestore? firestore;
  String? userId;
  bool taskCompleted = false;

  @override
  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance;
    userId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Task Manager",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 21),
        ),
        leading: const Icon(Icons.menu),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                      "Logout",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    content: const Text("Are you sure you want to log out?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context); // Close dialog
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.loginscreen,
                            );
                          }
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Logged out successfully")));
                        },
                        child: const Text(
                          "Logout",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:  EdgeInsets.all(12),
            child: Container(
              child: FutureBuilder<QuoteModel>(
                future: ApiService().fetchQuotes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: Colors.blue,));
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  if (snapshot.hasData) {
                    final quote = snapshot.data!;

                    return Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quote.quote,
                            style: TextStyle(color: Colors.black, fontSize: 18,fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text("- ${quote.author}", style: TextStyle(color: Colors.black45,fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ),
          ),
          Padding(
            padding:  EdgeInsets.symmetric(vertical: 8.0,horizontal: 8),
            child: Text(
              "Today's Tasks",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection(AppConst.userCollection)
                  .doc(userId)
                  .collection(AppConst.taskCollectionPath)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.blue,));
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No tasks found. Add one!"));
                }

                final tasks = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: tasks.length,
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (context, index) {
                    var taskData = tasks[index].data();
                    bool isCompleted = taskData['isCompleted'] ?? false;
                    String taskId = tasks[index].id;
                    var dateValue = taskData['date'];
                    String formattedDate = "";

                    if (dateValue is Timestamp) {
                      formattedDate = DateFormat(
                        'dd-MM-yyyy',
                      ).format(dateValue.toDate());
                    } else {
                      formattedDate = dateValue?.toString() ?? "No Date";
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      color: Colors.purple.shade50,
                      child: Column(
                        children: [
                          CheckboxListTile(
                            activeColor: Colors.green,
                            controlAffinity: ListTileControlAffinity.leading,

                            title: Text(
                              taskData['title'] ?? 'No Title',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(taskData['desc'] ?? ''),
                                SizedBox(height: 5),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          formattedDate.isEmpty
                                              ? "No Date"
                                              : formattedDate,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 10),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: isCompleted
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        isCompleted ? "Completed" : "Pending",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isCompleted
                                              ? Colors.green
                                              : Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 80),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_note,
                                        color: Colors.blueGrey,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UpdateTaskScreen(
                                                  taskData: taskData,
                                                  // Pass the task map
                                                  docId: tasks[index]
                                                      .id, // Pass the document ID
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_forever,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text(
                                                "Delete Task",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              content: Text(
                                                "Are you sure you want to delete this task?",
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text("Cancel"),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Task Deleted !!")));
                                                    Navigator.pop(context);
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection(
                                                          AppConst
                                                              .userCollection,
                                                        )
                                                        .doc(userId)
                                                        .collection(
                                                          AppConst
                                                              .taskCollectionPath,
                                                        )
                                                        .doc(taskId)
                                                        .delete();
                                                  },
                                                  child: const Text(
                                                    "Delete",
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            value: isCompleted,
                            onChanged: (bool? value) async {
                              await FirebaseFirestore.instance
                                  .collection(AppConst.userCollection)
                                  .doc(userId)
                                  .collection(AppConst.taskCollectionPath)
                                  .doc(taskId)
                                  .update({'isCompleted': value});
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addTaskscreen);
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
    );
  }
}
