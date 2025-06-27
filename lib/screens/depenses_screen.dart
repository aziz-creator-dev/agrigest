import 'package:flutter/material.dart';
import 'package:agrigest/models/depense.dart';
import 'package:agrigest/services/depense_service.dart';
import 'package:agrigest/widgets/depense_form.dart';
import 'package:agrigest/widgets/depense_card.dart';

class DepensesScreen extends StatefulWidget {
  const DepensesScreen({super.key});

  @override
  State<DepensesScreen> createState() => _DepensesScreenState();
}

class _DepensesScreenState extends State<DepensesScreen> {
  final DepenseService _depenseService = DepenseService();
  late Future<List<Depense>> _depensesFuture;
  double _totalDepenses = 0;

  @override
  void initState() {
    super.initState();
    _loadDepenses();
  }

  Future<void> _loadDepenses() async {
    setState(() {
      _depensesFuture = _depenseService.getDepenses();
    });

    final depenses = await _depenseService.getDepenses();
    _calculateTotal(depenses);
  }

  void _calculateTotal(List<Depense> depenses) {
    double total = 0;
    for (final depense in depenses) {
      total += depense.montant;
    }
    setState(() {
      _totalDepenses = total;
    });
  }

  void _showAddDepenseDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return DepenseForm(
          onSave: (depense) async {
            await _depenseService.addDepense(depense);
            if (!mounted) return;
            Navigator.pop(context);
            _loadDepenses();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dépenses'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDepenseDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total des dépenses:',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    '${_totalDepenses.toStringAsFixed(2)} TND',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadDepenses,
              child: FutureBuilder<List<Depense>>(
                future: _depensesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  }

                  final depenses = snapshot.data!;

                  if (depenses.isEmpty) {
                    return const Center(
                      child: Text('Aucune dépense enregistrée'),
                    );
                  }

                  return ListView.builder(
                    itemCount: depenses.length,
                    itemBuilder: (context, index) {
                      final depense = depenses[index];
                      return DepenseCard(
                        depense: depense,
                        onEdit: () async {
                          final updatedDepense = await showDialog<Depense>(
                            context: context,
                            builder: (context) {
                              return DepenseForm(
                                depense: depense,
                                onSave: (updatedDepense) {
                                  Navigator.pop(context, updatedDepense);
                                },
                              );
                            },
                          );

                          if (updatedDepense != null) {
                            await _depenseService.updateDepense(updatedDepense);
                            _loadDepenses();
                          }
                        },
                        onDelete: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Confirmer la suppression'),
                                content: const Text(
                                    'Voulez-vous vraiment supprimer cette dépense?'),
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
                            await _depenseService.deleteDepense(depense.id);
                            _loadDepenses();
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