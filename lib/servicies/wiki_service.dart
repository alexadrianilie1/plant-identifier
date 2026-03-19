import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/flower_data.dart';

class WikiService {
  // Returnam un Map cu {title: "...", description: "..."}
  Future<Map<String,String>> fetchPlantDetails(String plantLabel) async {
    String queryName =  FlowerData.getWikiQuery(plantLabel) ?? plantLabel;

    try{
      final url = Uri.parse(
        'https://ro.wikipedia.org/api/rest_v1/page/summary/$queryName'
      );

      final response = await http.get(url);

      if(response.statusCode == 200)
      {
        var data = jsonDecode(response.body);
        return {
          'title': data['title'] ?? plantLabel,
          'description': data['extract'] ?? "Nu există descriere disponibilă."
        };
      } else {
        return {
          'title': plantLabel,
          'description': "Nu s-au găsit informații în limba romnână pentru această floare."
        };
      }
    } catch(e){
      print("Eroare Wiki: $e");
      return {
        'title': plantLabel,
        'description': "Eroare de conexiune. Verifică internetul."
      };
    }
  }
}