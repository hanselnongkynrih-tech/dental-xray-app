import 'package:flutter/material.dart';
import '../api/api_client.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final ApiClient apiClient = ApiClient();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  List<dynamic> doctors = [];
  int? selectedDoctorId;

  @override
  void initState() {
    super.initState();
    loadDoctors();
  }

  Future<void> loadDoctors() async {
    try {
      final data = await apiClient.getDoctors();
      setState(() => doctors = data);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  Future<void> pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() => selectedTime = time);
    }
  }

  Future<void> submit() async {
    if (selectedDate == null ||
        selectedTime == null ||
        selectedDoctorId == null) {
      return;
    }

    final date =
        "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}";
    final time = selectedTime!.format(context);

    try {
      await apiClient.createAppointment(
        date: date,
        time: time,
        doctorId: selectedDoctorId!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment booked")),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Widget _inputBox({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 10),
                Text(text),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Text("Book Appointment"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [

              /// 🔷 HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Book Appointment",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Schedule your dental checkup easily",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 📋 FORM CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [

                    /// 👨‍⚕️ DOCTOR DROPDOWN
                    DropdownButtonFormField<int>(
                      initialValue: selectedDoctorId,
                      decoration: InputDecoration(
                        labelText: "Select Doctor",
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: doctors.map((doc) {
                        return DropdownMenuItem<int>(
                          value: doc["id"],
                          child: Text(doc["full_name"]),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedDoctorId = value);
                      },
                    ),

                    const SizedBox(height: 16),

                    /// 📅 DATE
                    _inputBox(
                      text: selectedDate == null
                          ? "Select Date"
                          : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                      icon: Icons.calendar_today,
                      onTap: pickDate,
                    ),

                    const SizedBox(height: 16),

                    /// ⏰ TIME
                    _inputBox(
                      text: selectedTime == null
                          ? "Select Time"
                          : selectedTime!.format(context),
                      icon: Icons.access_time,
                      onTap: pickTime,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// 🚀 BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FACFE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Book Appointment",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}