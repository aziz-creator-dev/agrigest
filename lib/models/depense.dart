class Depense {
  final String id;
  final String categorie;
  final String description;
  final double montant;
  final DateTime date;
  final String? justificatifUrl;
  final DateTime dateCreation;

  Depense({
    required this.id,
    required this.categorie,
    required this.description,
    required this.montant,
    required this.date,
    this.justificatifUrl,
    required this.dateCreation,
  });

  factory Depense.fromJson(Map<String, dynamic> json) {
    return Depense(
      id: json['id'],
      categorie: json['categorie'],
      description: json['description'],
      montant: (json['montant'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      justificatifUrl: json['justificatif_url'],
      dateCreation: DateTime.parse(json['date_creation']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categorie': categorie,
      'description': description,
      'montant': montant,
      'date': date.toIso8601String(),
      'justificatif_url': justificatifUrl,
      'date_creation': dateCreation.toIso8601String(),
    };
  }
}