import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/pet.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class PetDetailScreen extends StatefulWidget {
  final Pet pet;
  const PetDetailScreen({super.key, required this.pet});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  Future<void> _bookAppointment() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final fs = Provider.of<FirestoreService>(context, listen: false);

    // LOGIN CHECK (SAFE)
    final user = auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("You must login first.")));
      return;
    }

    // SELECT DATE
    final datePick = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (datePick == null) return;

    // SELECT TIME
    if (!mounted) return;
    final timePick = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );

    if (timePick == null) return;

    final formattedDate = DateFormat("yyyy-MM-dd").format(datePick);
    if (!mounted) return;
    final formattedTime = timePick.format(context);

    // SAFETY CHECK BEFORE ASYNC CALL
    if (!mounted) return;

    // CREATE APPOINTMENT
    await fs.createAppointment(
      petId: widget.pet.id,
      petName: widget.pet.name,
      userId: auth.getUid(),
      date: formattedDate,
      time: formattedTime,
    );

    // SAFETY CHECK AFTER ASYNC CALL
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Appointment booked for $formattedDate at $formattedTime",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pet;

    return Scaffold(
      appBar: AppBar(
        title: Text(p.name),
        backgroundColor: const Color(0xFFBFA6E2),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE SAFE CLOUDINARY SUPPORT
            LayoutBuilder(
              builder: (context, constraints) {
                final imgWidth = constraints.maxWidth * 0.7;

                return Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      p.imageUrl,
                      width: imgWidth,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            _info("Name", p.name),
            _info("Species", p.species),
            _info("Breed", p.breed),
            _info("Age", p.age.toString()),
            _info("Location", p.location),

            const SizedBox(height: 20),

            Text(p.description, style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 25),

            // BOOK BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _bookAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBFA6E2),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Book Appointment",
                  style: TextStyle(fontSize: 17, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
