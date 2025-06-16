import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ExamenClinique.dart';

class AjoutPatientPage extends StatefulWidget {
  final String userId;

  const AjoutPatientPage({Key? key, required this.userId}) : super(key: key);

  @override
  _AjoutPatientPageState createState() => _AjoutPatientPageState();
}

class _AjoutPatientPageState extends State<AjoutPatientPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  bool _showAutreEndocrino = false;
  TextEditingController _autreEndocrinoController = TextEditingController();
  final Map<String, TextEditingController> _controllers = {
    'nom': TextEditingController(),
    'prenom': TextEditingController(),
    'matricule': TextEditingController(),
    'telephone': TextEditingController(),
    'lit': TextEditingController(),
    'pays': TextEditingController(),
    'profession': TextEditingController(),
    'allergiesPrecision': TextEditingController(),
    'deficiencesPrecision': TextEditingController(),
    'regimeAlimentaire': TextEditingController(),
    'motifHospitalisation': TextEditingController(),
    'histoireMaladie': TextEditingController(),
    'autresAntecedents': TextEditingController(),
    'type_intervention': TextEditingController(),
    'autres_antecedents_familiaux': TextEditingController(),
    'antecedents_chirurgicaux_familiaux': TextEditingController(),
    'maladie_chronique_autre': TextEditingController(),
    'traitements_en_cours_details': TextEditingController(),
    'incidents_transfusion': TextEditingController(),
    'personneAPrevenir': TextEditingController(),
    'personneDeConfiance': TextEditingController(),


  };

  DateTime? _dateNaissance;
  String? _sexe;
  String? _nationalite;
  String? _etatCivil;
  int? _nombreEnfants;
  String? lit;
  String? _niveauInstruction;
  String? _couvertureSociale;
  String? _origine;
  bool? _allergies;
  String? _typeAllergie;
  bool? _deficiences;
  String? _typeDeficience;
  String? _modeVie;
  DateTime? _dateHospitalisation;
  String? _modeEntree;
  List<String> _etatEntree = [];
  List<String> _antecedentsMedicaux = [];
  List<Map<String, dynamic>> _antecedentsChirurgicauxList = [];
  DateTime? _dateChirurgie;
  String? _complicationsChirurgie;
  bool? _antecedentsTransfusionnels;
  int? _nombrePochesTransfusees;
  List<String> _antecedentsFamiliauxCardio = [];
  List<String> _antecedentsFamiliauxRespiratoire = [];
  List<String> _antecedentsFamiliauxEndocrino = [];
  List<String> _antecedentsFamiliauxRenal = [];
  List<String> _antecedentsFamiliauxOncologique = [];
  List<String> _antecedentsFamiliauxNeuro = [];
  List<String> _maladiesChroniques = [];
  String? _serviceInfermier; // Nouvelle variable pour stocker le service
bool _showDiabeteOptions = false;
bool _showThyroideOptions = false;
String? _selectedDiabeteType;
String? _selectedThyroideType;


// Pour la section personnelle
bool _showDiabeteOptionsPerso = false;
bool _showThyroideOptionsPerso = false;
String? _selectedDiabeteTypePerso;
String? _selectedThyroideTypePerso;

