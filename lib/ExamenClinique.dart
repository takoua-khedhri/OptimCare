import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'Evaluation.dart';

class ExamenClinique extends StatefulWidget {
  final String patientId;

  const ExamenClinique({Key? key, required this.patientId}) : super(key: key);

  @override
  _ExamenCliniqueState createState() => _ExamenCliniqueState();
}

class _ExamenCliniqueState extends State<ExamenClinique> {
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
    // Force la validation de tous les champs
    if (_formKey.currentState!.validate()) {
      // Vérification manuelle des champs obligatoires
      if (
          _temperatureController.text.trim().isEmpty ||
          _tensionController.text.trim().isEmpty ||
          _freqCardiaqueController.text.trim().isEmpty ||
          _freqRespiratoireController.text.trim().isEmpty ||
          _saturationController.text.trim().isEmpty ||
          _glycemieController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez remplir tous les champs obligatoires'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

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
            });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Evaluation(patientId: widget.patientId),
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
    String? selectedValue,
    List<String> items,
    Function(String?) onChanged, {
    bool isRequired = false,
  }) {
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
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: selectedValue,
            onChanged: onChanged,
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
            validator: isRequired
            
                ? (value) => value == null || value.isEmpty 
                    ? 'Ce champ est obligatoire' 
                    : null
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
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        label: RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(color: Colors.black54, fontSize: 16),
            children: isRequired
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    )
                  ]
                : [],
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      validator: isRequired
          ? (value) => value == null || value.trim().isEmpty 
              ? 'Ce champ est obligatoire' 
              : null
          : null,
    ),
  );
}

 Widget _buildTensionField() {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: TextFormField(
      controller: _tensionController,
      keyboardType: TextInputType.text,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
      ],
      decoration: InputDecoration(
        label: RichText(
          text: const TextSpan(
            text: 'Tension artérielle (mmHg)',
            style: TextStyle(color: Colors.black54, fontSize: 16),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
        hintText: 'ex: 120/80',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Ce champ est obligatoire';
        }
        final parts = value.split('/');
        if (parts.length != 2) return 'Format: XXX/XX';
        return null;
      },
    ),
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
                      onPressed: _enregistrerExamenClinique,
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
                        onPressed: _enregistrerExamenClinique,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        shadowColor: Colors.black38,
        minimumSize: fullWidth ? const Size(double.infinity, 50) : null,
        animationDuration: const Duration(milliseconds: 200),
        enableFeedback: true,
      ),
      icon: Icon(icon, size: isSmallScreen ? 18 : 20),
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Examen Clinique',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade700,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('1. Observation Générale'),
              _buildDropdown(
                'Apparence générale',
                _apparenceGenerale,
                ['Bonne', 'Fatiguée', 'Altérée', 'Autre'],
                (value) => setState(() => _apparenceGenerale = value),
              ),
              _buildDropdown(
                'État de conscience',
                _etatConscience,
                ['Conscient', 'Confus', 'Somnolent', 'Inconscient'],
                (value) => setState(() => _etatConscience = value),
              ),
              _buildDropdown(
                'Mobilité',
                _mobilite,
                ['Autonome', 'Aidé', 'Alité', 'Immobilisé'],
                (value) => setState(() => _mobilite = value),
              ),
              _buildDropdown(
                'Langage',
                _langage,
                ['Clair', 'Lent', 'Troubles de l\'élocution'],
                (value) => setState(() => _langage = value),
              ),
              _buildTextFieldSection(
                'Observation libre',
                _observationGeneraleController,
                maxLines: 3,
              ),

              _buildSectionHeader('2. Système Neurologique'),
              _buildDropdown(
                'Pupilles',
                _pupilles,
                ['Isocores', 'Anisocores', 'Mydriase', 'Réactives'],
                (value) => setState(() => _pupilles = value),
              ),
              _buildDropdown(
                'Orientation',
                _orientation,
                ['Orienté', 'Désorienté', 'Glasgow'],
                (value) => setState(() => _orientation = value),
              ),
              _buildDropdown(
                'Troubles neurologiques',
                _troublesNeurologiques,
                ['Paresthésies', 'Céphalées', 'Vertiges', 'Absents'],
                (value) => setState(() => _troublesNeurologiques = value),
              ),
              _buildTextFieldSection(
                'Observation neurologique',
                _neurologiqueObservationController,
                maxLines: 3,
              ),

              _buildSectionHeader('3. Appareil Respiratoire'),
              _buildDropdown(
                'Respiration',
                _respiration,
                ['Normale', 'Rapide', 'Polypnée', 'Dyspnée', 'Bradypnée'],
                (value) => setState(() => _respiration = value),
              ),
              _buildDropdown(
                'Bruits respiratoires',
                _bruitsRespiratoires,
                ['Normaux', 'Silence', 'Ronchis', 'Sibilants'],
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

              _buildSectionHeader('4. Appareil Cardiovasculaire'),
              _buildDropdown(
                'Pouls',
                _pouls,
                ['Régulier', 'Irregulier', 'Filant'],
                (value) => setState(() => _pouls = value),
              ),
              _buildDropdown(
                'Œdèmes',
                _oedemes,
                ['Aucun', 'Bilatéral', 'Unilatéral', 'A godet'],
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

              _buildSectionHeader('5. Système Digestif'),
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
                ['Souple', 'Douloureux', 'Défense', 'Ballonnement'],
                (value) => setState(() => _abdomen = value),
              ),
              _buildTextFieldSection(
                'Observation digestive',
                _digestifObservationController,
                maxLines: 3,
              ),

              _buildSectionHeader('6. Appareil Urinaire'),
              _buildDropdown(
                'Miction',
                _miction,
                ['Spontanée', 'Sondée', 'Rétention'],
                (value) => setState(() => _miction = value),
              ),
              _buildDropdown(
                'Aspect des urines',
                _aspectUrines,
                ['Normal', 'Troubles', 'Hématurie', 'Sombre'],
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

              _buildSectionHeader('7. Peau et Téguments'),
              _buildDropdown(
                'Intégrité cutanée',
                _integriteCutane,
                ['Préservée', 'Rougeurs', 'Lésions', 'Plaies'],
                (value) => setState(() => _integriteCutane = value),
              ),
              _buildDropdown(
                'Risque d\'escarre',
                _risqueEscarre,
                ['Oui', 'Non'],
                (value) => setState(() => _risqueEscarre = value),
              ),
              _buildTextFieldSection(
                'Observation peau et téguments',
                _peauObservationController,
                maxLines: 3,
              ),

              _buildSectionHeader('8. Locomotion / Autonomie'),
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

              _buildSectionHeader('9. Paramètres Vitaux'),
              _buildTextFieldSection(
                'Température (°C)',
                _temperatureController,
                keyboardType: TextInputType.number,
                isRequired: true,
              ),
              _buildTensionField(),

              _buildTextFieldSection(
                'Fréquence cardiaque (bpm)',
                _freqCardiaqueController,
                keyboardType: TextInputType.number,
                isRequired: true,
              ),
              _buildTextFieldSection(
                'Fréquence respiratoire (/min)',
                _freqRespiratoireController,
                keyboardType: TextInputType.number,
                isRequired: true,
              ),
              _buildTextFieldSection(
                'Saturation O2 (%)',
                _saturationController,
                keyboardType: TextInputType.number,
                isRequired: true,
              ),
              _buildTextFieldSection(
                'Glycémie capillaire (g/L)',
                _glycemieController,
                keyboardType: TextInputType.number,
                isRequired: true,
              ),

              _buildSectionHeader('10. Diagnostic et Prescription'),
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
            ],
          ),
        ),
      ),
    );
  }
}