import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/appointment.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final fs = Provider.of<FirestoreService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5E9FF),
      appBar: AppBar(
        title: const Text("Your Profile"),
        backgroundColor: const Color(0xFFF5E9FF),
        foregroundColor: const Color(0xFF7C3AED),
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =============================
            // USER INFO
            // =============================
            Text(
              auth.currentUserEmail(),
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF7C3AED),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "User ID: ${auth.getUid()}",
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),

            const SizedBox(height: 25),

            // =============================
            // APPOINTMENTS TITLE
            // =============================
            const Text(
              "Your Appointments",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7C3AED),
              ),
            ),

            const SizedBox(height: 12),

            // =============================
            // APPOINTMENTS STREAM
            // =============================
            Expanded(
              child: StreamBuilder<List<Appointment>>(
                stream: fs.streamAppointments(auth.getUid()),
                builder: (_, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snap.hasData || snap.data!.isEmpty) {
                    return const Center(child: Text("No appointments yet."));
                  }

                  final appts = snap.data!;

                  return ListView.builder(
                    itemCount: appts.length,
                    itemBuilder: (_, i) => _appointmentCard(context, appts[i]),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // =============================
            // LOGOUT BUTTON
            // =============================
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C6BFF),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () async {
                await auth.signOut();
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // APPOINTMENT CARD (Clean UI)
  // ==========================================
  Widget _appointmentCard(BuildContext context, Appointment a) {
    final fs = Provider.of<FirestoreService>(context, listen: false);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.pets, color: Color(0xFF7C3AED), size: 32),
            const SizedBox(width: 12),

            // TEXT SECTION
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.petName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${a.date} • ${a.time}",
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 6),

                  // STATUS BADGE
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: a.status == "cancelled"
                          ? Colors.red.shade100
                          : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      a.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: a.status == "cancelled"
                            ? Colors.red.shade700
                            : Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // CANCEL BUTTON
            if (a.status != "cancelled")
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                onPressed: () async {
                  fs.cancelAppointment(a.id);
                },
              ),
          ],
        ),
      ),
    );
  }
}
