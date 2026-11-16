import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manger/widgets/constant/app_const.dart';

class UpdateTaskScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> taskData;
  const UpdateTaskScreen({super.key, required this.docId, required this.taskData});

  @override
  State<UpdateTaskScreen> createState() => _UpdateTaskScreenState();

}

class _UpdateTaskScreenState extends State<UpdateTaskScreen> {



  DateTime? selectedDate;
  final TextEditingController dateController = TextEditingController();
  var titleController = TextEditingController();
  var descController = TextEditingController();
  String selectedStatus = "Pending";
  List<String> statusList = ["Pending","In Progress", "Completed"];

  String uid = " ";
  FirebaseFirestore? firestore;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> mData = [];

  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance;
    initilazeUID();
    titleController.text = widget.taskData['title'] ?? "";
    descController.text = widget.taskData['desc'] ?? "";
    dateController.text = widget.taskData['date'] ?? "";
    selectedStatus = widget.taskData['status'] ?? "Pending";
  }

  void initilazeUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString("uid") ?? " ";
    setState(() {});
  }


  void updateTask({
    required String title,
    required String desc,
    required String docId,
  }) async {
    firestore!
        .collection(AppConst.userCollection)
        .doc(uid)
        .collection(AppConst.taskCollectionPath)
        .doc(docId)
        .update({"title": title, "desc": desc,"date":dateController.text,"status":selectedStatus});
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Update Task",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 21),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 11, horizontal: 11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Title",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 7),
        
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: "Enter task title",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 17),
              Text(
                "Description",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 7),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Enter task description",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 17),
              Text(
                "Date",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 7),
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: "Select date",
                  suffixIcon: Icon(Icons.calendar_today),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now().subtract(Duration(days: 732)),
                    lastDate: DateTime.now(),
                  );
        
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                      dateController.text = DateFormat(
                        'dd-MM-yyyy',
                      ).format(pickedDate);
                    });
                  }
                },
              ),
              SizedBox(height: 17),
              Text(
                "Status",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 7),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                items: statusList.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedStatus = newValue!;
                  });
                },
              ),
              SizedBox(height: 17),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                   updateTask(title: titleController.text, desc: descController.text, docId: widget.docId);
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Task updated !!"),backgroundColor: Colors.green,));
        
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    fixedSize: Size(100, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: Text("Update Task", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
