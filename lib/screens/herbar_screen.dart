import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plant_identifier/models/flower_data.dart';
import '../servicies/db_service.dart';
import 'flower_detail_screen.dart';

class HerbarScreen extends StatefulWidget {
  const HerbarScreen({super.key});

  @override
  State<HerbarScreen> createState() => _HerbarScreenState();
}

class _HerbarScreenState extends State<HerbarScreen> {
  late TextEditingController searchController;
  String searchQuery = "";
  bool showOnlyFavorites = false;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  final DBService dbService = DBService();
  
  return Scaffold(
    backgroundColor: const Color(0xFF121212),
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text("Herbarul Meu", style: TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
    ),
    body: Column(
      children: [
        // --- HEADER FIX (Search + Favorite) ---
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Caută o floare...",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF10B981)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  setState(() {
                    showOnlyFavorites = !showOnlyFavorites;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: showOnlyFavorites ? const Color(0xFF10B981) : Colors.grey[900],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.favorite, color: Colors.white),
                ),
              )
            ],
          ),
        ),

        // --- LISTA DINAMICĂ DE PLANTE ---
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: dbService.getFlowersStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Center(child: Text("Eroare."));
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
              }

              // --- FILTRARE DINAMICĂ (pe baza căutării și a stării de favorite) ---
              final docs = (snapshot.data?.docs ?? []).where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = (data['name'] ?? '').toString().toLowerCase();
                final isFav = data['is_favorite'] ?? false;
                return name.contains(searchQuery) && (showOnlyFavorites ? isFav : true);
              }).toList();

              if (docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.eco_outlined, size: 80, color: Colors.grey[800]),
                      const SizedBox(height: 10),
                      Text(searchQuery.isEmpty ? "Nu ai nicio plantă." : "Niciun rezultat.", 
                           style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var doc = docs[index];
                  var data = doc.data() as Map<String, dynamic>;

                  String name = data['name'] ?? 'Necunoscută';
                  String scientificName = FlowerData.getScientificName(data['scientific_name']) ?? '';
                  double confidence = double.tryParse(data['confidence']?.toString() ?? '0') ?? 0.0;

                  Widget imageWidget;
                  String? base64String = data['image_base64'];
                  if (base64String != null && base64String.isNotEmpty) {
                    try {
                      imageWidget = Image.memory(base64Decode(base64String), fit: BoxFit.cover, gaplessPlayback: true);
                    } catch (e) { imageWidget = const Icon(Icons.broken_image); }
                  } else { imageWidget = const Icon(Icons.image_not_supported); }

                  Timestamp? ts = data['timestamp'];
                  String dateStr = ts != null ? "${ts.toDate().day}/${ts.toDate().month}/${ts.toDate().year}" : "";

                  return Dismissible(
                    key: Key(doc.id),
                    direction: DismissDirection.horizontal,
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(color: Colors.yellow[800], borderRadius: BorderRadius.circular(20)),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      child: const Icon(Icons.favorite, color: Colors.white),
                    ),
                    secondaryBackground: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(color: Colors.red[800], borderRadius: BorderRadius.circular(20)),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      if(direction == DismissDirection.endToStart) dbService.deleteFlower(doc.id);
                    },
                    confirmDismiss: (direction) async {
                      if(direction == DismissDirection.endToStart) {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.grey[900],
                            title: const Text("Ștergi planta?", style: TextStyle(color: Colors.white)),
                            content: Text("Sigur vrei să ștergi $name?"),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Nu")),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Da", style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        );
                      } else {
                        bool newStatus = !(data['is_favorite'] ?? false);
                        final snackBar = SnackBar(
                          backgroundColor: newStatus ? Colors.green[700] : Colors.yellow[700], 
                          content: Text(
                            newStatus ? "Adăugat la favorite" : "Eliminat din favorite", 
                            style: TextStyle(color: newStatus ? Colors.white : Colors.black)
                            ), 
                          duration: const Duration(seconds: 2));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        dbService.updateFavoriteStatus(doc.id, newStatus);
                        return false; 
                      }
                    },
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => FlowerDetailScreen(flowerData: data))),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(15)),
                              child: ClipRRect(borderRadius: BorderRadius.circular(15), child: imageWidget),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                      GestureDetector(
                                        onTap: () {
                                          bool newStatus = !(data['is_favorite'] ?? false);
                                          dbService.updateFavoriteStatus(doc.id, newStatus);
                                          final snackBar = SnackBar(
                                            backgroundColor: newStatus ? Colors.green[700] : Colors.yellow[700], 
                                            content: Text(
                                              newStatus ? "Adăugat la favorite" : "Eliminat din favorite", 
                                              style: TextStyle(color: newStatus ? Colors.white : Colors.black)
                                              ), 
                                            duration: const Duration(seconds: 2));

                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        
                                        },
                                        child: Icon(
                                          data['is_favorite'] == true ? Icons.favorite : Icons.favorite_border, color: data['is_favorite'] == true ? Colors.yellow[700] : Colors.grey,),
                                      ),
                                    ],
                                  ),
                                  if (scientificName.isNotEmpty) 
                                  Text(
                                    scientificName, 
                                    style: TextStyle(
                                      color: Colors.grey[400], 
                                      fontSize: 13, 
                                      fontStyle: FontStyle.italic)
                                    ),

                                  const SizedBox(height: 8),

                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981).withOpacity(0.15), 
                                          borderRadius: BorderRadius.circular(8)
                                          ),
                                        child: Text(
                                          "${confidence.toStringAsFixed(1)}%", 
                                          style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold)),
                                      ),
                                      const Spacer(),
                                      Text(dateStr, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  );
  }
}