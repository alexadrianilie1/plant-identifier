import 'dart:io';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_identifier/screens/auth_screen.dart';
import 'package:plant_identifier/servicies/auth_service.dart';

import '../servicies/plant_recognizer_service.dart';
import '../servicies/db_service.dart';
import '../servicies/location_service.dart';
import '../models/plant_result.dart';
import '../models/flower_data.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _cameraController;
  bool _isBusy = false;
  File? _pickedImage;
  PlantResult _plantResult = PlantResult.empty();

  final PlantRecognizerService _plantRecognizerService = PlantRecognizerService();
  final LocationService _locationService = LocationService();
  final ImagePicker _picker = ImagePicker();
  final DBService _dbService = DBService();

  Future<Position?>? _locationFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _plantRecognizerService.initialize();
    _locationFuture = _locationService.getCurrentLocation();

  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(cameras[0], ResolutionPreset.high);
        await _cameraController!.initialize();
        if (!mounted) return;
        setState(() {});
      }
    } catch (e) {
      print("Eroare camera: $e");
    }
  }

  Future<void> _analyzeImage(String path) async {
    if (_isBusy) return;

    setState(() {
      _isBusy = true;
      _plantResult = PlantResult(
        label: "Analizez...",
        confidence: 0.0,
        description: "Se proceseaza imaginea...",
        isIdentified: false,
        careTips: {},
      );
    });

    try {
      PlantResult result = await _plantRecognizerService.processImage(path);
      if (!mounted) return;
      setState(() {
        _plantResult = result;
      });
    } catch (e) {
      print("Eroare analiza: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
        _showResultSheet();
      }
    }
  }

  Future<void> _captureAndScan() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    try {
      final image = await _cameraController!.takePicture();
      setState(() => _pickedImage = File(image.path)); 
      await _analyzeImage(image.path);
    } catch (e) {
      print("Eroare camera: $e");
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 25);
    if (image == null) return; 

    setState(() {
      _pickedImage = File(image.path); 
    });
    await _analyzeImage(image.path);
  }

  void _showGuestRestrictionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Cont necesar", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Vizitatorii pot identifica plante, dar salvarea lor in herbar necesita un cont.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Inchide", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>  AuthScreen()));
            },
            child: const Text("Logare"),
          ),
        ],
      ),
    );
  }

  void _showResultSheet() {
    bool isSuccess = _plantResult.isIdentified;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: controller,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  if (isSuccess) ...[
                    const SizedBox(height: 20),
                    Text(
                      FlowerData.getCommonName(_plantResult.label.toLowerCase()) ?? _plantResult.label,
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.greenAccent),
                        const SizedBox(width: 10),
                        Text(
                          "Siguranta: ${_plantResult.confidence.toStringAsFixed(1)}%",
                          style: const TextStyle(color: Colors.white70, fontSize: 16), 
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Colors.white24),
                    const Text("Descriere:", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(_plantResult.description, style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5)),
                    const SizedBox(height: 20),
                    const Text("Sfaturi de ingrijire:", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Column(
                      children: [
                        _buildCareTip(Icons.water_drop, "Apa", _plantResult.careTips['udare']),
                        _buildCareTip(Icons.wb_sunny, "Lumina", _plantResult.careTips['lumina']),
                        _buildCareTip(Icons.landscape, "Sol", _plantResult.careTips['sol']),
                        _buildCareTip(Icons.thermostat, "Temperatura", _plantResult.careTips['temperatura']),
                        _buildCareTip(Icons.bug_report, "Daunatori", _plantResult.careTips['daunatori']),
                        _buildCareTip(Icons.info, "Dificultate", _plantResult.careTips['dificultate']),
                        _buildCareTip(Icons.pets, "Pet Friendly", _plantResult.careTips['pet_friendly']),
                        _buildCareTip(Icons.description, "Sfat general", _plantResult.careTips['sfat_general'])
                      ],
                    )
                  ] else ...[
                    const SizedBox(height: 20),
                    const Text("Planta nu a fost recunoscuta.", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 10),
                    const Text("Incearca sa focalizezi mai bine floarea sau foloseste alt unghi.", style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
                  ],
                  const SizedBox(height: 30),
                  if (isSuccess) ...[
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        if (AuthService().isGuest()) {
                          _showGuestRestrictionDialog();
                          return;
                        }
                        try {
                          Position? position = await _locationFuture;
                          await _dbService.addFlower(
                            name: FlowerData.getCommonName(_plantResult.label.toLowerCase()) ?? _plantResult.label,
                            scientificName: _plantResult.label,
                            description: _plantResult.description,
                            imageFile: _pickedImage!,
                            confidence: _plantResult.confidence,
                            isFavorite: false,
                            careTips: _plantResult.careTips,
                            latitude: position!.latitude,
                            longitude: position.longitude,
                          );
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Planta a fost salvata!", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.green,));
                          }
                        } catch (e) {
                          print("Eroare la salvare: $e");
                        }
                      },
                      icon: Icon(AuthService().isGuest() ? Icons.lock : Icons.save),
                      label: Text(AuthService().isGuest() ? "Salveaza (Cont necesar)" : "Salveaza in ierbar"),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                       style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () 
                      {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_downward, color: Colors.black),
                      label: const Text("Închide", style: TextStyle(color: Colors.black)),
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const ui.Color.fromARGB(255, 188, 188, 188),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text("Incearca din nou"),
                    ),
                  ]
                  ,
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      }
    ).whenComplete(() {
      setState(() {
        _pickedImage = null; 
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_pickedImage != null)
            _buildBlurredImageBackground()
          else if (_cameraController != null && _cameraController!.value.isInitialized)
            SizedBox.expand(child: CameraPreview(_cameraController!))
          else
            const Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
          if (_pickedImage == null) ...[
            Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF10B981), width: 3),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(child: Icon(Icons.add, color: Colors.white54, size: 30)),
              ),
            ),
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  const Text("Scaneaza o planta", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black, blurRadius: 10)])),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                    child: const Text("Incadreaza floarea in chenar", style: TextStyle(color: Colors.white70)),
                  ),
                ],
              ),
            ),
          ],
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(onPressed: _pickFromGallery, icon: const Icon(Icons.photo_library, color: Colors.white, size: 30)),
                GestureDetector(
                  onTap: _isBusy ? null : _captureAndScan,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: const Color(0xFF10B981).withOpacity(0.8),
                    ),
                    child: _isBusy ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.search, color: Colors.white, size: 35),
                  ),
                ),
                const SizedBox(width: 48), 
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurredImageBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(_pickedImage!, fit: BoxFit.cover),
        BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(color: Colors.black.withOpacity(0.3)),
        ),
        Center(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24, width: 1),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15, spreadRadius: 2)]
            ),
            child: Image.file(_pickedImage!, fit: BoxFit.contain),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _plantRecognizerService.dispose();
    super.dispose();
  }
}

Widget _buildCareTip(IconData icon, String title, String? content) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.green, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              Text(content ?? "Incarcare...", style: const TextStyle(fontSize: 16, color: Colors.white)),
            ],
          ),
        ),
      ],
    ),
  );
}