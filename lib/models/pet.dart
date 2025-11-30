import 'package:cloud_firestore/cloud_firestore.dart';

class Pet {
  final String id;
  final String name;
  final String species;
  final String breed;
  final String age;
  final String location;
  final String imageUrl;
  final String description;

  Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.location,
    required this.imageUrl,
    required this.description,
  });

  factory Pet.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Pet(
      id: doc.id,
      name: d["name"] ?? "",
      species: d["species"] ?? "",
      breed: d["breed"] ?? "",
      age: d["age"].toString(),
      location: d["location"] ?? "",
      imageUrl: d["imageUrl"] ?? "",
      description: d["description"] ?? "",
    );
  }
}
