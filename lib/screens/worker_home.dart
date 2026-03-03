import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'login_screen.dart';

class WorkerHome extends StatefulWidget {
  const WorkerHome({super.key});

  @override
  State<WorkerHome> createState() => _WorkerHomeState();
}

class _WorkerHomeState extends State<WorkerHome>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SkillNest Worker"),
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
            Tab(icon: Icon(Icons.person), text: "Account"),
            Tab(icon: Icon(Icons.work), text: "Requests"),
            Tab(icon: Icon(Icons.history), text: "History"),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: const [WorkerAccountTab(), RequestTab(), WorkerHistoryTab()],
      ),
    );
  }
}

/// ================= ACCOUNT TAB =================

class WorkerAccountTab extends StatelessWidget {
  const WorkerAccountTab({super.key});

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
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text(
            "Worker Profile",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                ListTile(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= REQUEST TAB =================

class RequestTab extends StatelessWidget {
  const RequestTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();

    return StreamBuilder<QuerySnapshot>(
      stream: db.getWorkerRequests(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var jobs = snapshot.data!.docs;

        if (jobs.isEmpty) {
          return const Center(child: Text("No Pending Requests"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            var job = jobs[index];

            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.build, color: Colors.white),
                      ),
                      title: Text(job['skill']),
                      subtitle: Text("Requested by: ${job['userEmail']}"),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await db.acceptJob(job.id);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text("Accept"),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await db.rejectJob(job.id);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text("Reject"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// ================= HISTORY TAB =================

class WorkerHistoryTab extends StatelessWidget {
  const WorkerHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();

    return StreamBuilder<QuerySnapshot>(
      stream: db.getWorkerHistory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var jobs = snapshot.data!.docs;

        if (jobs.isEmpty) {
          return const Center(child: Text("No Accepted Jobs"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            var job = jobs[index];

            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.check, color: Colors.white),
                ),
                title: Text(job['skill']),
                subtitle: Text("Client: ${job['userEmail']}"),
                trailing: const Text(
                  "Accepted",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
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
