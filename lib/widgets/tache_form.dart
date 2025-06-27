import 'package:flutter/material.dart';
import 'package:agrigest/models/tache.dart';
import 'package:agrigest/services/client_service.dart';
import 'package:agrigest/models/client.dart';
import 'package:intl/intl.dart';

class TacheForm extends StatefulWidget {
  final Tache? tache;
  final Function(Tache) onSave;
  final String? initialClientId;

  const TacheForm({
    super.key,
    this.tache,
    this.initialClientId,
    required this.onSave,
  });

  @override
  State<TacheForm> createState() => _TacheFormState();
}

class _TacheFormState extends State<TacheForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _montantController;
  late DateTime _date;
  late bool _estPaye;
  late String _clientId;
  List<Client> _clients = [];
  final ClientService _clientService = ClientService();

  // For description dropdown and custom field
  final List<String> _descriptionOptions = [
    'recolte',
    'arrosage',
    'labourage',
    'transport',
    'Autre...',
  ];
  String? _selectedDescription;
  TextEditingController _customDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _montantController = TextEditingController(
      text: widget.tache?.montant.toString() ?? '0.0',
    );
    _date = widget.tache?.date ?? DateTime.now();
    _estPaye = widget.tache?.estPaye ?? false;
    _clientId = widget.tache?.clientId ?? widget.initialClientId ?? '';

    // Description initialization
    if (widget.tache != null) {
      bool foundInDropdown = false;
      for (final opt in _descriptionOptions) {
        // exact match
        if (widget.tache!.description == opt) {
          _selectedDescription = opt;
          _customDescriptionController.text = '';
          foundInDropdown = true;
          break;
        } else if (widget.tache!.description.startsWith('$opt ')) {
          _selectedDescription = opt;
          _customDescriptionController.text = widget.tache!.description
              .substring(opt.length + 1);
          foundInDropdown = true;
          break;
        }
      }
      if (!foundInDropdown) {
        _selectedDescription = 'Autre...';
        _customDescriptionController.text = widget.tache!.description;
      }
    } else {
      _selectedDescription = _descriptionOptions.first;
      _customDescriptionController.text = '';
    }
    _loadClients();
  }

  Future<void> _loadClients() async {
    final clients = await _clientService.getClients();
    setState(() {
      _clients = clients;
      if (_clientId.isEmpty && _clients.isNotEmpty) {
        _clientId = _clients.first.id;
      }
    });
  }

  @override
  void dispose() {
    _montantController.dispose();
    _customDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Build final description
      String finalDescription = '';
      if (_selectedDescription == 'Autre...') {
        finalDescription = _customDescriptionController.text.trim();
      } else {
        finalDescription = _selectedDescription ?? '';
        if (_customDescriptionController.text.trim().isNotEmpty) {
          finalDescription += " " + _customDescriptionController.text.trim();
        }
      }
      final tache = Tache(
        id:
            widget.tache?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        clientId: _clientId,
        description: finalDescription,
        date: _date,
        montant: double.tryParse(_montantController.text) ?? 0.0,
        estPaye: _estPaye,
        dateCreation: widget.tache?.dateCreation ?? DateTime.now(),
      );
      widget.onSave(tache);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.tache == null ? 'Ajouter une tâche' : 'Modifier tâche',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _clientId.isEmpty ? null : _clientId,
                items:
                    _clients.map((client) {
                      return DropdownMenuItem(
                        value: client.id,
                        child: Text(
                          client.nom,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _clientId = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Client',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner un client';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Dropdown
              DropdownButtonFormField<String>(
                dropdownColor: Colors.black, // for a dark dropdown background
                style: const TextStyle(
                  color: Colors.white,
                ), // selected text color
                value: _selectedDescription,
                items:
                    _descriptionOptions.map((desc) {
                      return DropdownMenuItem(
                        value: desc,
                        child: Text(
                          desc,
                          style: const TextStyle(
                            color: Colors.white,
                          ), // dropdown list text color
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDescription = value!;
                    if (_selectedDescription != 'Autre...') {
                      _customDescriptionController.clear();
                    }
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.white), // label color
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner une description';
                  }
                  return null;
                },
              ),

              // Show custom field when "Autre..." is selected or always for complement
              if (_selectedDescription == 'Autre...' ||
                  (_selectedDescription != null))
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextFormField(
                    controller: _customDescriptionController,
                    decoration: InputDecoration(
                      labelText:
                          _selectedDescription == 'Autre...'
                              ? 'Décrire la tâche'
                              : 'Ajouter quantité',
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (_selectedDescription == 'Autre...' &&
                          (value == null || value.isEmpty)) {
                        return 'Veuillez entrer une description';
                      }
                      return null;
                    },
                  ),
                ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _montantController,
                decoration: const InputDecoration(labelText: 'Montant (TND)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_date)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              SwitchListTile(
                title: const Text('Payé'),
                value: _estPaye,
                onChanged: (value) {
                  setState(() {
                    _estPaye = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
