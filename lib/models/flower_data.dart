class FlowerData {
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
      'wiki_query': 'Eschscholzia_californica',
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