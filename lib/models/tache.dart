class Tache {
  final String id;
  final String clientId;
  final String description;
  final DateTime date;
  final double montant;
  final bool estPaye;
  final DateTime dateCreation;

  Tache({
    required this.id,
    required this.clientId,
    required this.description,
    required this.date,
    required this.montant,
    required this.estPaye,
    required this.dateCreation,
  });

  factory Tache.fromJson(Map<String, dynamic> json) {
    return Tache(
      id: json['id'],
      clientId: json['client_id'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      montant: (json['montant'] as num).toDouble(),
      estPaye: json['est_paye'],
      dateCreation: DateTime.parse(json['date_creation']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'description': description,
      'date': date.toIso8601String(),
      'montant': montant,
      'est_paye': estPaye,
      'date_creation': dateCreation.toIso8601String(),
    };
  }
}