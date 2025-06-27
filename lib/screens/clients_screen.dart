import 'package:flutter/material.dart';
import 'package:agrigest/models/client.dart';
import 'package:agrigest/services/client_service.dart';
import 'package:agrigest/widgets/client_form.dart';
import 'package:agrigest/widgets/client_card.dart';
import 'package:agrigest/screens/client_taches_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final ClientService _clientService = ClientService();
  late Future<List<Client>> _clientsFuture;
  List<Client> _allClients = [];
  List<Client> _filteredClients = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _clientsFuture = _fetchClients();
    _searchController.addListener(_filterClients);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Client>> _fetchClients() async {
    final clients = await _clientService.getClients();
    setState(() {
      _allClients = clients;
      _filteredClients = clients;
    });
    return clients;
  }

  Future<void> _refreshClients() async {
    setState(() {
      _clientsFuture = _fetchClients();
    });
  }

  void _filterClients() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredClients = _allClients;
      } else {
        _filteredClients = _allClients.where((client) {
          return client.nom.toLowerCase().contains(query) ||
              client.prenom.toLowerCase().contains(query) ||
              client.telephone.contains(query) ||
              client.email.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _showAddClientDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return ClientForm(
          onSave: (client) async {
            await _clientService.addClient(client);
            if (!mounted) return;
            Navigator.pop(context);
            await _refreshClients();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Rechercher un client...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddClientDialog,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshClients,
        child: FutureBuilder<List<Client>>(
          future: _clientsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            }

            // La liste des clients affichée dépend de la recherche
            final clients = _filteredClients;

            if (clients.isEmpty) {
              return Center(
                child: Text(
                  _searchController.text.isEmpty
                      ? 'Aucun client enregistré'
                      : 'Aucun client trouvé',
                ),
              );
            }

            return ListView.builder(
              itemCount: clients.length,
              itemBuilder: (context, index) {
                final client = clients[index];
                return ClientCard(
                  client: client,
                  onEdit: () async {
                    final updatedClient = await showDialog<Client>(
                      context: context,
                      builder: (context) {
                        return ClientForm(
                          client: client,
                          onSave: (updatedClient) {
                            Navigator.pop(context, updatedClient);
                          },
                        );
                      },
                    );

                    if (updatedClient != null) {
                      await _clientService.updateClient(updatedClient);
                      await _refreshClients();
                    }
                  },
                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Confirmer la suppression'),
                          content: const Text(
                              'Voulez-vous vraiment supprimer ce client?'),
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
                      await _clientService.deleteClient(client.id);
                      await _refreshClients();
                    }
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ClientTachesScreen(client: client),
                      ),
                    );
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
