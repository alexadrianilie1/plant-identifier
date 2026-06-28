import 'dart:convert';

import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/**
 * Clasa [AiService] gestionează componentele de inteligență artificială ale aplicației.
 * Aceasta include inferența locală utilizând [TensorFlow Lite] pentru clasificare vizuală
 * și integrarea cu modele de limbaj (LLM) prin [Groq API] pentru suport botanic dinamic.
 */
class AiService {
  static const String _url = "https://api.groq.com/openai/v1/chat/completions";
  static final String _apiKey = dotenv.env['GROQ_KEY'] ?? "";
  
  /**
   * Interoghează modelul [llama-3.3-70b-versatile] prin API-ul Groq pentru a genera 
   * sfaturi de îngrijire botanică personalizate.
   * 
   * [plantName] - Specia florii identificată de modelul local.
   * Returnează un [Map] conținând sfaturile structurate în format JSON.
   */
  Future<Map<String, dynamic>> getPlantCareTips(String plantName) async {
    try {
      var response = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile", // Model corect pentru Groq
          "messages": [
            {
              "role": "system",
              "content": "Ești un expert botanic și cunoști foarte bine limba română. Răspunde DOAR în format JSON brut, fără alte explicații."
            },
            {
              "role": "user",
              "content": """Oferă detalii pentru $plantName în următorul format JSON:
              {
                "udare": "text scurt",
                "lumina": "text scurt",
                "temperatura": "text scurt",
                "sol": "text scurt și ce fel de sol preferă această plantă",
                "daunatori": "text scurt",
                "pet_friendly": "Da/Nu și un scurt motiv",
                "dificultate": "text scurt",
                "sfat_general": "un sfat general despre cum să ai grijă de această plantă"
              }"""
            }
          ],
          "temperature": 0.5, // Mai mica pentru rsspunsuri mai precise
          "response_format": {"type": "json_object"} // Fortează Groq să dea JSON
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String content = data['choices'][0]['message']['content'];
        print("Răspuns brut de la Groq: $content");
        // Decodăm string-ul primit ca fiind la randul lui un obiect JSON
        return jsonDecode(content);
      } else {
        print("Eroare API: ${response.statusCode}");
        return {"error": "Nu am putut obține datele."};
      }
    } catch (e) {
      print("Eroare Catch: $e");
      return {"error": "Eroare de conexiune."};
    }
    }

    /**
     * Inițializează și încarcă modelul [EfficientNetB0] în interpretorul [TFLite].
     * Modelul este optimizat prin cuantizare pentru a rula local pe procesorul dispozitivului.
     */
    Future<void> loadModel() async {
      try{
        await Tflite.loadModel(
          model: "assets/model_efficientnetb0_v3.tflite",
          labels: "assets/model_efficientnetb0_labels_v3.txt",
          numThreads: 1, 
          isAsset: true,
          useGpuDelegate: false,
        );
      }catch(e){
        print("Eroare la incarcarea modelului AI: $e");
      }
  }

  /**
   * Executa inferenta locala pe imaginea capturata.
   * 
   * [imagePath] - Calea locala către fisierul imaginii procesate.
   * Returneaza o lista de [recognitions] (eticheta si scor de incredere) sau null in caz de eroare.
   */
  Future<List<dynamic>?> analyzeImage(String imagePath) async {
    try{
      var recognitions = await Tflite.runModelOnImage(
        path: imagePath,
        numResults: 5,
        threshold: 0.1,
        imageMean: 0.0,
        imageStd: 1.0,
        asynch: true,
      );
      
      return recognitions;
    }catch(e){
      print("Eroare la analiza AI: $e");
      return null;
    }
  }

  /**
   * Eliberam memoria
   */
  void dispose(){
    Tflite.close();
  }
}