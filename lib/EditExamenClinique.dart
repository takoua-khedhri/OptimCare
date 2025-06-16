import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class EditExamenClinique extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic> initialData;

  const EditExamenClinique({
    Key? key,
    required this.patientId,
    required this.initialData,
  }) : super(key: key);

  @override
  _EditExamenCliniqueState createState() => _EditExamenCliniqueState();
}

class _EditExamenCliniqueState extends State<EditExamenClinique> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Contrôleurs pour les champs texte
  final TextEditingController _observationGeneraleController = TextEditingController();
  final TextEditingController _neurologiqueObservationController = TextEditingController();
  final TextEditingController _respiratoireObservationController = TextEditingController();
  final TextEditingController _cardiovasculaireObservationController = TextEditingController();
  final TextEditingController _digestifObservationController = TextEditingController();
  final TextEditingController _urinaireObservationController = TextEditingController();
  final TextEditingController _diureseController = TextEditingController();
  final TextEditingController _peauObservationController = TextEditingController();
  final TextEditingController _locomotionObservationController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _tensionController = TextEditingController();
  final TextEditingController _freqCardiaqueController = TextEditingController();
  final TextEditingController _freqRespiratoireController = TextEditingController();
  final TextEditingController _saturationController = TextEditingController();
  final TextEditingController _glycemieController = TextEditingController();
  final TextEditingController _diagnosticController = TextEditingController();
  final TextEditingController _prescriptionController = TextEditingController();

  // Variables d'état pour les sélections
  String? _apparenceGenerale;
  String? _etatConscience;
  String? _mobilite;
  String? _langage;
  String? _pupilles;
  String? _orientation;
  String? _troublesNeurologiques;
  String? _respiration;
  String? _bruitsRespiratoires;
  String? _toux;
  String? _pouls;
  String? _oedemes;
  String? _colorationCutane;
  String? _appetit;
  String? _transitIntestinal;
  String? _abdomen;
  String? _miction;
  String? _aspectUrines;
  String? _integriteCutane;
  String? _risqueEscarre;
  String? _deplacement;
  String? _aidesTechniques;
  String? _autonomieAVQ;
  DateTime? _dateExamen;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

 void _initializeData() {
  // Initialiser les contrôleurs texte avec les données existantes
  _observationGeneraleController.text = widget.initialData['observationGenerale']?['observationLibre'] ?? '';
  _neurologiqueObservationController.text = widget.initialData['systemeNeurologique']?['observationLibre'] ?? '';
  _respiratoireObservationController.text = widget.initialData['appareilRespiratoire']?['observationLibre'] ?? '';
  _cardiovasculaireObservationController.text = widget.initialData['appareilCardiovasculaire']?['observationLibre'] ?? '';
  _digestifObservationController.text = widget.initialData['systemeDigestif']?['observationLibre'] ?? '';
  _urinaireObservationController.text = widget.initialData['appareilUrinaire']?['observationLibre'] ?? '';
  _diureseController.text = widget.initialData['appareilUrinaire']?['diurese'] ?? '';
  _peauObservationController.text = widget.initialData['peauTeguments']?['observationLibre'] ?? '';
  _locomotionObservationController.text = widget.initialData['locomotionAutonomie']?['observationLibre'] ?? '';
  _temperatureController.text = widget.initialData['parametresVitaux']?['temperature'] ?? '';
  _tensionController.text = widget.initialData['parametresVitaux']?['tensionArterielle'] ?? '';
  _freqCardiaqueController.text = widget.initialData['parametresVitaux']?['freqCardiaque'] ?? '';
  _freqRespiratoireController.text = widget.initialData['parametresVitaux']?['freqRespiratoire'] ?? '';
  _saturationController.text = widget.initialData['parametresVitaux']?['saturationO2'] ?? '';
  _glycemieController.text = widget.initialData['parametresVitaux']?['glycemie'] ?? '';
  _diagnosticController.text = widget.initialData['diagnosticMedical'] ?? '';
  _prescriptionController.text = widget.initialData['prescriptionMedicale'] ?? '';

  // Initialiser les dropdowns avec validation des valeurs
  _apparenceGenerale = _validateDropdownValue(
    widget.initialData['observationGenerale']?['apparenceGenerale'],
    ['Bonne', 'Fatiguée', 'Altérée', 'Autre']
  );
  
  _etatConscience = _validateDropdownValue(
    widget.initialData['observationGenerale']?['etatConscience'],
    ['Conscient', 'Confus', 'Somnolent', 'Inconscient']
  );
  
  _mobilite = _validateDropdownValue(
    widget.initialData['observationGenerale']?['mobilite'],
    ['Autonome', 'Aidé', 'Alité', 'Immobilisé']
  );
  
  _langage = _validateDropdownValue(
    widget.initialData['observationGenerale']?['langage'],
    ['Clair', 'Lent', 'Troubles de l\'élocution']
  );
  
  _pupilles = _validateDropdownValue(
    widget.initialData['systemeNeurologique']?['pupilles'],
    ['Isocores', 'Anisocores', 'Mydriase', 'Réactives']
  );
  
  _orientation = _validateDropdownValue(
    widget.initialData['systemeNeurologique']?['orientation'],
    ['Orienté', 'Désorienté', 'Glasgow']
  );
  
  _troublesNeurologiques = _validateDropdownValue(
    widget.initialData['systemeNeurologique']?['troublesNeurologiques'],
    [ 'Céphalées', 'Vertiges', 'Paresthésies', 'absents']
  );
  
  _respiration = _validateDropdownValue(
    widget.initialData['appareilRespiratoire']?['respiration'],
    ['Normale', 'Dyspnée', 'Polypnée','Bradypnée']
  );
  
  _bruitsRespiratoires = _validateDropdownValue(
    widget.initialData['appareilRespiratoire']?['bruitsRespiratoires'],
    ['Normaux', 'Ronchis', 'Sibilants', 'Silence', 'Autres']
  );
  
  _toux = _validateDropdownValue(
    widget.initialData['appareilRespiratoire']?['toux'],
    ['Absente', 'Sèche', 'Productive']
  );
  
  _pouls = _validateDropdownValue(
    widget.initialData['appareilCardiovasculaire']?['pouls'],
    ['Régulier', 'Irregulier','Filant']
  );
  
  _oedemes = _validateDropdownValue(
    widget.initialData['appareilCardiovasculaire']?['oedemes'],
    ['Aucun', 'Bilatéral', 'Unilatéral' ,'A godet']
  );
  
  _colorationCutane = _validateDropdownValue(
    widget.initialData['appareilCardiovasculaire']?['colorationCutane'],
    ['Normale', 'Pâle', 'Cyanosée']
  );
  
  _appetit = _validateDropdownValue(
    widget.initialData['systemeDigestif']?['appetit'],
    ['Normal', 'Diminué', 'Absent']
  );
  
  _transitIntestinal = _validateDropdownValue(
    widget.initialData['systemeDigestif']?['transitIntestinal'],
    ['Normal', 'Constipation', 'Diarrhée', 'Autre']
  );
  
  _abdomen = _validateDropdownValue(
    widget.initialData['systemeDigestif']?['abdomen'],
    ['Souple', 'Douloureux', 'Défense', 'Ballonnement']
  );
  
  _miction = _validateDropdownValue(
    widget.initialData['appareilUrinaire']?['miction'],
    ['Spontanée', 'Sondée', 'Rétention']
  );
  
  _aspectUrines = _validateDropdownValue(
    widget.initialData['appareilUrinaire']?['aspectUrines'],
    ['Normal', 'Troubles', 'Sombre', 'Hématurie']
  );
  
  _integriteCutane = _validateDropdownValue(
    widget.initialData['peauTeguments']?['integriteCutane'],
    ['Préservée', 'Rougeurs', 'Plaies', 'Lésions']
  );
  
  _risqueEscarre = _validateDropdownValue(
    widget.initialData['peauTeguments']?['risqueEscarre'],
    ['Oui', 'Non']
  );
  
  _deplacement = _validateDropdownValue(
    widget.initialData['locomotionAutonomie']?['deplacement'],
    ['Autonome', 'Aidé', 'Nécessite 2 personnes']
  );
  
  _aidesTechniques = _validateDropdownValue(
    widget.initialData['locomotionAutonomie']?['aidesTechniques'],
    ['Aucune', 'Canne', 'Déambulateur', 'Fauteuil roulant']
  );
  
  _autonomieAVQ = _validateDropdownValue(
    widget.initialData['locomotionAutonomie']?['autonomieAVQ'],
    ['Autonome', 'Partiellement dépendant', 'Dépendant']
  );

  // Initialiser la date
  if (widget.initialData['dateExamen'] != null) {
    _dateExamen = (widget.initialData['dateExamen'] as Timestamp).toDate();
  } else {
    _dateExamen = DateTime.now();
  }
}

  String? _validateDropdownValue(dynamic value, List<String> validOptions) {
    final stringValue = value?.toString();
    return validOptions.contains(stringValue) ? stringValue : null;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _observationGeneraleController.dispose();
    _neurologiqueObservationController.dispose();
    _respiratoireObservationController.dispose();
    _cardiovasculaireObservationController.dispose();
    _digestifObservationController.dispose();
    _urinaireObservationController.dispose();
    _diureseController.dispose();
    _peauObservationController.dispose();
    _locomotionObservationController.dispose();
    _temperatureController.dispose();
    _tensionController.dispose();
    _freqCardiaqueController.dispose();
    _freqRespiratoireController.dispose();
    _saturationController.dispose();
    _glycemieController.dispose();
    _diagnosticController.dispose();
    _prescriptionController.dispose();
    super.dispose();
  }

  Future<void> _enregistrerExamenClinique() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('Patients')
            .doc(widget.patientId)
            .collection('DossierMedical')
            .doc('Examen_clinique')
            .set({
              'diagnosticMedical': _diagnosticController.text,
              'prescriptionMedicale': _prescriptionController.text,
              'observationGenerale': {
                'apparenceGenerale': _apparenceGenerale,
                'etatConscience': _etatConscience,
                'mobilite': _mobilite,
                'langage': _langage,
                'observationLibre': _observationGeneraleController.text,
              },
              'systemeNeurologique': {
                'pupilles': _pupilles,
                'orientation': _orientation,
                'troublesNeurologiques': _troublesNeurologiques,
                'observationLibre': _neurologiqueObservationController.text,
              },
              'appareilRespiratoire': {
                'respiration': _respiration,
                'bruitsRespiratoires': _bruitsRespiratoires,
                'toux': _toux,
                'observationLibre': _respiratoireObservationController.text,
              },
              'appareilCardiovasculaire': {
                'pouls': _pouls,
                'oedemes': _oedemes,
                'colorationCutane': _colorationCutane,
                'observationLibre': _cardiovasculaireObservationController.text,
              },
              'systemeDigestif': {
                'appetit': _appetit,
                'transitIntestinal': _transitIntestinal,
                'abdomen': _abdomen,
                'observationLibre': _digestifObservationController.text,
              },
              'appareilUrinaire': {
                'miction': _miction,
                'aspectUrines': _aspectUrines,
                'diurese': _diureseController.text,
                'observationLibre': _urinaireObservationController.text,
              },
              'peauTeguments': {
                'integriteCutane': _integriteCutane,
                'risqueEscarre': _risqueEscarre,
                'observationLibre': _peauObservationController.text,
              },
              'locomotionAutonomie': {
                'deplacement': _deplacement,
                'aidesTechniques': _aidesTechniques,
                'autonomieAVQ': _autonomieAVQ,
                'observationLibre': _locomotionObservationController.text,
              },
              'parametresVitaux': {
                'temperature': _temperatureController.text,
                'tensionArterielle': _tensionController.text,
                'freqCardiaque': _freqCardiaqueController.text,
                'freqRespiratoire': _freqRespiratoireController.text,
                'saturationO2': _saturationController.text,
                'glycemie': _glycemieController.text,
              },
              'dateExamen': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Examen clinique mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String title,
    String? value,
    List<String> items,
    Function(String?) onChanged, {
    bool isRequired = false,
  }) {
    // Vérifier que la valeur existe dans les items
    final validValue = items.contains(value) ? value : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: title,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              children: isRequired
                  ? [
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: validValue,
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              suffixIcon: isRequired
                  ? const Icon(Icons.star, size: 12, color: Colors.red)
                  : null,
            ),
            validator: isRequired && validValue == null
                ? (val) => 'Ce champ est obligatoire'
                : null,
            isExpanded: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldSection(
    String label,
    TextEditingController controller, {
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: '$label${isRequired ? '*' : ''}',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          suffixIcon: isRequired
              ? const Icon(Icons.star, size: 12, color: Colors.red)
              : null,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: isRequired && (controller.text.isEmpty)
            ? (value) => 'Ce champ est obligatoire'
            : null,
      ),
    );
  }

  Widget _buildTensionField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: _tensionController,
        decoration: InputDecoration(
          labelText: 'Tension artérielle (mmHg)*',
          hintText: 'ex: 120/80',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          suffixIcon: const Icon(Icons.star, size: 12, color: Colors.red),
        ),
        keyboardType: TextInputType.text,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
        ],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Ce champ est obligatoire';
          }
          final regex = RegExp(r'^\d{2,3}/\d{2,3}$');
          if (!regex.hasMatch(value)) {
            return 'Format incorrect. Doit être sous forme: XXX/XX (ex: 120/80)';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
       
      
               Center(
  child: LayoutBuilder(
    builder: (context, constraints) {
      // Adapte la taille du bouton en fonction de la largeur de l'écran
      final buttonWidth = constraints.maxWidth > 600 
          ? constraints.maxWidth * 0.5  // 50% de largeur sur grands écrans
          : constraints.maxWidth * 0.9; // 90% de largeur sur petits écrans
      
      return ElevatedButton(
        onPressed: _enregistrerExamenClinique,
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Modifier Examen Clinique',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
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
              // Section I. Observation Générale
              _buildSectionHeader('I. Observation Générale'),
             // Dans Observation Générale
_buildDropdown(
  'Apparence générale',
  _apparenceGenerale,
  ['Bonne', 'Fatiguée', 'Altérée', 'Autre'],
  (value) => setState(() => _apparenceGenerale = value),
  isRequired: true,
),
_buildDropdown(
  'État de conscience',
  _etatConscience,
  ['Conscient', 'Confus', 'Somnolent', 'Inconscient'],
  (value) => setState(() => _etatConscience = value),
  isRequired: true,
),

// Dans Paramètres Vitaux
_buildTextFieldSection(
  'Température (°C)',
  _temperatureController,
  isRequired: true,
  keyboardType: TextInputType.number,
),
_buildTensionField(), // Déjà marqué comme obligatoire
_buildTextFieldSection(
  'Fréquence cardiaque (bpm)',
  _freqCardiaqueController,
  isRequired: true,
  keyboardType: TextInputType.number,
),
_buildTextFieldSection(
  'Fréquence respiratoire (/min)',
  _freqRespiratoireController,
  isRequired: true,
  keyboardType: TextInputType.number,
),
_buildTextFieldSection(
  'Saturation O2 (%)',
  _saturationController,
  isRequired: true,
  keyboardType: TextInputType.number,
),
              // Section II. Système Neurologique
              _buildSectionHeader('II. Système Neurologique'),
              _buildDropdown(
                'Pupilles',
                _pupilles,
                ['Isocores', 'Anisocores', 'Mydriase', 'Réactives'],
                (value) => setState(() => _pupilles = value),
              ),
              _buildDropdown(
                'Orientation',
                _orientation,
                [
                  'Orienté',
                  'Désorienté',
                  'Glasgow',
                ],
                (value) => setState(() => _orientation = value),
              ),
              _buildDropdown(
                'Troubles neurologiques',
                _troublesNeurologiques,
                [
                  'Céphalées',
                  'Vertiges',
                  'Paresthésies',
                  'Absents',
                ],
                (value) => setState(() => _troublesNeurologiques = value),
              ),
              _buildTextFieldSection(
                'Observation neurologique',
                _neurologiqueObservationController,
                maxLines: 3,
              ),

              // Section III. Appareil Respiratoire
              _buildSectionHeader('III. Appareil Respiratoire'),
              _buildDropdown(
                'Respiration',
                _respiration,
                ['Normale', 'Dyspnée', 'Polypnée', 'Bradypnée'],
                (value) => setState(() => _respiration = value),
              ),
              _buildDropdown(
                'Bruits respiratoires',
                _bruitsRespiratoires,
                ['Normaux', 'Ronchis', 'Sibilants', 'Silence'],
                (value) => setState(() => _bruitsRespiratoires = value),
              ),
              _buildDropdown(
                'Toux',
                _toux,
                ['Absente', 'Sèche', 'Productive'],
                (value) => setState(() => _toux = value),
              ),
              _buildTextFieldSection(
                'Observation respiratoire',
                _respiratoireObservationController,
                maxLines: 3,
              ),

              // Section IV. Appareil Cardiovasculaire
              _buildSectionHeader('IV. Appareil Cardiovasculaire'),
              _buildDropdown(
                'Pouls',
                _pouls,
                ['Régulier', 'Irrégulier', 'Filant'],
                (value) => setState(() => _pouls = value),
              ),
              _buildDropdown(
                'Œdèmes',
                _oedemes,
                ['Aucun', 'Bilatéral', 'Unilatéral','A godet'],
                (value) => setState(() => _oedemes = value),
              ),
              _buildDropdown(
                'Coloration cutanée',
                _colorationCutane,
                ['Normale', 'Pâle', 'Cyanosée'],
                (value) => setState(() => _colorationCutane = value),
              ),
              _buildTextFieldSection(
                'Observation cardiovasculaire',
                _cardiovasculaireObservationController,
                maxLines: 3,
              ),

              // Section V. Système Digestif
              _buildSectionHeader('V. Système Digestif'),
              _buildDropdown(
                'Appétit',
                _appetit,
                ['Normal', 'Diminué', 'Absent'],
                (value) => setState(() => _appetit = value),
              ),
              _buildDropdown(
                'Transit intestinal',
                _transitIntestinal,
                ['Normal', 'Constipation', 'Diarrhée', 'Autre'],
                (value) => setState(() => _transitIntestinal = value),
              ),
              _buildDropdown(
                'Abdomen',
                _abdomen,
                ['Souple', 'Douloureur localisée', 'Défense', 'Ballonnement'],
                (value) => setState(() => _abdomen = value),
              ),
              _buildTextFieldSection(
                'Observation digestive',
                _digestifObservationController,
                maxLines: 3,
              ),

              // Section VI. Appareil Urinaire
              _buildSectionHeader('VI. Appareil Urinaire'),
              _buildDropdown(
                'Miction',
                _miction,
                ['Spontanée', 'Sondée', 'Rétention'],
                (value) => setState(() => _miction = value),
              ),
              _buildDropdown(
                'Aspect des urines',
                _aspectUrines,
                ['Normal', 'Troubles', 'Sombre', 'Hématurie'],
                (value) => setState(() => _aspectUrines = value),
              ),
              _buildTextFieldSection(
                'Diurèse (mL/24h)',
                _diureseController,
                keyboardType: TextInputType.number,
              ),
              _buildTextFieldSection(
                'Observation urinaire',
                _urinaireObservationController,
                maxLines: 3,
              ),

              // Section VII. Peau et Téguments
              _buildSectionHeader('VII. Peau et Téguments'),
              _buildDropdown(
                'Intégrité cutanée',
                _integriteCutane,
                ['Préservée', 'Rougeurs', 'Plaies', 'Lésions'],
                (value) => setState(() => _integriteCutane = value),
              ),
              _buildDropdown(
                'Risque d\'escarre',
                _risqueEscarre,
                ['Oui','Non'],
                (value) => setState(() => _risqueEscarre = value),
              ),
              _buildTextFieldSection(
                'Observation peau et téguments',
                _peauObservationController,
                maxLines: 3,
              ),

              // Section VIII. Locomotion / Autonomie
              _buildSectionHeader('VIII. Locomotion / Autonomie'),
              _buildDropdown(
                'Déplacement',
                _deplacement,
                ['Autonome', 'Aidé', 'Nécessite 2 personnes'],
                (value) => setState(() => _deplacement = value),
              ),
              _buildDropdown(
                'Aides techniques',
                _aidesTechniques,
                ['Aucune', 'Cannes', 'Déambulateur', 'Fauteuil roulant'],
                (value) => setState(() => _aidesTechniques = value),
              ),
              _buildDropdown(
                'Autonomie AVQ',
                _autonomieAVQ,
                ['Autonome', 'Partiellement dépendant', 'Dépendant'],
                (value) => setState(() => _autonomieAVQ = value),
              ),
              _buildTextFieldSection(
                'Observation locomotion/autonomie',
                _locomotionObservationController,
                maxLines: 3,
              ),

              // Section IX. Paramètres Vitaux
              _buildSectionHeader('IX. Paramètres Vitaux'),
              _buildTextFieldSection(
                'Température (°C)',
                _temperatureController,
                isRequired: true,
                keyboardType: TextInputType.number,
              ),
              _buildTensionField(),
              _buildTextFieldSection(
                'Fréquence cardiaque (bpm)',
                _freqCardiaqueController,
                isRequired: true,
                keyboardType: TextInputType.number,
              ),
              _buildTextFieldSection(
                'Fréquence respiratoire (/min)',
                _freqRespiratoireController,
                isRequired: true,
                keyboardType: TextInputType.number,
              ),
              _buildTextFieldSection(
                'Saturation O2 (%)',
                _saturationController,
                isRequired: true,
                keyboardType: TextInputType.number,
              ),
              _buildTextFieldSection(
                'Glycémie capillaire (g/L)',
                _glycemieController,
                keyboardType: TextInputType.number,
              ),

              // Section X. Diagnostic et Prescription
              _buildSectionHeader('X. Diagnostic et Prescription'),
              _buildTextFieldSection(
                'Diagnostic médical',
                _diagnosticController,
                maxLines: 3,
              ),
              _buildTextFieldSection(
                'Prescription médicale',
                _prescriptionController,
                maxLines: 5,
              ),

              _buildActionButtons(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}