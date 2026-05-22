import 'package:flutter/material.dart';
import '../api/api_client.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState
    extends State<DoctorAppointmentsScreen> {

  List<dynamic> appointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    try {
      final data = await ApiClient().getDoctorAppointments();

      setState(() {
        appointments = data;
        isLoading = false;
      });

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointments"),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : appointments.isEmpty
          ? const Center(
        child: Text("No appointments"),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {

          final appt = appointments[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  Text(
                    "Patient ID: ${appt['patient_id']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                      "Treatment: ${appt['specialization']}"),
                  Text("Date: ${appt['date']}"),
                  Text("Time: ${appt['time']}"),

                  const SizedBox(height: 12),

                  if (appt['status'] == "pending")
                    Row(
                      children: [

                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {

                              await ApiClient()
                                  .updateAppointmentStatus(
                                appointmentId:
                                appt['id'],
                                status: "accepted",
                              );

                              loadAppointments();
                            },
                            style:
                            ElevatedButton.styleFrom(
                              backgroundColor:
                              Colors.green,
                            ),
                            child:
                            const Text("Accept"),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {

                              await ApiClient()
                                  .updateAppointmentStatus(
                                appointmentId:
                                appt['id'],
                                status: "rejected",
                              );

                              loadAppointments();
                            },
                            style:
                            ElevatedButton.styleFrom(
                              backgroundColor:
                              Colors.red,
                            ),
                            child:
                            const Text("Reject"),
                          ),
                        ),
                      ],
                    )
                  else
                    Container(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: appt['status'] ==
                            "accepted"
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                      child: Text(
                        appt['status']
                            .toUpperCase(),
                        style: TextStyle(
                          color:
                          appt['status'] ==
                              "accepted"
                              ? Colors.green
                              : Colors.red,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}