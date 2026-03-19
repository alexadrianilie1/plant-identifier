class PlantResult {
  final String label;      
  final double confidence;  
  final String description; 
  final bool isIdentified; 
  final Map<String, dynamic> careTips;

  PlantResult({
    required this.label,
    required this.confidence,
    required this.description,
    required this.isIdentified,
    required this.careTips,
  });

  factory PlantResult.empty() {
    return PlantResult(
      label: "Scanează o plantă...",
      confidence: 0.0,
      description: "Informațiile vor apărea aici.",
      isIdentified: false,
      careTips: {},
    );
  }
}