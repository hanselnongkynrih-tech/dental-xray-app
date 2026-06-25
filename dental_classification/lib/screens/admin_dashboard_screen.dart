import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../api/api_client.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {

  final AuthService _authService = AuthService();

  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> images = [];
  List<Map<String, dynamic>> appointments = [];

  int doctors = 0;
  int patients = 0;
  int labs = 0;
  int admins = 0;

  bool isLoadingUsers = true;
  bool isLoadingImages = true;
  bool isLoadingAppointments = true;

  String selectedPage = ""; // 🔥 NOTHING selected initially

  @override
  void initState() {
    super.initState();
    fetchUsers();
    fetchImages();
    fetchAppointments();
  }

  // =========================
  // FETCH USERS
  // =========================
  Future<void> fetchUsers() async {
    final token = await _authService.getToken();
    debugPrint("USERS TOKEN = $token");

    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/users/all'),
      headers: {'Authorization': 'Bearer $token'},
    );
    debugPrint("USERS STATUS = ${response.statusCode}");
    debugPrint("USERS BODY = ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      setState(() {

        users = data.cast<Map<String, dynamic>>();

        doctors = users
            .where((u) => u['role'] == "doctor")
            .length;

        patients = users
            .where((u) => u['role'] == "patient")
            .length;

        labs = users
            .where((u) => u['role'] == "lab")
            .length;

        admins = users
            .where((u) => u['role'] == "admin")
            .length;

        isLoadingUsers = false;
      });
    }
  }

  // =========================
  // FETCH IMAGES
  // =========================
  Future<void> fetchImages() async {
    final token = await _authService.getToken();
    debugPrint("IMAGES TOKEN = $token");

    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/images/all'),
      headers: {'Authorization': 'Bearer $token'},
    );
    debugPrint("IMAGES STATUS = ${response.statusCode}");
    debugPrint("IMAGES BODY = ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      setState(() {
        images = data.cast<Map<String, dynamic>>();
        isLoadingImages = false;
      });
    }
  }

  // =========================
  // FETCH Appointments
  // =========================
  Future<void> fetchAppointments() async {

    final token = await _authService.getToken();
    debugPrint("APPOINTMENTS TOKEN = $token");

    final response = await http.get(
      Uri.parse(
        '${Constants.apiBaseUrl}/appointments/admin/all',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    debugPrint("APPOINTMENTS STATUS = ${response.statusCode}");
    debugPrint("APPOINTMENTS BODY = ${response.body}");

    if (response.statusCode == 200) {

      final List<dynamic> data =
      jsonDecode(response.body);

      setState(() {
        appointments =
            data.cast<Map<String, dynamic>>();

        isLoadingAppointments = false;
      });
    }
  }

  // =========================
  // DELETE USER
  // =========================
  Future<void> deleteUser(int id) async {
    final token = await _authService.getToken();

    await http.delete(
      Uri.parse('${Constants.apiBaseUrl}/users/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    fetchUsers();
  }

  // =========================
  // UPDATE ROLE
  // =========================
  Future<void> updateRole(int id, String role) async {
    final token = await _authService.getToken();

    await http.put(
      Uri.parse('${Constants.apiBaseUrl}/users/$id?role=$role'),
      headers: {'Authorization': 'Bearer $token'},
    );

    fetchUsers();
  }

  // =========================
  // DELETE IMAGE
  // =========================
  Future<void> deleteImage(int id) async {
    final token = await _authService.getToken();

    await http.delete(
      Uri.parse('${Constants.apiBaseUrl}/images/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    fetchImages();
  }

  // =========================
  // BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // 🔷 DRAWER
      drawer: _buildDrawer(context),

      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),

      body: Column(
        children: [

          // 🔷 HEADER
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2F6BFF), Color(0xFF4A8CFF)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Welcome Admin",
                          style: TextStyle(color: Colors.white70)),
                      SizedBox(height: 5),
                      Text(
                        "Dental Clinic Control Center",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        "${appointments.length} appointments • "
                            "${users.length} users",
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.admin_panel_settings,
                    color: Colors.white, size: 50),
              ],
            ),
          ),

          // 🔷 STATS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [

                Row(
                  children: [

                    _StatCard(
                      "Doctors",
                      doctors.toString(),
                      Icons.medical_services,
                    ),

                    _StatCard(
                      "Patients",
                      patients.toString(),
                      Icons.people,
                    ),

                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [

                    _StatCard(
                      "Labs",
                      labs.toString(),
                      Icons.science,
                    ),

                    _StatCard(
                      "Admins",
                      admins.toString(),
                      Icons.admin_panel_settings,
                    ),

                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [

                    _StatCard(
                      "Appointments",
                      appointments.length.toString(),
                      Icons.calendar_today,
                    ),

                    _StatCard(
                      "Pending",
                      appointments
                          .where(
                            (a) => a['status'] == "pending",
                      )
                          .length
                          .toString(),
                      Icons.pending_actions,
                    ),

                  ],
                ),

              ],
            ),
          ),

          const SizedBox(height: 10),

          // 🔷 CONTENT AREA
          Expanded(
            child: selectedPage == "users"
                ? _buildUsers()
                : selectedPage == "images"
                ? _buildImages()
                : selectedPage == "appointments"
                ? _buildAppointments()
                : ListView(
              padding: const EdgeInsets.all(16),

              children: [

                const Text(
                  "Recent Appointments",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                if (appointments.isEmpty)

                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "No appointments yet",
                      ),
                    ),
                  )

                else

                  ...appointments.take(5).map(
                        (appointment) => Card(
                      elevation: 3,

                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),

                      child: ListTile(

                        leading: const CircleAvatar(
                          child: Icon(
                            Icons.calendar_today,
                          ),
                        ),

                        title: Text(
                          appointment['specialization']
                              .toString(),
                        ),

                        subtitle: Text(
                          "Patient ID: "
                              "${appointment['patient_id']}",
                        ),

                        trailing: Text(
                          appointment['status']
                              .toUpperCase(),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                const Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [

                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.calendar_today,
                        ),

                        label: const Text(
                          "Appointments",
                        ),

                        onPressed: () {
                          setState(() {
                            selectedPage =
                            "appointments";
                          });
                        },
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.people,
                        ),

                        label: const Text(
                          "Users",
                        ),

                        onPressed: () {
                          setState(() {
                            selectedPage =
                            "users";
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [

                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.image,
                        ),

                        label: const Text(
                          "Images",
                        ),

                        onPressed: () {
                          setState(() {
                            selectedPage =
                            "images";
                          });
                        },
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.refresh,
                        ),

                        label: const Text(
                          "Refresh",
                        ),

                        onPressed: () {
                          fetchUsers();
                          fetchImages();
                          fetchAppointments();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // DRAWER
  // =========================
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [

          Container(
            color: Colors.blue,
            padding: const EdgeInsets.all(20),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.admin_panel_settings,
                    color: Colors.white, size: 40),
                SizedBox(height: 10),
                Text("Admin",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                Text("Dashboard",
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          _drawerItem(Icons.people, "Users", () {
            Navigator.pop(context);
            setState(() => selectedPage = "users");
          }),

          _drawerItem(Icons.image, "Images", () {
            Navigator.pop(context);
            setState(() => selectedPage = "images");
          }),

          _drawerItem(
            Icons.calendar_today,
            "Appointments",
                () {
              Navigator.pop(context);
              setState(() => selectedPage = "appointments");
            },
          ),

          const Divider(),

          // 🔥 SAFE LOGOUT
          _drawerItem(Icons.logout, "Logout", () async {
            Navigator.pop(context);

            final navigator = Navigator.of(context);

            await _authService.logout();

            if (!mounted) return;

            navigator.pushNamedAndRemoveUntil(
                '/welcome', (route) => false);
          }, color: Colors.red),
        ],
      ),
    );
  }

  Widget _drawerItem(
      IconData icon,
      String title,
      VoidCallback onTap, {
        Color color = Colors.black,
      }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }

  // =========================
  // USERS VIEW
  // =========================
  Widget _buildUsers() {
    if (isLoadingUsers) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      children: users.map((user) {
        return Card(
          margin: const EdgeInsets.all(10),
          child: ListTile(
            title: Text(user['full_name']),
            subtitle: Text("${user['mobile_number']} • ${user['role']}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [

                PopupMenuButton<String>(
                  icon: const Icon(Icons.edit),
                  onSelected: (value) => updateRole(user['id'], value),
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: "patient", child: Text("Patient")),
                    PopupMenuItem(value: "doctor", child: Text("Doctor")),
                    PopupMenuItem(value: "lab", child: Text("Lab")),
                    PopupMenuItem(value: "admin", child: Text("Admin")),
                  ],
                ),

                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => deleteUser(user['id']),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // =========================
  // IMAGES VIEW
  // =========================
  Widget _buildImages() {
    if (isLoadingImages) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.count(
      crossAxisCount: 2,
      children: images.map((img) {
        return Card(
          margin: const EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                child: Image.network(
                  "${Constants.apiBaseUrl}/${img['image_path']}",
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteImage(img['id']),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAppointments() {

    if (isLoadingAppointments) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.builder(
      itemCount: appointments.length,

      itemBuilder: (context, index) {

        final appointment =
        appointments[index];

        return Card(
          elevation: 5,
          margin: const EdgeInsets.all(10),

          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(18),
          ),

          child: Padding(
            padding: const EdgeInsets.all(12),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  "Patient ID: ${appointment['patient_id']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  "Doctor ID: ${appointment['doctor_id']}",
                ),

                Text(
                  "Specialization: ${appointment['specialization']}",
                ),

                Text(
                  "Date: ${appointment['date']}",
                ),

                Text(
                  "Time: ${appointment['time']}",
                ),

                const SizedBox(height: 10),

                Divider(),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: appointment['status'] ==
                        "accepted"
                        ? Colors.green.shade100
                        : appointment['status'] ==
                        "pending"
                        ? Colors.orange.shade100
                        : Colors.red.shade100,

                    borderRadius:
                    BorderRadius.circular(20),
                  ),

                  child: Text(
                    appointment['status']
                        .toUpperCase(),

                    style: TextStyle(
                      color: appointment['status'] ==
                          "accepted"
                          ? Colors.green.shade900
                          : appointment['status'] ==
                          "pending"
                          ? Colors.orange.shade900
                          : Colors.red.shade900,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                if (appointment['status'] == "pending")
                  Row(
                    children: [

                      Expanded(
                        child: ElevatedButton(

                          onPressed: () async {

                            await ApiClient()
                                .updateAppointmentStatus(
                              appointmentId:
                              appointment['id'],
                              status: "accepted",
                            );

                            fetchAppointments();
                          },

                          child: const Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check),
                              SizedBox(width: 5),
                              Text("Accept"),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: ElevatedButton(

                          onPressed: () async {

                            await ApiClient()
                                .updateAppointmentStatus(
                              appointmentId:
                              appointment['id'],
                              status: "rejected",
                            );

                            fetchAppointments();
                          },

                          child: const Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Icon(Icons.close),
                              SizedBox(width: 5),
                              Text("Reject"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

              ],
            ),
          ),
        );
      },
    );
  }
}

// =========================
// STAT CARD
// =========================
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard(this.title, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(height: 10),
              Text(value,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}