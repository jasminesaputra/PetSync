import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pet.dart';
import '../services/firestore_service.dart';
import 'pet_detail_screen.dart';

class CategoryScreen extends StatelessWidget {
  final String species; // “Dog”, “Cat”, “All”

  const CategoryScreen({super.key, required this.species});

  @override
  Widget build(BuildContext context) {
    final fs = Provider.of<FirestoreService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5E9FF),
      appBar: AppBar(
        title: Text("$species Pets"),
        backgroundColor: const Color(0xFFF5E9FF),
        foregroundColor: const Color(0xFF7C3AED),
        elevation: 0,
      ),

      body: StreamBuilder<List<Pet>>(
        stream: fs.streamAllPets(),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Pet> pets = snap.data!;

          if (species != "All") {
            pets = pets.where((e) => e.species == species).toList();
          }

          if (pets.isEmpty) {
            return const Center(child: Text("No pets found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: pets.length,
            itemBuilder: (_, i) => _tile(context, pets[i]),
          );
        },
      ),
    );
  }

  // --- FIXED TILE WITH CLOUDINARY-SAFE IMAGE ---
  Widget _tile(BuildContext context, Pet p) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            p.imageUrl.trim(),
            width: 55,
            height: 55,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const SizedBox(
                width: 55,
                height: 55,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            },
            errorBuilder: (context, _, __) => Container(
              width: 55,
              height: 55,
              color: Colors.grey.shade300,
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        ),
        title: Text(p.name),
        subtitle: Text(p.breed),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PetDetailScreen(pet: p)),
        ),
      ),
    );
  }
}
