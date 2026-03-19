import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:plant_identifier/models/flower_data.dart';


// MODIFICARE: Am schimbat din StatefulWidget în StatelessWidget
class FlowerDetailScreen extends StatelessWidget {
  final Map<String, dynamic> flowerData;

  const FlowerDetailScreen({super.key, required this.flowerData});

  @override
  Widget build(BuildContext context) {
    String name = flowerData['name'] ?? 'Necunoscut';
    String scientificName = FlowerData.getScientificName(flowerData['scientific_name']) ?? 'Necunoscut';
    String description = flowerData['description'] ?? 'Fără descriere';
    Map<String, dynamic> careTips = flowerData['care_tips'] ?? 'Fără sfaturi';
    
    // Parsare sigură a confidence-ului
    double confidence = 0.0;
    if (flowerData['confidence'] != null) {
      confidence = double.tryParse(flowerData['confidence'].toString()) ?? 0.0;
    }
    
    // Extragere imagine Base64
    String base64Image = flowerData['image_base64'] ?? '';

    Widget imageWidget;
    if (base64Image.isNotEmpty) {
      try {
        imageWidget = Image.memory(
          base64Decode(base64Image),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      } catch (e) {
        imageWidget = Container(color: Colors.grey, child: const Icon(Icons.broken_image));
      }
    } else {
      imageWidget = Container(
        color: Colors.grey[900],
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            size: 100,
            color: Colors.white,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: CustomScrollView(
        slivers: [
          // --- HEADER CU POZA MARE ---
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            backgroundColor: const Color(0xFF121212),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: imageWidget,
            ),
          ),

          // --- CONȚINUT TEXT ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- NUME ȘTIINȚIFIC ---
                  if (scientificName.isNotEmpty && scientificName != 'Necunoscut') ...[
                    const Text(
                      "Denumire Științifică",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      scientificName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // --- CONFIDENCE (Procentaj) ---
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified, color: Color(0xFF10B981), size: 16),
                            const SizedBox(width: 8),
                            Text(
                              "Identificat cu ${confidence.toStringAsFixed(1)}% precizie",
                              style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 20),

                  // --- DESCRIERE ---
                  const Text(
                    "Despre această plantă",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey[300], fontSize: 16, height: 1.5),
                  ),
                  
                  const SizedBox(height: 20),

                  const Text(
                    "Sfaturi de îngrijire:",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Column(
                     children: [
                      _buildCareTip(Icons.water_drop, "Apă", careTips['udare']),
                      _buildCareTip(Icons.wb_sunny, "Lumină", careTips['lumina']),
                      _buildCareTip(Icons.landscape, "Sol", careTips['sol']),
                      _buildCareTip(Icons.thermostat, "Temperatură",careTips['temperatura']),
                      _buildCareTip(Icons.bug_report, "Dăunători", careTips['daunatori']),
                      _buildCareTip(Icons.info, "Dificultate", careTips['dificultate']),
                      _buildCareTip(Icons.pets, "Pet Friendly", careTips['pet_friendly']),
                      _buildCareTip(Icons.description, "Sfat general", careTips['sfat_general'])
                    ],
                  ),
                  const SizedBox(height: 50,)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildCareTip(IconData icon, String title, String? content) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.green, size: 24),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title.toUpperCase(), 
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              Text(content ?? "Se încarcă...", 
                style: TextStyle(fontSize: 16, color: Colors.white)),
            ],
          ),
        ),
      ],
    ),
  );
}