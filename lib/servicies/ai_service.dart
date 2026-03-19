import 'dart:convert';

import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;


class AiService {
  // Functie statica pentru a obtine sfaturi de ingrijire
  static const String _url = "https://api.groq.com/openai/v1/chat/completions";
  static final String _apiKey = dotenv.env['GROQ_KEY'] ?? "";
  
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
          "temperature": 0.5, // Mai mică pentru răspunsuri mai precise
          "response_format": {"type": "json_object"} // Forțează Groq să dea JSON
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String content = data['choices'][0]['message']['content'];
        print("Răspuns brut de la Groq: $content");
        // Decodăm string-ul primit ca fiind la rândul lui un obiect JSON
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
    // Incarcam modelul
    Future<void> loadModel() async {
      try{
        await Tflite.loadModel(
          model: "assets/model.tflite",
          labels: "assets/labels.txt",
          numThreads: 1,
          isAsset: true,
          useGpuDelegate: false,
        );
      }catch(e){
        print("Eroare la incarcarea modelului AI: $e");
      }
  }

  // Analizam imaginea si returnam rezultatul brut
  // Returneaza o lista sau null
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

  // Eliberam memoria
  void dispose(){
    Tflite.close();
  }
}