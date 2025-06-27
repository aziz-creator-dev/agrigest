import 'package:flutter/material.dart';
import 'package:agrigest/models/tache.dart';
import 'package:intl/intl.dart';
import 'package:agrigest/services/client_service.dart';

class TacheCard extends StatelessWidget {
  final Tache tache;
  final Function(bool) onTogglePaid;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TacheCard({
    super.key,
    required this.tache,
    required this.onTogglePaid,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tâche du ${DateFormat('dd/MM/yyyy').format(tache.date)}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Modifier'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Supprimer'),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            FutureBuilder(
              future: ClientService().getClient(tache.clientId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Client: ${snapshot.data!.nom}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
            Text(tache.description),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${tache.montant.toStringAsFixed(2)} TND',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => onTogglePaid(!tache.estPaye),
                  child: Chip(
                    backgroundColor:
                        tache.estPaye ? Colors.green[100] : Colors.orange[100],
                    label: Text(
                      tache.estPaye ? 'Payé' : 'Non payé',
                      style: TextStyle(
                        color: tache.estPaye ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}