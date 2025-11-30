import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String petId;
  final String petName;
  final String userId;
  final String date;
  final String time;
  final String status;

  Appointment({
    required this.id,
    required this.petId,
    required this.petName,
    required this.userId,
    required this.date,
    required this.time,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      "petId": petId,
      "petName": petName,
      "userId": userId,
      "date": date,
      "time": time,
      "status": status,
    };
  }

  factory Appointment.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Appointment(
      id: doc.id, // FIXED!
      petId: d["petId"],
      petName: d["petName"],
      userId: d["userId"],
      date: d["date"],
      time: d["time"],
      status: d["status"],
    );
  }
}