// Pour la section familiale
bool _showDiabeteOptionsFam = false;
bool _showThyroideOptionsFam = false;

  @override
  void initState() {
    super.initState();
    _dateHospitalisation = DateTime.now();
    _chargerServiceInfermier(); // <-- À ajouter ici !
  }

  Future<void> _chargerServiceInfermier() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final infermierDoc =
          await FirebaseFirestore.instance
              .collection('Infermier')
              .doc(user.uid)
              .get();

      if (infermierDoc.exists) {
        setState(() {
          _serviceInfermier = infermierDoc['service'] ?? 'Non spécifié';
        });
      }
    } catch (e) {
      print('Erreur lors du chargement du service: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controllers.values.forEach((controller) => controller.dispose());
    _controllers['personneAPrevenir']?.dispose();
    _controllers['personneDeConfiance']?.dispose();
    _autreEndocrinoController.dispose(); // Ajoutez cette ligne

    super.dispose();
  }

  Future<String?> _enregistrerPatient() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Créer les données pour info_personnelle
        Map<String, dynamic> infoPersonnelle = {
          'nom': _controllers['nom']!.text,
          'prenom': _controllers['prenom']!.text,
          'matricule': _controllers['matricule']!.text,
          'lit': _controllers['lit']!.text,
          'dateNaissance': _dateNaissance,
          'sexe': _sexe,
          'nationalite': _nationalite,
          'pays':
              _nationalite == 'Étrangère' ? _controllers['pays']!.text : null,
          'telephone': _controllers['telephone']!.text,
          'etatCivil': _etatCivil,
          'nombreEnfants': _nombreEnfants,
          'niveauInstruction': _niveauInstruction,
          'profession': _controllers['profession']!.text,
          'couvertureSociale': _couvertureSociale,
          'origine': _origine,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
           'personneAPrevenir': _controllers['personneAPrevenir']!.text,
           'personneDeConfiance': _controllers['personneDeConfiance']!.text,
        };

        // Créer les données pour informations_generales
        Map<String, dynamic> informationsGenerales = {
          'allergies': _allergies,
          'typeAllergie': _typeAllergie,
          'allergiesPrecision': _controllers['allergiesPrecision']!.text,
          'deficiences': _deficiences,
          'typeDeficience': _typeDeficience,
          'deficiencesPrecision': _controllers['deficiencesPrecision']!.text,
          'regimeAlimentaire': _controllers['regimeAlimentaire']!.text,
          'modeVie': _modeVie,
          'motifHospitalisation': _controllers['motifHospitalisation']!.text,
          'dateHospitalisation': _dateHospitalisation,
          'modeEntree': _modeEntree,
          'etatEntree': _etatEntree,
          'histoireMaladie': _controllers['histoireMaladie']!.text,
          'antecedentsMedicaux': _antecedentsMedicaux,
          'autresAntecedents': _controllers['autresAntecedents']!.text,
          'antecedentsChirurgicaux': _antecedentsChirurgicauxList,
          'antecedentsFamiliauxCardio': _antecedentsFamiliauxCardio,
          'antecedentsFamiliauxRespiratoire': _antecedentsFamiliauxRespiratoire,
          'antecedentsFamiliauxEndocrino': _antecedentsFamiliauxEndocrino,
          'antecedentsFamiliauxRenal': _antecedentsFamiliauxRenal,
          'antecedentsFamiliauxOncologique': _antecedentsFamiliauxOncologique,
          'antecedentsFamiliauxNeuro': _antecedentsFamiliauxNeuro,
          'autresAntecedentsFamiliaux':
              _controllers['autres_antecedents_familiaux']!.text,
          'maladiesChroniques': _maladiesChroniques,
          'traitementsEnCours':
              _controllers['traitements_en_cours_details']!.text,
          'dateCreation': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // Créer une référence pour le nouveau patient
        final patientRef =
            FirebaseFirestore.instance.collection('Patients').doc();

        // Créer un batch pour les opérations atomiques
        final batch = FirebaseFirestore.instance.batch();

        // 1. Créer le document principal du patient avec les infos de base
        batch.set(patientRef, {
          'id': patientRef.id,
          'nom': _controllers['nom']!.text,
          'prenom': _controllers['prenom']!.text,
          'matricule': _controllers['matricule']!.text,
          'lit': _controllers['lit']!.text,
          'service': _serviceInfermier, // Service également au niveau racine
          'dateCreation': FieldValue.serverTimestamp(),
        });

        // 2. Créer le document info_personnelle dans DossierMedical
        batch.set(
          patientRef.collection('DossierMedical').doc('info_personnelle'),
          infoPersonnelle,
        );

        // 3. Créer le document informations_generales dans DossierMedical
        batch.set(
          patientRef.collection('DossierMedical').doc('informations_generales'),
          informationsGenerales,
        );

        // Exécuter le batch
        await batch.commit();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient enregistré avec succès')),
        );
        return patientRef.id;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'enregistrement: $e')),
        );
        return null;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  void _passerExamenClinique() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final patientId = await _enregistrerPatient();

      if (!mounted) return;
      Navigator.pop(context);

      if (patientId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExamenClinique(patientId: patientId),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'enregistrement: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: _controllers[fieldKey],
        decoration: InputDecoration(
          labelText: label,
          suffixIcon:
              isRequired
                  ? const Icon(Icons.star, size: 12, color: Colors.red)
                  : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator:
            (value) =>
                isRequired && (value == null || value.isEmpty)
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        value: _getFieldValue(field),
        hint: Text(hint),
        items:
            items.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
        onChanged: (value) => _setFieldValue(field, value),
        validator:
            isRequired && _getFieldValue(field) == null
                ? (val) => 'Ce champ est obligatoire'
                : null,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          suffixIcon:
              isRequired
                  ? const Icon(Icons.star, size: 12, color: Colors.red)
                  : null,
        ),
      ),
    );
  }

  Widget _buildYesNoQuestion({
    required String question,
    required bool? value,
    required void Function(bool?) onChanged,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$question${isRequired ? '*' : ''}',
          style: const TextStyle(fontSize: 16),
        ),
        Row(
          children: [
            Radio<bool>(value: true, groupValue: value, onChanged: onChanged),
            const Text('Oui'),
            const SizedBox(width: 20),
            Radio<bool>(value: false, groupValue: value, onChanged: onChanged),
            const Text('Non'),
          ],
        ),
        if (isRequired && value == null)
          const Text(
            'Ce champ est obligatoire',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
      ],
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        keyboardType: TextInputType.number,
        onChanged: (val) => onChanged(int.tryParse(val)),
      ),
    );
  }

  Widget _buildAntecedentsSection({
    required String title,
    required List<String> items,
  }) {
    return ExpansionTile(
      title: Text(title),
      children: [
        Wrap(
          spacing: 8,
          children:
              items.map((item) {
                return FilterChip(
                  label: Text(item),
                  selected: _antecedentsMedicaux.contains('$title - $item'),
                  onSelected: (selected) {
                    setState(() {
                      final fullItem = '$title - $item';
                      if (selected) {
                        _antecedentsMedicaux.add(fullItem);
                      } else {
                        _antecedentsMedicaux.remove(fullItem);
                      }
                    });
                  },
                );
              }).toList(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildTextFormField(
            '${title.toLowerCase()}_autre',
            'Autre précision',
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxList({
    required List<String> items,
    required List<String> selectedItems,
    required void Function(List<String>) onChanged,
  }) {
    return Column(
      children:
          items.map((item) {
            return CheckboxListTile(
              title: Text(item),
              value: selectedItems.contains(item),
              onChanged: (bool? value) {
                final newList = List<String>.from(selectedItems);
                if (value == true) {
                  newList.add(item);
                } else {
                  newList.remove(item);
                }
                onChanged(newList);
              },
            );
          }).toList(),
    );
  }
Widget _buildEndocrinoPersoSection() {
  return ExpansionTile(
    title: const Text('Endocrino-métabolique'),
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Diabète
          ListTile(
            title: const Text('Diabète'),
            trailing: Icon(_showDiabeteOptionsPerso 
                ? Icons.keyboard_arrow_up 
                : Icons.keyboard_arrow_down),
            onTap: () {
              setState(() {
                _showDiabeteOptionsPerso = !_showDiabeteOptionsPerso;
                if (_showDiabeteOptionsPerso) _showThyroideOptionsPerso = false;
              });
            },
          ),
          
          if (_showDiabeteOptionsPerso) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Insulino-dépendant'),
                    value: 'Diabète - Insulino-dépendant',
                    groupValue: _selectedDiabeteTypePerso,
                    onChanged: (value) {
                      setState(() {
                        _selectedDiabeteTypePerso = value;
                        _antecedentsMedicaux.removeWhere((item) => 
                            item.startsWith('Diabète - '));
                        if (value != null) {
                          _antecedentsMedicaux.add(value);
                        }
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Non insulino-dépendant'),
                    value: 'Diabète - Non insulino-dépendant',
                    groupValue: _selectedDiabeteTypePerso,
                    onChanged: (value) {
                      setState(() {
                        _selectedDiabeteTypePerso = value;
                        _antecedentsMedicaux.removeWhere((item) => 
                            item.startsWith('Diabète - '));
                        if (value != null) {
                          _antecedentsMedicaux.add(value);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
          
          // Section Thyroïde
          ListTile(
            title: const Text('Thyroïde'),
            trailing: Icon(_showThyroideOptionsPerso 
                ? Icons.keyboard_arrow_up 
                : Icons.keyboard_arrow_down),
            onTap: () {
              setState(() {
                _showThyroideOptionsPerso = !_showThyroideOptionsPerso;
                if (_showThyroideOptionsPerso) _showDiabeteOptionsPerso = false;
              });
            },
          ),
          
          if (_showThyroideOptionsPerso) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Hyperthyroïdie'),
                    value: 'Thyroïde - Hyperthyroïdie',
                    groupValue: _selectedThyroideTypePerso,
                    onChanged: (value) {
                      setState(() {
                        _selectedThyroideTypePerso = value;
                        _antecedentsMedicaux.removeWhere((item) => 
                            item.startsWith('Thyroïde - '));
                        if (value != null) {
                          _antecedentsMedicaux.add(value);
                        }
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Hypothyroïdie'),
                    value: 'Thyroïde - Hypothyroïdie',
                    groupValue: _selectedThyroideTypePerso,
                    onChanged: (value) {
                      setState(() {
                        _selectedThyroideTypePerso = value;
                        _antecedentsMedicaux.removeWhere((item) => 
                            item.startsWith('Thyroïde - '));
                        if (value != null) {
                          _antecedentsMedicaux.add(value);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ],
  );
}
Widget _buildActionButtons() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final isVertical = constraints.maxWidth < 600;

        return isVertical
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildButton(
                    context,
                    text: 'Retour',
                    color: Colors.grey[600]!,
                    icon: Icons.arrow_back,
                    onPressed: () => Navigator.pop(context),
                    fullWidth: true,
                  ),
                  const SizedBox(height: 12),
                  _buildButton(
                    context,
                    text: 'Étape suivante',
                    color: Colors.teal.shade700,
                    icon: Icons.arrow_forward,
                    onPressed: _passerExamenClinique,
                    fullWidth: true,
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: _buildButton(
                      context,
                      text: 'Retour',
                      color: Colors.grey[600]!,
                      icon: Icons.arrow_back,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildButton(
                      context,
                      text: 'Étape suivante',
                      color: Colors.teal.shade700,
                      icon: Icons.arrow_forward,
                      onPressed: _passerExamenClinique,
                    ),
                  ),
                ],
              );
      },
    ),
  );
}

Widget _buildButton(
  BuildContext context, {
  required String text,
  required Color color,
  required IconData icon,
  required VoidCallback onPressed,
  bool fullWidth = false,
}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isSmallScreen = screenWidth < 400;

  return ElevatedButton.icon(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 14 : 16,
        horizontal: isSmallScreen ? 12 : 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      shadowColor: Colors.black38,
      minimumSize: fullWidth ? const Size(double.infinity, 50) : null,
      animationDuration: const Duration(milliseconds: 200),
      enableFeedback: true,
    ),
    icon: Icon(
      icon,
      size: isSmallScreen ? 18 : 20,
    ),
    label: Text(
      text,
      style: TextStyle(
        fontSize: isSmallScreen ? 14 : 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  );
}

dynamic _getFieldValue(String field) {
    switch (field) {
      case 'sexe':
        return _sexe;
      case 'nationalite':
        return _nationalite;
      case 'etatCivil':
        return _etatCivil;
     
      case 'niveauInstruction':
        return _niveauInstruction;
      case 'couvertureSociale':
        return _couvertureSociale;
      case 'origine':
        return _origine;
      case 'typeAllergie':
        return _typeAllergie;
      case 'typeDeficience':
        return _typeDeficience;
      case 'modeVie':
        return _modeVie;
      case 'modeEntree':
        return _modeEntree;
      case 'complications_chirurgie':
        return _complicationsChirurgie;
      default:
        return null;
    }
  }

  void _setFieldValue(String field, dynamic value) {
    setState(() {
      switch (field) {
        case 'sexe':
          _sexe = value;
          break;
        case 'nationalite':
          _nationalite = value;
          break;
        case 'etatCivil':
          _etatCivil = value;
          break;
       
          break;
        case 'niveauInstruction':
          _niveauInstruction = value;
          break;
        case 'couvertureSociale':
          _couvertureSociale = value;
          break;
        case 'origine':
          _origine = value;
          break;
        case 'typeAllergie':
          _typeAllergie = value;
          break;
        case 'typeDeficience':
          _typeDeficience = value;
          break;
        case 'modeVie':
          _modeVie = value;
          break;
        case 'modeEntree':
          _modeEntree = value;
          break;
        case 'complications_chirurgie':
          _complicationsChirurgie = value;
          break;
      }
    });
  }

  List<String> _buildGouvernoratsList() {
    return [
      'Ariana',
      'Béja',
      'Ben Arous',
      'Bizerte',
      'Gabès',
      'Gafsa',
      'Jendouba',
      'Kairouan',
      'Kasserine',
      'Kébili',
      'Le Kef',
      'Mahdia',
      'La Manouba',
      'Médenine',
      'Monastir',
      'Nabeul',
      'Sfax',
      'Sidi Bouzid',
      'Siliana',
      'Sousse',
      'Tataouine',
      'Tozeur',
      'Tunis',
      'Zaghouan',
    ];
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateNaissance) {
      setState(() => _dateNaissance = picked);
    }
  }

  Future<void> _selectSurgeryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateChirurgie) {
      setState(() => _dateChirurgie = picked);
    }
  }

  void _ajouterAntecedentChirurgical() {
    final typeIntervention = _controllers['type_intervention']?.text;
    if (typeIntervention == null || typeIntervention.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez préciser le type d\'intervention'),
        ),
      );
      return;
    }
    if (_dateChirurgie == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une date')),
      );
      return;
    }

    setState(() {
      _antecedentsChirurgicauxList.add({
        'type': typeIntervention,
        'date': _dateChirurgie!,
        'complications': _complicationsChirurgie ?? 'Aucune',
        'transfusion': _antecedentsTransfusionnels ?? false,
        'nombrePoches': _nombrePochesTransfusees,
        'incidents': _controllers['incidents_transfusion']?.text,
      });

      _dateChirurgie = null;
      _complicationsChirurgie = null;
      _controllers['type_intervention']?.clear();
      _controllers['incidents_transfusion']?.clear();
    });
  }

  void _supprimerAntecedentChirurgical(Map<String, dynamic> antecedent) {
    setState(() {
      _antecedentsChirurgicauxList.remove(antecedent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
      title: Text(
        'Nouveau Patient',
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('1. Informations Personnelles'),
              _buildTextFormField('nom', 'Nom*', isRequired: true),
              _buildTextFormField('prenom', 'Prénom*', isRequired: true),
              _buildTextFormField('matricule', 'Matricule*', isRequired: true),
              _buildTextFormField(
                'lit',
                'Numéro de lit*',
                isRequired: true,
                keyboardType: TextInputType.number,
                
              ),
              ListTile(
                title: Text(
                  _dateNaissance == null
                      ? 'Date de naissance*'
                      : 'Né(e) le: ${DateFormat('dd/MM/yyyy').format(_dateNaissance!)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const Divider(),

              _buildDropdown('sexe', 'Sexe*', [
                'Femme',
                'Homme',
              ], isRequired: true),
              _buildDropdown('nationalite', 'Nationalité', [
                'Tunisienne',
                'Étrangère',
              ]),

              if (_nationalite == 'Étrangère')
                _buildTextFormField('pays', 'Pays'),

              _buildTextFormField(
                'telephone',
                'Téléphone',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),

              _buildSectionHeader('2. Informations Sociales'),
              _buildDropdown('etatCivil', 'État civil', [
                'Célibataire',
                'Marié(e)',
                'Divorcé(e)',
                'Veuf(ve)',
              ]),

              if (_etatCivil != null && _etatCivil != 'Célibataire')
                _buildNumberInput(
                  value: _nombreEnfants,
                  hint: 'Nombre d\'enfants',
                  onChanged: (value) => setState(() => _nombreEnfants = value),
                ),

              _buildDropdown('niveauInstruction', 'Niveau d\'instruction', [
                'Analphabète',
                'Primaire',
                'Secondaire',
                'Universitaire',
              ]),

              _buildTextFormField('profession', 'Profession'),

              _buildDropdown('couvertureSociale', 'Couverture sociale*', [
                'CNSS',
                'CNRPS',
                'CNAM',
                'Indigent',
                'Plein tarif',
                'Autre',
              ], isRequired: true),
              _buildTextFormField(
  'personneAPrevenir', 
  'Personne à prévenir', 
),
_buildTextFormField(
  'personneDeConfiance', 
  'Personne de confiance', 
),

              _buildDropdown('origine', 'Origine', _buildGouvernoratsList()),
              const SizedBox(height: 24),

              _buildSectionHeader('3. Informations Médicales'),
              _buildYesNoQuestion(
                question: 'Allergies*',
                value: _allergies,
                onChanged: (val) => setState(() => _allergies = val),
                isRequired: true,
              ),

              if (_allergies == true) ...[
                _buildDropdown('typeAllergie', 'Type d\'allergie', [
                  'Alimentaire',
                  'Médicamenteuse',
                  'Environnementale',
                  'Autre',
                ]),
                if (_typeAllergie == 'Autre')
                  _buildTextFormField('allergiesPrecision', 'Précisez'),
              ],

              _buildYesNoQuestion(
                question: 'Déficiences',
                value: _deficiences,
                onChanged: (val) => setState(() => _deficiences = val),
              ),

              if (_deficiences == true) ...[
                _buildDropdown('typeDeficience', 'Type de déficience', [
                  'Auditive',
                  'Visuelle',
                  'Mentale',
                  'Motrice',
                  'Autre',
                ]),
                if (_typeDeficience == 'Autre')
                  _buildTextFormField('deficiencesPrecision', 'Précisez'),
              ],

              _buildTextFormField('regimeAlimentaire', 'Régime alimentaire'),

              _buildDropdown('modeVie', 'Mode de vie', [
                'Sédentaire',
                'Activité physique',
              ]),
              const SizedBox(height: 24),

              _buildSectionHeader('4. Histoire de la Maladie & Admission'),
              _buildTextFormField(
                'motifHospitalisation',
                'Motif d\'hospitalisation*',
                isRequired: true,
                maxLines: 3,
              ),

              ListTile(
                title: Text(
                  'Date d\'hospitalisation: ${DateFormat('dd/MM/yyyy HH:mm').format(_dateHospitalisation!)}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),

              _buildDropdown('modeEntree', 'Mode d\'entrée*', [
                'Consultation',
                'Urgence',
                'Transfert',
              ], isRequired: true),

              const Text(
                'État d\'entrée*',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              Wrap(
                spacing: 8,
                children:
                    [
                      'Autonome',
                      'Fauteuil roulant',
                      'Alité',
                      'Conscient',
                      'Confus',
                      'Inconscient',
                    ].map((etat) {
                      return FilterChip(
                        label: Text(etat),
                        selected: _etatEntree.contains(etat),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _etatEntree.add(etat);
                            } else {
                              _etatEntree.remove(etat);
                            }
                          });
                        },
                      );
                    }).toList(),
              ),

              const SizedBox(height: 16),
              _buildTextFormField(
                'histoireMaladie',
                'Histoire de la maladie*',
                isRequired: true,
                maxLines: 5,
              ),

              const SizedBox(height: 24),
              _buildSectionHeader('5. Antécédents Médicaux et Chirurgicaux'),

              const Text(
                '5.1 Antécédents médicaux personnels',
                  style: TextStyle(
                 fontWeight: FontWeight.bold,
                 color: Colors.black, // Changement ici
                  ),
              ),
              

              _buildAntecedentsSection(
                title: 'Cardiovasculaire',
                items: [
                  'HTA',
                  'Insuffisance cardiaque',
                  'Angor',
                  'IDM',
                  'Valvulopathie',
                  'Pacemaker',
                  'Thrombose',
                ],
              ),

              _buildAntecedentsSection(
                title: 'Respiratoire',
                items: [
                  'BPCO',
                  'Asthme',
                  'Oxygénothérapie',
                  'Tuberculose',
                  'Apnée du sommeil',
                  'Emphysème',
                  'DDB',
                  'Pneumothorax',
                ],
              ),

             _buildEndocrinoPersoSection(),

              _buildAntecedentsSection(
                title: 'Hépatobiliaire',
                items: ['Hépatite', 'Cirrhose'],
              ),

              _buildAntecedentsSection(
                title: 'Rénal',
                items: [
                  'Insuffisance rénale chronique',
                    'Insuffaisance rénale aiguë',
                  'Dialyse',
                  'Infection urinaire',
                  'Hypertrophie de la prostate',
                ],
              ),

               _buildAntecedentsSection(
                title: 'Neurologique/Psychiatrique',
                items: [
                  'Epilepsie',
                  'accident vasculaire cérébral',
                  'Myasthénie',
                  'hypertension intracranienne(HTIC)',
                  'Antécédents psychiatriques',
                  'Autres'
                ],
              ),

                _buildAntecedentsSection(
                title: 'Gastro-intestinal',
                items: [
                  'Ulcére',
                  'reflux gastro oesphagien(RGO)',
                   'Pancréatite',
                   'Diarrhée chronique',
                   'Autres',
                ],
              ),

              _buildAntecedentsSection(
                title: 'Ophtalmologique',
                items: ['Cataracte', 'Glaucome'],
              ),

              _buildAntecedentsSection(
                title: 'Hématologique',
                items: ['Gingivorragies', 'Ecchymoses'],
              ),

              _buildAntecedentsSection(
                title: 'Infectieux',
                items: ['HIV', 'Hépatite B', 'Hépatite C'],
              ),

              _buildAntecedentsSection(
                title: 'Gynéco-obstétricaux',
                items: ['Contraception'],
              ),

              _buildAntecedentsSection(
                title: 'Toxicologie/Addictions',
                items: [
                  'Alcool',
                  'Tabac (PA)',
                  'Stupéfiants',
                  'Produits inhalés',
                ],
              ),

              _buildTextFormField(
                'autresAntecedents',
                'Autres antécédents à préciser',
                maxLines: 3,
              ),

              const Text(
                '5.2 Antécédents chirurgicaux',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Changé en noir
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Type d\'intervention',
                style: TextStyle(
                 fontWeight: FontWeight.bold,
                 color: Colors.black, // Changement ici
                  ),                    ),

                    _buildTextFormField(
                      'type_intervention',
                      'Précisez le type d\'intervention',
                    ),

                    const SizedBox(height: 8),
                    const Text(
                      'Date de chirurgie',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    ListTile(
                      title: Text(
                        _dateChirurgie == null
                            ? 'Sélectionner une date'
                            : 'Date: ${DateFormat('dd/MM/yyyy').format(_dateChirurgie!)}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectSurgeryDate(context),
                    ),

                    const SizedBox(height: 8),
                    const Text(
                      'Complications per/post-opératoires',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    _buildDropdown('complications_chirurgie', 'Sélectionner', [
                      'Hémorragie',
                      'Infection',
                      'Cardio-respiratoire',
                      'Autre',
                    ]),

                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _ajouterAntecedentChirurgical,
                      child: const Text('Ajouter cet antécédent chirurgical'),
                    ),

                    if (_antecedentsChirurgicauxList.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Antécédents chirurgicaux enregistrés:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      ..._antecedentsChirurgicauxList
                          .map(
                            (antecedent) => ListTile(
                              title: Text(antecedent['type']),
                              subtitle: Text(
                                '${DateFormat('dd/MM/yyyy').format(antecedent['date'])} - ${antecedent['complications']}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed:
                                    () => _supprimerAntecedentChirurgical(
                                      antecedent,
                                    ),
                              ),
                            ),
                          )
                          .toList(),
                    ],
                  ],
                ),
              ),
              const Text(
                '5.3 Antécédents médicaux familiaux',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Changé en noir
                ),
              ),


              ExpansionTile(
                title: const Text('Cardiovasculaire'),
                children: [
                  _buildCheckboxList(
                    items: ['HTA', 'Troubles du rythme', 'Autre'],
                    selectedItems: _antecedentsFamiliauxCardio,
                    onChanged:
                        (selected) => setState(
                          () => _antecedentsFamiliauxCardio = selected,
                        ),
                  ),
                ],
              ),

              ExpansionTile(
                title: const Text('Respiratoire'),
                children: [
                  _buildCheckboxList(
                    items: [
                      'Asthme',
                      'BPCO',
                      'Tuberculose',
                      'Apnée du sommeil',
                      'Autre',
                    ],
                    selectedItems: _antecedentsFamiliauxRespiratoire,
                    onChanged:
                        (selected) => setState(
                          () => _antecedentsFamiliauxRespiratoire = selected,
                        ),
                  ),
                ],
              ),

ExpansionTile(
  title: const Text('Endocrino-métabolique'),
  children: [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Diabète (inchangée)
        ListTile(
          title: const Text('Diabète'),
          trailing: Icon(_showDiabeteOptions 
              ? Icons.keyboard_arrow_up 
              : Icons.keyboard_arrow_down),
          onTap: () {
            setState(() {
              _showDiabeteOptions = !_showDiabeteOptions;
              if (_showDiabeteOptions) {
                _showThyroideOptions = false;
                _showAutreEndocrino = false;
              }
            });
          },
        ),
        
        if (_showDiabeteOptions) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text('Insulino-dépendant'),
                  value: 'Diabète - Insulino-dépendant',
                  groupValue: _selectedDiabeteType,
                  onChanged: (value) {
                    setState(() {
                      _selectedDiabeteType = value;
                      _antecedentsFamiliauxEndocrino.removeWhere((item) => 
                          item.startsWith('Diabète - ') || item.startsWith('Autre - '));
                      if (value != null) {
                        _antecedentsFamiliauxEndocrino.add(value);
                      }
                      _autreEndocrinoController.clear();
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Non insulino-dépendant'),
                  value: 'Diabète - Non insulino-dépendant',
                  groupValue: _selectedDiabeteType,
                  onChanged: (value) {
                    setState(() {
                      _selectedDiabeteType = value;
                      _antecedentsFamiliauxEndocrino.removeWhere((item) => 
                          item.startsWith('Diabète - ') || item.startsWith('Autre - '));
                      if (value != null) {
                        _antecedentsFamiliauxEndocrino.add(value);
                      }
                      _autreEndocrinoController.clear();
                    });
                  },
                ),
              ],
            ),
          ),
        ],
        
        // Section Thyroïde (inchangée)
        ListTile(
          title: const Text('Thyroïde'),
          trailing: Icon(_showThyroideOptions 
              ? Icons.keyboard_arrow_up 
              : Icons.keyboard_arrow_down),
          onTap: () {
            setState(() {
              _showThyroideOptions = !_showThyroideOptions;
              if (_showThyroideOptions) {
                _showDiabeteOptions = false;
                _showAutreEndocrino = false;
              }
            });
          },
        ),
        
        if (_showThyroideOptions) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text('Hyperthyroïdie'),
                  value: 'Thyroïde - Hyperthyroïdie',
                  groupValue: _selectedThyroideType,
                  onChanged: (value) {
                    setState(() {
                      _selectedThyroideType = value;
                      _antecedentsFamiliauxEndocrino.removeWhere((item) => 
                          item.startsWith('Thyroïde - ') || item.startsWith('Autre - '));
                      if (value != null) {
                        _antecedentsFamiliauxEndocrino.add(value);
                      }
                      _autreEndocrinoController.clear();
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Hypothyroïdie'),
                  value: 'Thyroïde - Hypothyroïdie',
                  groupValue: _selectedThyroideType,
                  onChanged: (value) {
                    setState(() {
                      _selectedThyroideType = value;
                      _antecedentsFamiliauxEndocrino.removeWhere((item) => 
                          item.startsWith('Thyroïde - ') || item.startsWith('Autre - '));
                      if (value != null) {
                        _antecedentsFamiliauxEndocrino.add(value);
                      }
                      _autreEndocrinoController.clear();
                    });
                  },
                ),
              ],
            ),
          ),
        ],
        
        // Nouvelle section Autre
        ListTile(
          title: const Text('Autre'),
          trailing: Icon(_showAutreEndocrino 
              ? Icons.keyboard_arrow_up 
              : Icons.keyboard_arrow_down),
          onTap: () {
            setState(() {
              _showAutreEndocrino = !_showAutreEndocrino;
              if (_showAutreEndocrino) {
                _showDiabeteOptions = false;
                _showThyroideOptions = false;
              }
            });
          },
        ),
        
        if (_showAutreEndocrino) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: Column(
              children: [
                TextField(
                  controller: _autreEndocrinoController,
                  decoration: InputDecoration(
                    labelText: 'Préciser autre pathologie endocrino-métabolique',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _antecedentsFamiliauxEndocrino.removeWhere((item) => 
                          item.startsWith('Autre - '));
                      if (value.isNotEmpty) {
                        _antecedentsFamiliauxEndocrino.add('Autre - $value');
                        _selectedDiabeteType = null;
                        _selectedThyroideType = null;
                      }
                    });
                  },
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ],
    ),
  ],
),
              ExpansionTile(
                title: const Text('Rénal'),
                children: [
                  _buildCheckboxList(
                    items: ['Insuffisance rénale', 'Autre'],
                    selectedItems: _antecedentsFamiliauxRenal,
                    onChanged:
                        (selected) => setState(
                          () => _antecedentsFamiliauxRenal = selected,
                        ),
                  ),
                ],
              ),

              ExpansionTile(
                title: const Text('Oncologique'),
                children: [
                  _buildCheckboxList(
                    items: ['Sein', 'Colon', 'Prostate', 'Autre'],
                    selectedItems: _antecedentsFamiliauxOncologique,
                    onChanged:
                        (selected) => setState(
                          () => _antecedentsFamiliauxOncologique = selected,
                        ),
                  ),
                ],
              ),

              ExpansionTile(
                title: const Text('Neurologique/Psychiatrique'),
                children: [
                  _buildCheckboxList(
                    items: [
                      'AVC',
                      'Épilepsie',
                      'Alzheimer',
                      'Troubles psychiatriques',
                      'Autre',
                    ],
                    selectedItems: _antecedentsFamiliauxNeuro,
                    onChanged:
                        (selected) => setState(
                          () => _antecedentsFamiliauxNeuro = selected,
                        ),
                  ),
                ],
              ),

              _buildTextFormField(
                'autres_antecedents_familiaux',
                'Autres antécédents familiaux',
                maxLines: 2,
              ),

              const Text(
                '5.4 Antécédents chirurgicaux familiaux',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Changé en noir
                ),
              ),

              _buildTextFormField(
                'antecedents_chirurgicaux_familiaux',
                'Interventions connues dans la famille',
                maxLines: 3,
              ),

             

const Text(
                '5.5 Maladies chroniques et traitement en cours',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Changé en noir
                ),
              ),

              Wrap(
                spacing: 8,
                children:
                    [
                      'Cardiaque',
                      'Digestif',
                      'Respiratoire',
                      'Neurologique',
                      'Rhumatologique',
                      'Autre',
                    ].map((maladie) {
                      return FilterChip(
                        label: Text(maladie),
                        selected: _maladiesChroniques.contains(maladie),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _maladiesChroniques.add(maladie);
                            } else {
                              _maladiesChroniques.remove(maladie);
                            }
                          });
                        },
                      );
                    }).toList(),
              ),

              if (_maladiesChroniques.contains('Autre'))
                _buildTextFormField(
                  'maladie_chronique_autre',
                  'Précisez la maladie chronique',
                ),

              _buildTextFormField(
                'traitements_en_cours_details',
                'Traitement(s) en cours (nom, posologie, fréquence)',
                maxLines: 4,
              ),

              const SizedBox(height: 24),
              _buildActionButtons(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
