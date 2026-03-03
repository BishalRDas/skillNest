import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome>
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
        title: const Text("SkillNest"),

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

            Tab(icon: Icon(Icons.history), text: "History"),

            Tab(icon: Icon(Icons.search), text: "Search"),
          ],
        ),
      ),

      body: TabBarView(
        controller: tabController,

        children: [AccountTab(), const HistoryTab(), const SearchTab()],
      ),
    );
  }
}

/// ACCOUNT TAB

class AccountTab extends StatelessWidget {
  AccountTab({super.key});

  final AuthService auth = AuthService();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 10),

            const CircleAvatar(
              radius: 55,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),

            const SizedBox(height: 15),

            const Text(
              "User Name",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            const Text(
              "user@email.com",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: width,

              child: Card(
                elevation: 5,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit, color: Colors.blue),

                        title: const Text("Edit Profile"),

                        trailing: const Icon(Icons.arrow_forward_ios),
                      ),

                      const Divider(),

                      ListTile(
                        leading: const Icon(Icons.settings, color: Colors.blue),

                        title: const Text("Settings"),

                        trailing: const Icon(Icons.arrow_forward_ios),
                      ),

                      const Divider(),

                      /// LOGOUT BUTTON
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),

                        title: const Text("Logout"),

                        onTap: () async {
                          await auth.logout();

                          Navigator.pushAndRemoveUntil(
                            context,

                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),

                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// HISTORY TAB

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();

    return StreamBuilder<QuerySnapshot>(
      stream: db.getUserHistory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var jobs = snapshot.data!.docs;

        if (jobs.isEmpty) {
          return const Center(child: Text("No Job History"));
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
                title: Text(job['workerName']),
                subtitle: Text("Status: ${job['status']}"),
              ),
            );
          },
        );
      },
    );
  }
}

/// SEARCH TAB

class SearchTab extends StatelessWidget {
  const SearchTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: StreamBuilder<QuerySnapshot>(
        stream: db.getWorkers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var workers = snapshot.data!.docs;

          return ListView.builder(
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
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(worker['name']),
                  subtitle: Text(worker['skill']),
                  trailing: ElevatedButton(
                    child: const Text("Hire"),
                    onPressed: () async {
                      await db.sendJobRequest(
                        workerId: worker.id,
                        workerName: worker['name'],
                        skill: worker['skill'],
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Job Request Sent")),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
