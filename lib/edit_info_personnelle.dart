import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditInfoPersonnelle extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic> initialData;

  const EditInfoPersonnelle({
    Key? key,
    required this.patientId,
    required this.initialData,
  }) : super(key: key);

  @override
  _EditInfoPersonnelleState createState() => _EditInfoPersonnelleState();
}

class _EditInfoPersonnelleState extends State<EditInfoPersonnelle> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    'nom': TextEditingController(),
    'prenom': TextEditingController(),
    'matricule': TextEditingController(),
    'lit': TextEditingController(),
    'telephone': TextEditingController(),
    'profession': TextEditingController(),
    'pays': TextEditingController(),
  };

  DateTime? _dateNaissance;
  String? _sexe;
  String? _nationalite;
  String? _etatCivil;
  int? _nombreEnfants;
  String? _niveauInstruction;
  String? _couvertureSociale;
  String? _origine;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  String? _validateDropdownValue(dynamic value, List<String> validOptions, {String? defaultValue}) {
    if (value == null) return defaultValue;
    final strValue = value.toString();
    return validOptions.contains(strValue) ? strValue : defaultValue;
  }

  void _initializeData() {
    _controllers.forEach((key, controller) {
      controller.text = widget.initialData[key]?.toString() ?? '';
    });

    _dateNaissance = widget.initialData['dateNaissance']?.toDate();
    
    // Initialisation sécurisée des valeurs des dropdowns
    _sexe = _validateDropdownValue(
      widget.initialData['sexe'], 
      ['Femme', 'Homme']
    );
    
    _nationalite = _validateDropdownValue(
      widget.initialData['nationalite'], 
      ['Tunisienne', 'Étrangère'],
      defaultValue: 'Tunisienne'
    );
    
    _etatCivil = _validateDropdownValue(
      widget.initialData['etatCivil'], 
      ['Célibataire', 'Marié(e)', 'Divorcé(e)', 'Veuf(ve)']
    );
    
    _nombreEnfants = widget.initialData['nombreEnfants'] ?? 0;
   
    
    _niveauInstruction = _validateDropdownValue(
      widget.initialData['niveauInstruction'], 
      ['Analphabète', 'Primaire', 'Secondaire', 'Universitaire']
    );
    
    _couvertureSociale = _validateDropdownValue(
      widget.initialData['couvertureSociale'], 
      ['CNSS', 'CNRPS', 'CNAM', 'Indigent', 'Plein tarif', 'Autre']
    );
    
    _origine = _validateDropdownValue(
      widget.initialData['origine'], 
      _buildGouvernoratsList()
    );
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _savePersonalInfo() async {
    if (_formKey.currentState!.validate()) {
      try {
        Map<String, dynamic> infoPersonnelle = {
          'nom': _controllers['nom']!.text,
          'prenom': _controllers['prenom']!.text,
          'matricule': _controllers['matricule']!.text,
          'lit': _controllers['lit']!.text,
          'dateNaissance': _dateNaissance,
          'sexe': _sexe,
          'nationalite': _nationalite,
          'pays': _nationalite == 'Étrangère' ? _controllers['pays']!.text : null,
          'telephone': _controllers['telephone']!.text,
          'etatCivil': _etatCivil,
          'nombreEnfants': _nombreEnfants,
          'niveauInstruction': _niveauInstruction,
          'profession': _controllers['profession']!.text,
          'couvertureSociale': _couvertureSociale,
          'origine': _origine,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance
            .collection('Patients')
            .doc(widget.patientId)
            .collection('DossierMedical') // Nouvelle structure
          .doc('info_personnelle')      // Document spécifique
          .set(infoPersonnelle, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Informations personnelles enregistrées avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'enregistrement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
    );
  }

  Widget _buildTextFormField(
    String fieldKey,
    String label, {
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: _controllers[fieldKey],
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: isRequired ? const Icon(Icons.star, size: 12, color: Colors.red) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
        ),
        keyboardType: keyboardType,
        validator: (value) => isRequired && (value == null || value.isEmpty)
            ? 'Ce champ est obligatoire'
            : null,
      ),
    );
  }

  Widget _buildDropdown(
    String field,
    String hint,
    List<String> items, {
    bool isRequired = false,
  }) {
    // Supprimer les doublons et les valeurs vides
    final uniqueItems = items.where((item) => item.isNotEmpty).toSet().toList();
    
    // Obtenir la valeur actuelle
    final currentValue = _getFieldValue(field);
    
    // Vérifier que la valeur existe dans la liste
    final isValidValue = currentValue != null && uniqueItems.contains(currentValue);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        value: isValidValue ? currentValue : null,
        hint: Text(hint),
        items: uniqueItems.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) => _setFieldValue(field, value),
        validator: isRequired && (currentValue == null || currentValue.isEmpty)
            ? (val) => 'Ce champ est obligatoire'
            : null,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          suffixIcon: isRequired ? const Icon(Icons.star, size: 12, color: Colors.red) : null,
        ),
      ),
    );
  }

  Widget _buildNumberInput({
    required int? value,
    required String hint,
    required void Function(int?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        initialValue: value?.toString(),
        decoration: InputDecoration(
          labelText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
        ),
        keyboardType: TextInputType.number,
        onChanged: (val) => onChanged(int.tryParse(val)),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateNaissance ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateNaissance = picked;
      });
    }
  }

  dynamic _getFieldValue(String field) {
    return switch (field) {
      'sexe' => _sexe,
      'nationalite' => _nationalite,
      'etatCivil' => _etatCivil,
      'niveauInstruction' => _niveauInstruction,
      'couvertureSociale' => _couvertureSociale,
      'origine' => _origine,
      _ => null,
    };
  }

  void _setFieldValue(String field, dynamic value) {
    setState(() {
      switch (field) {
        case 'sexe': _sexe = value; break;
        case 'nationalite': _nationalite = value; break;
        case 'etatCivil': _etatCivil = value; break;
        case 'niveauInstruction': _niveauInstruction = value; break;
        case 'couvertureSociale': _couvertureSociale = value; break;
        case 'origine': _origine = value; break;
      }
    });
  }

  List<String> _buildGouvernoratsList() {
    return [
      'Ariana', 'Béja', 'Ben Arous', 'Bizerte', 'Gabès', 'Gafsa', 'Jendouba',
      'Kairouan', 'Kasserine', 'Kébili', 'Le Kef', 'Mahdia', 'La Manouba',
      'Médenine', 'Monastir', 'Nabeul', 'Sfax', 'Sidi Bouzid', 'Siliana',
      'Sousse', 'Tataouine', 'Tozeur', 'Tunis', 'Zaghouan',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
      title: Text(
        'Informations Personnelles',
        style: TextStyle(
          fontWeight: FontWeight.bold, // Texte en gras
          color: Colors.white,        // Texte en blanc
        ),
        textAlign: TextAlign.center, // Centrer le texte
      ),
      centerTitle: true, // Ceci est nécessaire pour centrer le titre dans l'AppBar
      backgroundColor: Colors.teal.shade700,
      elevation: 0,
    ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('1. Informations Personnelles'),
                _buildTextFormField('nom', 'Nom*', isRequired: true),
                _buildTextFormField('prenom', 'Prénom*', isRequired: true),
                _buildTextFormField('matricule', 'Matricule*', isRequired: true),
                _buildTextFormField('lit', 'Numéro de lit*', isRequired: true, keyboardType: TextInputType.number),
                
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                  title: Text(
                    _dateNaissance == null
                        ? 'Date de naissance*'
                        : 'Date de naissance: ${DateFormat('dd/MM/yyyy').format(_dateNaissance!)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                
                _buildDropdown('sexe', 'Sexe*', ['Femme', 'Homme'], isRequired: true),
                _buildDropdown('nationalite', 'Nationalité', ['Tunisienne', 'Étrangère']),
                
                if (_nationalite == 'Étrangère')
                  _buildTextFormField('pays', 'Pays'),
                
                _buildTextFormField('telephone', 'Téléphone', keyboardType: TextInputType.phone),
                
                _buildSectionHeader('2. Informations Sociales'),
                _buildDropdown('etatCivil', 'État civil', [
                  'Célibataire', 'Marié(e)', 'Divorcé(e)', 'Veuf(ve)',
                ]),
                
                if (_etatCivil != null && _etatCivil != 'Célibataire')
                  _buildNumberInput(
                    value: _nombreEnfants,
                    hint: 'Nombre d\'enfants',
                    onChanged: (value) => setState(() => _nombreEnfants = value),
                  ),
                
               
                
                _buildDropdown('niveauInstruction', 'Niveau d\'instruction', [
                  'Analphabète', 'Primaire', 'Secondaire', 'Universitaire',
                ]),
                
                _buildTextFormField('profession', 'Profession'),
                _buildDropdown('couvertureSociale', 'Couverture sociale*', [
                  'CNSS', 'CNRPS', 'CNAM', 'Indigent', 'Plein tarif', 'Autre',
                ], isRequired: true),
                
                _buildDropdown('origine', 'Origine', _buildGouvernoratsList()),
                
                const SizedBox(height: 20),
Center(
  child: LayoutBuilder(
    builder: (context, constraints) {
      // Adapte la taille du bouton en fonction de la largeur de l'écran
      final buttonWidth = constraints.maxWidth > 600 
          ? constraints.maxWidth * 0.5  // 50% de largeur sur grands écrans
          : constraints.maxWidth * 0.9; // 90% de largeur sur petits écrans
      
      return ElevatedButton(
        onPressed: _savePersonalInfo,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal, // Couleur principale en teal
          foregroundColor: Colors.white, // Couleur du texte
          minimumSize: Size(
            buttonWidth, 
            50, // Hauteur fixe
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24, 
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4, // Ombre légère
          shadowColor: Colors.teal.shade300, // Ombre teal
          textStyle: TextStyle(
            fontSize: constraints.maxWidth > 600 ? 20 : 18, // Taille de texte responsive
            fontWeight: FontWeight.w600,
          ),
        ),
        child: const Text('Enregistrer la modification'),
      );
    },
  ),
),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}