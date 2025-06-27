import 'package:flutter/material.dart';
import 'package:agrigest/models/client.dart';
import 'package:agrigest/models/tache.dart';
import 'package:agrigest/services/tache_service.dart';
import 'package:agrigest/widgets/tache_form.dart';
import 'package:agrigest/widgets/tache_card.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart'; 

class ClientTachesScreen extends StatefulWidget {
  final Client client;

  const ClientTachesScreen({super.key, required this.client});

  @override
  State<ClientTachesScreen> createState() => _ClientTachesScreenState();
}

class _ClientTachesScreenState extends State<ClientTachesScreen> {
  final TacheService _tacheService = TacheService();
  late Future<List<Tache>> _tachesFuture;
  double _totalMontant = 0;
  double _totalPaye = 0;
  double _totalNonPaye = 0;

  @override
  void initState() {
    super.initState();
    _loadTaches();
  }

  Future<void> _loadTaches() async {
    setState(() {
      _tachesFuture = _tacheService.getTachesByClient(widget.client.id);
    });

    final taches = await _tacheService.getTachesByClient(widget.client.id);
    _calculateTotals(taches);
  }

  void _calculateTotals(List<Tache> taches) {
    double total = 0;
    double paye = 0;
    double nonPaye = 0;

    for (final tache in taches) {
      total += tache.montant;
      if (tache.estPaye) {
        paye += tache.montant;
      } else {
        nonPaye += tache.montant;
      }
    }

    setState(() {
      _totalMontant = total;
      _totalPaye = paye;
      _totalNonPaye = nonPaye;
    });
  }

  void _showAddTacheDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return TacheForm(
          initialClientId: widget.client.id,
          onSave: (tache) async {
            await _tacheService.addTache(tache);
            if (!mounted) return;
            Navigator.pop(context);
            _loadTaches();
          },
        );
      },
    );
  }

  Future<void> _shareReport() async {
    final taches = await _tacheService.getTachesByClient(widget.client.id);
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'TND');
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Création du contenu du rapport
    String reportContent = """
Rapport des tâches - ${widget.client.nom}
=================================

INFORMATIONS CLIENT:
Nom: ${widget.client.nom}
Prénom: ${widget.client.prenom}
Email: ${widget.client.email}
Téléphone: ${widget.client.telephone}

RÉCAPITULATIF FINANCIER:
Total: ${currencyFormat.format(_totalMontant)}
Payé: ${currencyFormat.format(_totalPaye)}
Non payé: ${currencyFormat.format(_totalNonPaye)}

DÉTAIL DES TÂCHES:
${taches.map((tache) => 
"""
- ${tache.description}
  Date: ${dateFormat.format(tache.date)}
  Montant: ${currencyFormat.format(tache.montant)}
  Statut: ${tache.estPaye ? 'Payé' : 'Non payé'}
""").join('\n')}
""";

    // Partage du rapport
    await Share.share(
      reportContent,
      subject: 'Rapport des tâches pour ${widget.client.nom}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'TND');

    return Scaffold(
      appBar: AppBar(
        title: Text('Tâches pour ${widget.client.nom}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareReport,
            tooltip: 'Partager le rapport',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTacheDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Récapitulatif',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:'),
                      Text(
                        currencyFormat.format(_totalMontant),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _totalMontant >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Payé:'),
                      Text(
                        currencyFormat.format(_totalPaye),
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Non payé:'),
                      Text(
                        currencyFormat.format(_totalNonPaye),
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadTaches,
              child: FutureBuilder<List<Tache>>(
                future: _tachesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  }

                  final taches = snapshot.data!;

                  if (taches.isEmpty) {
                    return const Center(
                      child: Text('Aucune tâche pour ce client'),
                    );
                  }

                  return ListView.builder(
                    itemCount: taches.length,
                    itemBuilder: (context, index) {
                      final tache = taches[index];
                      return TacheCard(
                        tache: tache,
                        onTogglePaid: (isPaid) async {
                          await _tacheService.markAsPaid(tache.id, isPaid);
                          _loadTaches();
                        },
                        onEdit: () async {
                          final updatedTache = await showDialog<Tache>(
                            context: context,
                            builder: (context) {
                              return TacheForm(
                                tache: tache,
                                onSave: (updatedTache) {
                                  Navigator.pop(context, updatedTache);
                                },
                              );
                            },
                          );

                          if (updatedTache != null) {
                            await _tacheService.updateTache(updatedTache);
                            _loadTaches();
                          }
                        },
                        onDelete: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Confirmer la suppression'),
                                content: const Text(
                                    'Voulez-vous vraiment supprimer cette tâche?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Supprimer'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm == true) {
                            await _tacheService.deleteTache(tache.id);
                            _loadTaches();
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}