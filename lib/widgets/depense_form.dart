import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agrigest/models/depense.dart';
import 'package:agrigest/services/depense_service.dart';
import 'package:intl/intl.dart';

class DepenseForm extends StatefulWidget {
  final Depense? depense;
  final Function(Depense) onSave;

  const DepenseForm({
    super.key,
    this.depense,
    required this.onSave,
  });

  @override
  State<DepenseForm> createState() => _DepenseFormState();
}

class _DepenseFormState extends State<DepenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _depenseService = DepenseService();
  late TextEditingController _categorieController;
  late TextEditingController _descriptionController;
  late TextEditingController _montantController;
  late DateTime _date;
  String? _justificatifUrl;
  bool _isUploading = false;

  final List<String> _categories = [
    'Matériel',
    'Main d\'œuvre',
    'Engrais',
    'Semences',
    'Carburant',
    'Entretien',
    'Autre'
  ];

  @override
  void initState() {
    super.initState();
    _categorieController = TextEditingController(text: widget.depense?.categorie ?? '');
    _descriptionController = TextEditingController(text: widget.depense?.description ?? '');
    _montantController = TextEditingController(text: widget.depense?.montant.toString() ?? '');
    _date = widget.depense?.date ?? DateTime.now();
    _justificatifUrl = widget.depense?.justificatifUrl;
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

  Future<void> _pickJustificatif() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _isUploading = true);
      try {
        final url = await _depenseService.uploadJustificatif(pickedFile.path);
        setState(() {
          _justificatifUrl = url;
          _isUploading = false;
        });
      } catch (e) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'upload: $e')),
        );
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final depense = Depense(
        id: widget.depense?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        categorie: _categorieController.text,
        description: _descriptionController.text,
        montant: double.tryParse(_montantController.text) ?? 0,
        date: _date,
        justificatifUrl: _justificatifUrl,
        dateCreation: widget.depense?.dateCreation ?? DateTime.now(),
      );
      widget.onSave(depense);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.depense == null ? 'Ajouter une dépense' : 'Modifier dépense'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _categorieController.text.isEmpty ? null : _categorieController.text,
                items: _categories.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,style: const TextStyle(color: Colors.white),),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categorieController.text = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner une catégorie';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _montantController,
                decoration: const InputDecoration(
                  labelText: 'Montant (TND)',
                  border: OutlineInputBorder(),
                ),
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
              const SizedBox(height: 16),
              if (_justificatifUrl != null)
                Column(
                  children: [
                    const Text('Justificatif:'),
                    Image.network(_justificatifUrl!, height: 100),
                  ],
                ),
              ElevatedButton(
                onPressed: _isUploading ? null : _pickJustificatif,
                child: _isUploading
                    ? const CircularProgressIndicator()
                    : const Text('Ajouter un justificatif'),
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