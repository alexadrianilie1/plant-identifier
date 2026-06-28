import 'package:plant_identifier/models/flower_data.dart';

import '../models/plant_result.dart';
import 'ai_service.dart';
import 'wiki_service.dart';

/**
 * Serviciul central de orchestrare (Facade) pentru fluxul de recunoaștere a plantelor.
 * 
 * Această clasă integrează procesarea locală (Edge AI) cu serviciile externe (Cloud APIs).
 * Gestionează întregul ciclu de viață al unei predicții: inițializarea modelului, 
 * executarea inferenței, validarea defensivă a rezultatului (OOD Detection) și 
 * îmbogățirea datelor prin interogări asincrone către Wikipedia și Groq.
 */
class PlantRecognizerService {
  final AiService _aiService = AiService();
  final WikiService _wikiService = WikiService();

  // Pragul de siguranta
  final double _minConfidence = 95.0;

  // Initializam AI-ul
  Future<void> initialize() async {
    await _aiService.loadModel();
  }

  // Functia de procesare
  Future<PlantResult> processImage(String imagePath) async {
    // Interogam AI-ul
    var recognitions = await _aiService.analyzeImage(imagePath);

    // Tratam cazul in care interpretorul TFLite esueaza sau nu returneaza date
    if(recognitions == null || recognitions.isEmpty) {
      return PlantResult(
        label: "Eroare",
        confidence: 0.0,
        description: "Nu am putut analiza imaginea.",
        isIdentified: false,
        careTips: {},
      );
    }

    // Extragem predictia cu probabilitatea cea mai mare
    var topResult = recognitions[0];
    String rawLabel = topResult["label"].toString().replaceAll(RegExp(r'[0,9]'), '').trim();
    double score = topResult["confidence"] * 100;

    // Verificam pragul de siguranta
    if(score < _minConfidence) {
      return PlantResult(
        label: "Necunoscuta",
        confidence: score,
        description: "Planta nu a fost recunoscută cu suficientă siguranță.",
        isIdentified: false,
        careTips: {},
      );
    }

    // Interogam Wikipedia pentru descriere
    Map<String, String> wikiData = await _wikiService.fetchPlantDetails(rawLabel);

    // Returnam pachetul
    return PlantResult(
      label: rawLabel,
      confidence: score,
      description: wikiData['description']!,
      isIdentified: true,
      careTips: await _aiService.getPlantCareTips(FlowerData.getCommonName(rawLabel) ?? rawLabel),
    );
  }

  /// Eliberam memoria
  void dispose(){
    _aiService.dispose();
  }
}