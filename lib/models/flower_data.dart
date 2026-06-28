/// Clasa [FlowerData] gestionează dicționarul general
/// 
/// Aceasta se ocupă de maparea lingvistică pentru a "traduce"
/// prevenite de la model în diferite moduri în funcție de necesitate
/// (ex. nume popular, nume știițific, nume necesar pentru apelul către Wikipedia REST API).
class FlowerData {
  /// Dicționarul imuabil care mapează cele 19 specii suportate de modelul CNN.
  final Map<String, Map<String, String>> flowers = {
    'astilbe': {
      'name': 'Astilbe',
      'scientific_name': 'Astilbe',
      'wiki_query': 'Astilbe',
    },
    'bellflower': {
      'name': 'Clopoțel',
      'scientific_name': 'Campanula',
      'wiki_query': 'Campanula',
    },
    'black_eyed_susan': {
      'name': 'Rudbeckia',
      'scientific_name': 'Rudbeckia hirta',
      'wiki_query': 'Rudbeckia',
    },
    'calendula': {
      'name': 'Gălbenele',
      'scientific_name': 'Calendula officinalis',
      'wiki_query': 'Gălbenele',
    },
    'california_poppy': {
      'name': 'Mac californian',
      'scientific_name': 'Eschscholzia californica',
      'wiki_query': 'Mac_californian',
    },
    'carnation': {
      'name': 'Garoafă',
      'scientific_name': 'Dianthus caryophyllus',
      'wiki_query': 'Garoafă',
    },
    'common_daisy': {
      'name': 'Margaretă',
      'scientific_name': 'Leucanthemum vulgare',
      'wiki_query': 'Margaretă',
    },
    'coreopsis': {
      'name': 'Ochiul fetei',
      'scientific_name': 'Coreopsis',
      'wiki_query': 'Coreopsis',
    },
    'daffodil': {
      'name': 'Narcisă',
      'scientific_name': 'Narcissus',
      'wiki_query': 'Narcisă',
    },
    'dandelion': {
      'name': 'Păpădie',
      'scientific_name': 'Taraxacum officinale',
      'wiki_query': 'Păpădie',
    },
    'iris': {
      'name': 'Iris',
      'scientific_name': 'Iris',
      'wiki_query': 'Stânjenel',
    },
    'lavender': {
      'name': 'Lavandă',
      'scientific_name': 'Lavandula',
      'wiki_query': 'Lavandă',
    },
    'lotus': {
      'name': 'Lotus',
      'scientific_name': 'Nelumbo nucifera',
      'wiki_query': 'Nelumbo_nucifera',
    },
    'magnolia': {
      'name': 'Magnolie',
      'scientific_name': 'Magnolia',
      'wiki_query': 'Magnolia',
    },
    'orchid': {
      'name': 'Orhidee',
      'scientific_name': 'Orchidaceae',
      'wiki_query': 'Orhidee',
    },
    'rose': {
      'name': 'Trandafir',
      'scientific_name': 'Rosa',
      'wiki_query': 'Trandafir',
    },
    'sunflower': {
      'name': 'Floarea-soarelui',
      'scientific_name': 'Helianthus annuus',
      'wiki_query': 'Floarea-soarelui',
    },
    'tulip': {
      'name': 'Lalea',
      'scientific_name': 'Tulipa',
      'wiki_query': 'Lalea',
    },
    'water_lily': {
      'name': 'Nufăr',
      'scientific_name': 'Nymphaea',
      'wiki_query': 'Nufăr',
    },
  };

  /**
   * Extrage cheia optimizată necesară pentru interogarea endpoint-urilor Wikipedia.
   * 
   * Rezolvă limitările de căutare ale API-ului, furnizând termenul exact sub care 
   * specia este indexată pe versiunea în limba română a platformei.
   * 
   * [label] - Eticheta brută provenită de la rețeaua neuronală (ex: "california_poppy").
   * Returnează un [String] cu valoarea de căutare sau [null] dacă specia nu este înregistrată.
   */
  static String? getWikiQuery(String label) {
    final flowerData = FlowerData().flowers[label.toLowerCase()];
    return flowerData != null ? flowerData['wiki_query'] : null;
  }

  /**
   * Extrage denumirea științifică (latină) asociată etichetei prezise.
   * 
   * [label] - Eticheta brută provenită de la rețeaua neuronală.
   * Returnează un [String] cu denumirea științifică utilizată în afișările detaliate.
   */
  static String? getScientificName(String label) {
    final flowerData = FlowerData().flowers[label.toLowerCase()];
    return flowerData != null ? flowerData['scientific_name'] : null;
  }

  /**
   * Extrage denumirea populară (în limba română) asociată etichetei prezise.
   * 
   * Aceasta este valoarea principală afișată utilizatorului în UI și salvată în Ierbar.
   * 
   * [label] - Eticheta brută provenită de la rețeaua neuronală.
   * Returnează un [String] cu denumirea populară.
   */
  static String? getCommonName(String label) {
    final flowerData = FlowerData().flowers[label.toLowerCase()];
    return flowerData != null ? flowerData['name'] : null;
  }
}