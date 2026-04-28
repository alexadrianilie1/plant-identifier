class FlowerData {
  final Map<String, Map<String, String>> flowers = {
    'rose': {
      'name': 'Trandafir',
      'scientific_name': 'Rosa',
      'wiki_query': 'Trandafir',
    },
    'tulip': {
      'name': 'Lalea',
      'scientific_name': 'Tulipa',
      'wiki_query': 'Lalea',
    },
    'daisy': {
      'name': 'Margaretă',
      'scientific_name': 'Leucanthemum vulgare',
      'wiki_query': 'Margaretă',
    },
    'sunflower': {
      'name': 'Floarea soarelui',
      'scientific_name': 'Helianthus annuus',
      'wiki_query': 'Floarea soarelui',
    },
    'dandelion': {
      'name': 'Păpădie',
      'scientific_name': 'Taraxacum',
      'wiki_query': 'Păpădie',
    },
  };

  static String? getWikiQuery(String label) {
    final flowerData = FlowerData().flowers[label.toLowerCase()];
    return flowerData != null ? flowerData['wiki_query'] : null;
  }

  static String? getScientificName(String label) {
    final flowerData = FlowerData().flowers[label.toLowerCase()];
    return flowerData != null ? flowerData['scientific_name'] : null;
  }

  static String? getCommonName(String label) {
    final flowerData = FlowerData().flowers[label.toLowerCase()];
    return flowerData != null ? flowerData['name'] : null;
  }
}