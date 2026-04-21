import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'login_screen.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SkillNest Admin"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff4A90E2), Color(0xff6FB1FC)],
            ),
          ),
        ),
        bottom: TabBar(
          controller: tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: "Users"),
            Tab(icon: Icon(Icons.engineering), text: "Workers"),
            Tab(icon: Icon(Icons.work), text: "Jobs"),
            Tab(icon: Icon(Icons.admin_panel_settings), text: "Account"),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: const [
          UsersTab(),
          WorkersTab(),
          JobsTab(),
          AdminAccountTab(),
        ],
      ),
    );
  }
}

/// ================= USERS TAB =================

class UsersTab extends StatelessWidget {
  const UsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("users").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var users = snapshot.data!.docs;

        if (users.isEmpty) {
          return const Center(child: Text("No Users Found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: users.length,
          itemBuilder: (context, index) {
            var user = users[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(user['name'] ?? "No Name"),
                subtitle: Text(user['email'] ?? ""),
                trailing: Text(
                  user['role'] ?? "",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// ================= WORKERS TAB =================

class WorkersTab extends StatelessWidget {
  const WorkersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("workers").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var workers = snapshot.data!.docs;

        if (workers.isEmpty) {
          return const Center(child: Text("No Workers Found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: workers.length,
          itemBuilder: (context, index) {
            var worker = workers[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.build, color: Colors.white),
                ),
                title: Text(worker['name'] ?? ""),
                subtitle: Text(worker['skill'] ?? ""),
              ),
            );
          },
        );
      },
    );
  }
}

/// ================= JOBS TAB =================

class JobsTab extends StatelessWidget {
  const JobsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();

    return StreamBuilder<QuerySnapshot>(
      stream: db.getAllJobs(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var jobs = snapshot.data!.docs;

        if (jobs.isEmpty) {
          return const Center(child: Text("No Jobs Found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            var job = jobs[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.work, color: Colors.white),
                ),
                title: Text(job['skill'] ?? ""),
                subtitle: Text(
                  "User: ${job['userEmail']} \nWorker: ${job['workerName']}",
                ),
                trailing: Text(
                  job['status'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: job['status'] == "accepted"
                        ? Colors.green
                        : job['status'] == "rejected"
                        ? Colors.red
                        : Colors.orange,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// ================= ADMIN ACCOUNT TAB =================

class AdminAccountTab extends StatelessWidget {
  const AdminAccountTab({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 55,
            backgroundColor: Colors.blue,
            child: Icon(
              Icons.admin_panel_settings,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Admin Panel",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: () async {
                await auth.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
