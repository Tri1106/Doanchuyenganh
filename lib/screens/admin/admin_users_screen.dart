import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';

class AdminUsersScreen extends StatefulWidget {
  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List users = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future load() async {
    users = await AdminApiService.getUsers();
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, i) {
          final u = users[i];
          return Card(
            child: ListTile(
              title: Text(u["FullName"]),
              subtitle: Text(u["Email"]),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        bool ok = await AdminApiService.deleteUser(u["UserID"]);
                        if (ok) load();
                      }),
                ],
              ),
            ),
          );
        });
  }
}
