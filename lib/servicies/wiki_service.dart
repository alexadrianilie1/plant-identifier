import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/flower_data.dart';

/**
 * Serviciu dedicat interogării și preluării de date enciclopedice externe.
 * 
 * Acest strat de rețea (Network Layer) interoghează [Wikipedia REST API] pentru a 
 * îmbogăți predicțiile modelului local de inteligență artificială cu descrieri standard.
 * De asemenea, rezolvă bariera lingvistică: mapează etichetele returnate de TFLite
 * (în limba engleză) către endpoint-urile Wikipedia în limba română (ro.wikipedia.org).
 */
class WikiService {
  /**
   * Preia detaliile sumare (extractul) unei plante de pe Wikipedia.
   * 
   * Utilizează dicționarul static [FlowerData.getWikiQuery] pentru a obține 
   * termenul exact de căutare. Abordarea este una defensivă (fail-safe): dacă 
   * interogarea eșuează (Eroare 404 sau lipsă conexiune), aplicația nu se blochează,
   * ci returnează un pachet de date (Map) cu un mesaj de eroare standardizat pentru UI.
   * 
   * [plantLabel] - Eticheta brută în limba engleză, returnată de modelul AI.
   * Returnează un [Map] cu cheile `title` și `description`.
   */
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