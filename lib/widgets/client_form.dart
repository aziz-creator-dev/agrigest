import 'package:flutter/material.dart';
import 'package:agrigest/models/client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClientForm extends StatefulWidget {
  final Client? client;
  final Function(Client) onSave;

  const ClientForm({
    super.key,
    this.client,
    required this.onSave,
  });

  @override
  State<ClientForm> createState() => _ClientFormState();
}

class _ClientFormState extends State<ClientForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _telephoneController;
  late TextEditingController _adresseController;
  late TextEditingController _villeController;
  late TextEditingController _codePostalController;
  late DateTime _dateCreation;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.client?.nom ?? '');
    _prenomController = TextEditingController(text: widget.client?.prenom ?? '');
    _emailController = TextEditingController(text: widget.client?.email ?? '');
    _telephoneController =
        TextEditingController(text: widget.client?.telephone ?? '');
    _adresseController =
        TextEditingController(text: widget.client?.adresse ?? '');
    _villeController = TextEditingController(text: widget.client?.ville ?? '');
    _codePostalController =
        TextEditingController(text: widget.client?.codePostal ?? '');
    _dateCreation = widget.client?.dateCreation ?? DateTime.now();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    _villeController.dispose();
    _codePostalController.dispose();
    super.dispose();
  }

 Future<void> _selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: _dateCreation,
    firstDate: DateTime(2000),
    lastDate: DateTime.now(),
    locale: const Locale('fr', 'FR'),  // Pour la localisation française
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Theme.of(context).primaryColor,
          ),
        ),
        child: child!,
      );
    },
  );
  
  if (picked != null && picked != _dateCreation) {
    setState(() {
      _dateCreation = picked;
    });
  }
}

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final client = Client(
        id: widget.client?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        nom: _nomController.text,
        prenom: _prenomController.text,
        email: _emailController.text,
        telephone: _telephoneController.text,
        adresse: _adresseController.text,
        ville: _villeController.text,
        codePostal: _codePostalController.text,
        dateCreation: _dateCreation,
      );
      widget.onSave(client);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.client == null ? 'Ajouter un client' : 'Modifier client'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _prenomController,
                decoration: const InputDecoration(labelText: 'Prénom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un prénom';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _telephoneController,
                decoration: const InputDecoration(labelText: 'Téléphone'),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: _adresseController,
                decoration: const InputDecoration(labelText: 'Adresse'),
              ),
              TextFormField(
                controller: _villeController,
                decoration: const InputDecoration(labelText: 'Ville'),
              ),
              TextFormField(
                controller: _codePostalController,
                decoration: const InputDecoration(labelText: 'Code postal'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date de création'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_dateCreation)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
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