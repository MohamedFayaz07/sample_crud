import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  List<dynamic> records = [];
  bool isLoading = true;

  final List<String> itUsers = [
    "IT User 01",
    "IT User 02",
    "IT User 03",
    "IT User 04",
  ];

  final TextEditingController descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    setState(() => isLoading = true);
    final result = await _authService.getNotes();
    setState(() {
      isLoading = false;
      if (result['success'] == true) {
        records = result['data'] ?? [];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Fetch Error: ${result['message']}")),
        );
        if (result['message'].toString().contains('token')) {
          _logout();
        }
      }
    });
  }

  void _logout() async {
    await _authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home - CRUD Table", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black87),
            onPressed: _logout,
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: records.isEmpty
                          ? Center(child: Text("No Records Found", style: TextStyle(fontSize: 16)))
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                child: DataTable(
                                  columnSpacing: 20,
                                  headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
                                  columns: const [
                                    DataColumn(label: Text("ID")),
                                    DataColumn(label: Text("Description")),
                                    DataColumn(label: Text("User Type")),
                                    DataColumn(label: Text("Actions")),
                                  ],
                                  rows: List.generate(records.length, (index) {
                                    final r = records[index];
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(r["id"].toString())),
                                        DataCell(Text(r["description"] ?? "")),
                                        DataCell(Text(r["user_type"] ?? "")),
                                        DataCell(Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.edit, color: Colors.blue),
                                              onPressed: () => _openEditDialog(index),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete, color: Colors.red),
                                              onPressed: () => _deleteRecord(r["id"]),
                                            ),
                                          ],
                                        )),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
        onPressed: _openAddDialog,
      ),
    );
  }

  void _openAddDialog() {
    descController.clear();
    String? localSelectedUser;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Add Record"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: "Description"),
              ),
              SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Select User"),
                value: localSelectedUser,
                items: itUsers.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    localSelectedUser = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(child: Text("Cancel"), onPressed: () => Navigator.pop(context)),
            ElevatedButton(
              child: Text("Add"),
              onPressed: () async {
                if (descController.text.isNotEmpty && localSelectedUser != null) {
                  final result = await _authService.addNote(descController.text, localSelectedUser!);
                  if (result['success']) {
                    _fetchNotes();
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: ${result['message']}")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please fill all fields")),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openEditDialog(int index) {
    final record = records[index];
    descController.text = record["description"] ?? "";
    String? localSelectedUser = record["user_type"];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Edit Record"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: "Description"),
              ),
              SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Select User"),
                value: localSelectedUser,
                items: itUsers.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    localSelectedUser = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(child: Text("Cancel"), onPressed: () => Navigator.pop(context)),
            ElevatedButton(
              child: Text("Update"),
              onPressed: () async {
                if (descController.text.isNotEmpty && localSelectedUser != null) {
                  final result = await _authService.updateNote(record["id"], descController.text, localSelectedUser!);
                  if (result['success']) {
                    _fetchNotes();
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: ${result['message']}")),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteRecord(int id) async {
    final result = await _authService.deleteNote(id);
    if (result['success']) {
      _fetchNotes();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${result['message']}")),
      );
    }
  }
}
