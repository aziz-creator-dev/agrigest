import 'package:flutter/material.dart';
import 'package:agrigest/models/tache.dart';
import 'package:agrigest/services/tache_service.dart';
import 'package:agrigest/widgets/tache_form.dart';
import 'package:agrigest/widgets/tache_card.dart';
import 'package:agrigest/services/client_service.dart';
import 'package:agrigest/models/client.dart';

class TachesScreen extends StatefulWidget {
  final String? clientId;

  const TachesScreen({super.key, this.clientId});

  @override
  State<TachesScreen> createState() => _TachesScreenState();
}

class _TachesScreenState extends State<TachesScreen> {
  final TacheService _tacheService = TacheService();
  late Future<List<Tache>> _tachesFuture;
  Client? _client;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.clientId != null) {
      _client = await ClientService().getClient(widget.clientId!);
    }
    _tachesFuture = widget.clientId != null
        ? _tacheService.getTachesByClient(widget.clientId!)
        : _tacheService.getAllTaches();
  }

  Future<void> _refreshTaches() async {
    setState(() {
      _loadData();
    });
  }

  void _showAddTacheDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return TacheForm(
          onSave: (tache) async {
            await _tacheService.addTache(tache);
            if (!mounted) return;
            Navigator.pop(context);
            _refreshTaches();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _client != null
          ? AppBar(
              title: Text('Tâches pour ${_client!.nom}'),
            )
          : null,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTacheDialog,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshTaches,
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
              return Center(
                child: Text(
                  widget.clientId != null
                      ? 'Aucune tâche pour ce client'
                      : 'Aucune tâche enregistrée',
                ),
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
                    _refreshTaches();
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
                      _refreshTaches();
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
                      _refreshTaches();
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}