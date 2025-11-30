import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/pet.dart';
import 'pet_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late PageController _pageController;
  final TextEditingController _searchCtl = TextEditingController();

  Timer? _timer;
  int _current = 0;
  String _query = "";

  String _selected = "All";

  final List<String> categories = ["All", "Dog", "Cat", "Reptile"];

  @override
  void initState() {
    super.initState();

    _pageController = PageController(viewportFraction: 0.86);

    _searchCtl.addListener(() {
      setState(() => _query = _searchCtl.text.trim().toLowerCase());
    });

    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_pageController.hasClients) return;
      final next = (_current + 1) % 5;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
      _current = next;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _searchCtl.dispose();
    super.dispose();
  }

  bool _matches(Pet p, String q) {
    if (q.isEmpty) return true;
    final text = "${p.name} ${p.breed} ${p.location} ${p.species}"
        .toLowerCase();
    return text.contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final fs = Provider.of<FirestoreService>(context, listen: false);
    final purple = Colors.deepPurple.shade400;
    const bg = Color(0xFFF3E8FF);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: purple,
        title: const Text("PetSync", style: TextStyle(color: Colors.white)),
      ),
      body: _homePage(context, fs),
    );
  }

  Widget _homePage(BuildContext context, FirestoreService fs) {
    final purple = Colors.deepPurple.shade700;
    final width = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome 👋",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: purple,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Find your perfect companion from shelters nearby. "
            "This app is a project for PPB Praktikum made by Jasmine Saputra (21120123140145).",
            style: TextStyle(color: Colors.deepPurple.shade300),
          ),
          const SizedBox(height: 20),

          // Search Box
          TextField(
            controller: _searchCtl,
            decoration: InputDecoration(
              hintText: "Search pets...",
              prefixIcon: Icon(Icons.search, color: Colors.deepPurple.shade300),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            "Featured",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: purple,
            ),
          ),
          const SizedBox(height: 12),

          // Carousel
          SizedBox(
            height: width < 600 ? 300 : 380,
            child: StreamBuilder<List<Pet>>(
              stream: fs.streamAllPets(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final all = snap.data!;
                all.shuffle();
                final featured = all.take(5).toList();

                return PageView.builder(
                  controller: _pageController,
                  itemCount: featured.length,
                  onPageChanged: (i) => setState(() => _current = i),
                  itemBuilder: (_, i) => _carouselCard(featured[i]),
                );
              },
            ),
          ),

          const SizedBox(height: 18),
          Center(child: _indicatorDots()),
          const SizedBox(height: 20),

          // Category Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                final bool active = _selected == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selected = cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: active ? Colors.deepPurple.shade400 : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.deepPurple.shade200,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: active
                            ? Colors.white
                            : Colors.deepPurple.shade400,
                        fontWeight: active
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            "All Pets",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: purple,
            ),
          ),
          const SizedBox(height: 12),

          StreamBuilder<List<Pet>>(
            stream: fs.streamAllPets(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var pets = snap.data!.where((p) => _matches(p, _query)).toList();

              if (_selected != "All") {
                pets = pets.where((p) => p.species == _selected).toList();
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _petTile(pets[i]),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------- Carousel Card ----------------
  Widget _carouselCard(Pet p) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PetDetailScreen(pet: p)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.shade200.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    p.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (c, o, s) =>
                        const Icon(Icons.broken_image, size: 100),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Opacity(
                    opacity: 0.9,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        p.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _indicatorDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _current == i ? 12 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: _current == i
                ? Colors.deepPurple.shade400
                : Colors.deepPurple.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _petTile(Pet p) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.shade200.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              p.imageUrl,
              fit: BoxFit.cover,
              height: double.infinity,
              errorBuilder: (c, o, s) =>
                  const Icon(Icons.broken_image, size: 40),
            ),
          ),
        ),
        title: Text(
          p.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple.shade700,
          ),
        ),
        subtitle: Text(
          "${p.breed} — ${p.location}",
          style: TextStyle(color: Colors.deepPurple.shade300),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PetDetailScreen(pet: p)),
        ),
      ),
    );
  }
}
