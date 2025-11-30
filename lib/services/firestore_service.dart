import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pet.dart';
import '../models/appointment.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // PETS ------------------------------------------
  Stream<List<Pet>> streamAllPets() {
    return _db
        .collection("pets")
        .snapshots()
        .map((snap) => snap.docs.map((d) => Pet.fromDoc(d)).toList());
  }

  Future<Pet?> getPetById(String id) async {
    final doc = await _db.collection("pets").doc(id).get();
    return Pet.fromDoc(doc);
  }

  // APPOINTMENTS ----------------------------------
  Stream<List<Appointment>> streamAppointments(String userId) {
    return _db
        .collection("appointments")
        .where("userId", isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Appointment.fromDoc(d)).toList());
  }

  Future<void> createAppointment({
    required String petId,
    required String petName,
    required String userId,
    required String date,
    required String time,
  }) async {
    final id = const Uuid().v4();

    final appt = Appointment(
      id: id,
      petId: petId,
      petName: petName,
      userId: userId,
      date: date,
      time: time,
      status: "pending",
    );

    await _db.collection("appointments").doc(id).set(appt.toMap());
  }

  // NEW: CANCEL APPOINTMENT
  Future<void> cancelAppointment(String id) async {
    await _db.collection("appointments").doc(id).update({
      "status": "cancelled",
    });
  }
}
