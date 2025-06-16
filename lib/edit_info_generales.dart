import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditInformationsGenerales extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic> initialData;

  const EditInformationsGenerales({
    Key? key,
    required this.patientId,
    required this.initialData,
  }) : super(key: key);

  @override
  _EditInformationsGeneralesState createState() => _EditInformationsGeneralesState();
}

class _EditInformationsGeneralesState extends State<EditInformationsGenerales> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _formData;
  DateTime? _dateChirurgie;
  bool _showAutreEndocrino = false;
 TextEditingController _autreEndocrinoController = TextEditingController();
  List<Map<String, dynamic>> _antecedentsChirurgicauxList = [];
  List<String> _antecedentsFamiliauxCardio = [];
  List<String> _antecedentsFamiliauxRespiratoire = [];
  List<String> _antecedentsFamiliauxEndocrino = [];
  List<String> _antecedentsFamiliauxRenal = [];
  List<String> _antecedentsFamiliauxOncologique = [];
  List<String> _antecedentsFamiliauxNeuro = [];
  List<String> _maladiesChroniques = [];
  bool _showDiabeteOptions = false;
  bool _showThyroideOptions = false;
  String? _selectedDiabeteType;
  String? _selectedThyroideType;

  bool? _hasAllergies;
  String? _selectedAllergyType;
  bool? _hasDeficiences;
  String? _selectedDeficienceType;
  List<String> _entryStates = [];

  @override
  void initState() {
    super.initState();
    _formData = Map<String, dynamic>.from(widget.initialData);

    // Initialiser les données des antécédents chirurgicaux
    if (_formData['antecedentsChirurgicaux'] != null) {
      _antecedentsChirurgicauxList = List<Map<String, dynamic>>.from(_formData['antecedentsChirurgicaux']);
    }

    // Initialiser les listes d'antécédents familiaux
    _antecedentsFamiliauxCardio = List<String>.from(_formData['antecedentsFamiliauxCardio'] ?? []);
    _antecedentsFamiliauxRespiratoire = List<String>.from(_formData['antecedentsFamiliauxRespiratoire'] ?? []);
    _antecedentsFamiliauxEndocrino = List<String>.from(_formData['antecedentsFamiliauxEndocrino'] ?? []);
    _antecedentsFamiliauxRenal = List<String>.from(_formData['antecedentsFamiliauxRenal'] ?? []);
    _antecedentsFamiliauxOncologique = List<String>.from(_formData['antecedentsFamiliauxOncologique'] ?? []);
    _antecedentsFamiliauxNeuro = List<String>.from(_formData['antecedentsFamiliauxNeuro'] ?? []);
    _maladiesChroniques = List<String>.from(_formData['maladiesChroniques'] ?? []);


_hasAllergies = _formData['hasAllergies'];
    _selectedAllergyType = _formData['selectedAllergyType'];
    _hasDeficiences = _formData['hasDeficiences'];
    _selectedDeficienceType = _formData['selectedDeficienceType'];
    _entryStates = List<String>.from(_formData['entryStates'] ?? []);

    // Initialiser les options de diabète et thyroïde
    _initEndocrinoOptions();
  }

  void _initEndocrinoOptions() {
    for (var item in _antecedentsFamiliauxEndocrino) {
      if (item.startsWith('Diabète - ')) {
        _selectedDiabeteType = item;
      } else if (item.startsWith('Thyroïde - ')) {
        _selectedThyroideType = item;
      }
    }
  }

  Future<void> _selectSurgeryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateChirurgie ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateChirurgie) {
      setState(() {
        _dateChirurgie = picked;
      });
    }
  }

  void _ajouterAntecedentChirurgical() {
    if (_formData['type_intervention'] == null || _formData['type_intervention'].isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez spécifier le type d\'intervention')),
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
        'type': _formData['type_intervention'],
        'date': _dateChirurgie!,
        'complications': _formData['complications_chirurgie'] ?? 'Aucune',
      });

      // Réinitialiser les champs
      _formData['type_intervention'] = '';
      _dateChirurgie = null;
      _formData['complications_chirurgie'] = null;
    });
  }

  void _supprimerAntecedentChirurgical(Map<String, dynamic> antecedent) {
    setState(() {
      _antecedentsChirurgicauxList.remove(antecedent);
    });
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
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

  Widget _buildTextField({
    required String label,
    required String field,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          suffixIcon: isRequired ? const Icon(Icons.star, size: 12, color: Colors.red) : null,
        ),
        initialValue: _formData[field]?.toString() ?? '',
        onChanged: (value) => _formData[field] = value,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: isRequired
            ? (value) => value == null || value.isEmpty ? 'Ce champ est obligatoire' : null
            : null,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String field,
    required List<String> items,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        value: _formData[field],
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          suffixIcon: isRequired ? const Icon(Icons.star, size: 12, color: Colors.red) : null,
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) => setState(() => _formData[field] = value),
        validator: isRequired && _formData[field] == null
            ? (value) => 'Ce champ est obligatoire'
            : null,
      ),
    );
  }

  Widget _buildCheckboxList({
    required List<String> items,
    required List<String> selectedItems,
    required Function(List<String>) onChanged,
  }) {
    return Column(
      children: items.map((item) {
        return CheckboxListTile(
          title: Text(item),
          value: selectedItems.contains(item),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                selectedItems.add(item);
              } else {
                selectedItems.remove(item);
              }
              onChanged(selectedItems);
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildAntecedentsSection({
    required String title,
    required List<String> items,
  }) {
    return ExpansionTile(
      title: Text(title),
      children: [
        _buildCheckboxList(
          items: items,
          selectedItems: _formData['antecedents_${title.toLowerCase()}'] ?? [],
          onChanged: (selected) {
            setState(() {
              _formData['antecedents_${title.toLowerCase()}'] = selected;
            });
          },
        ),
      ],
    );
  }

  Widget _buildEndocrinoPersoSection() {
    return ExpansionTile(
      title: const Text('Endocrino-métabolique (personnel)'),
      children: [
        _buildCheckboxList(
          items: [
            'Diabète',
            'Dyslipidémie',
            'Hyperthyroïdie',
            'Hypothyroïdie',
            'Obésité',
            'Autre',
          ],
          selectedItems: _formData['antecedents_endocrino_perso'] ?? [],
          onChanged: (selected) {
            setState(() {
              _formData['antecedents_endocrino_perso'] = selected;
            });
          },
        ),
      ],
    );
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Mettre à jour les nouvelles données médicales
        _formData['hasAllergies'] = _hasAllergies;
        _formData['selectedAllergyType'] = _selectedAllergyType;
        _formData['hasDeficiences'] = _hasDeficiences;
        _formData['selectedDeficienceType'] = _selectedDeficienceType;
        _formData['entryStates'] = _entryStates;
        // Mettre à jour les données des antécédents chirurgicaux
        _formData['antecedentsChirurgicaux'] = _antecedentsChirurgicauxList;

        // Mettre à jour les antécédents familiaux
        _formData['antecedentsFamiliauxCardio'] = _antecedentsFamiliauxCardio;
        _formData['antecedentsFamiliauxRespiratoire'] = _antecedentsFamiliauxRespiratoire;
        _formData['antecedentsFamiliauxEndocrino'] = _antecedentsFamiliauxEndocrino;
        _formData['antecedentsFamiliauxRenal'] = _antecedentsFamiliauxRenal;
        _formData['antecedentsFamiliauxOncologique'] = _antecedentsFamiliauxOncologique;
        _formData['antecedentsFamiliauxNeuro'] = _antecedentsFamiliauxNeuro;
        _formData['maladiesChroniques'] = _maladiesChroniques;

        await FirebaseFirestore.instance
            .collection('Patients')
            .doc(widget.patientId)
            .collection('DossierMedical')
            .doc('informations_generales')
            .update(_formData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informations mises à jour avec succès')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour: $e')),
        );
      }
    }
  }




  Widget _buildMedicalInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('1. Informations Médicales'),
        
        // Allergies
        const Text('Allergies', style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            const Text('Oui'),
            Radio<bool>(
              value: true,
              groupValue: _hasAllergies,
              onChanged: (value) {
                setState(() {
                  _hasAllergies = value;
                });
              },
            ),
            const Text('Non'),
            Radio<bool>(
              value: false,
              groupValue: _hasAllergies,
              onChanged: (value) {
                setState(() {
                  _hasAllergies = value;
                  if (value == false) {
                    _selectedAllergyType = null;
                    _formData['allergyDetails'] = null;
                  }
                });
              },
            ),
          ],
        ),
        
        if (_hasAllergies == true) ...[
          const SizedBox(height: 8),
          _buildDropdown(
            label: 'Type d\'allergie',
            field: 'selectedAllergyType',
            items: ['Alimentaire', 'Médicamenteuse', 'Environnementale', 'Autre'],
            isRequired: true,
          ),
          
          if (_selectedAllergyType == 'Autre') 
            _buildTextField(
              label: 'Précisez le type d\'allergie',
              field: 'allergyDetails',
              isRequired: true,
            ),
        ],
        
        const SizedBox(height: 16),
        
        // Déficiences
        const Text('Déficiences', style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            const Text('Oui'),
            Radio<bool>(
              value: true,
              groupValue: _hasDeficiences,
              onChanged: (value) {
                setState(() {
                  _hasDeficiences = value;
                });
              },
            ),
            const Text('Non'),
            Radio<bool>(
              value: false,
              groupValue: _hasDeficiences,
              onChanged: (value) {
                setState(() {
                  _hasDeficiences = value;
                  if (value == false) {
                    _selectedDeficienceType = null;
                    _formData['deficiencyDetails'] = null;
                  }
                });
              },
            ),
          ],
        ),
        
        if (_hasDeficiences == true) ...[
          const SizedBox(height: 8),
          _buildDropdown(
            label: 'Type de déficience',
            field: 'selectedDeficienceType',
            items: ['Auditive', 'Visuelle', 'Mentale', 'Motrice', 'Autre'],
            isRequired: true,
          ),
          
          if (_selectedDeficienceType == 'Autre') 
            _buildTextField(
              label: 'Précisez le type de déficience',
              field: 'deficiencyDetails',
              isRequired: true,
            ),
        ],
        
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Régime alimentaire',
          field: 'diet',
        ),
        
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Mode de vie',
          field: 'lifestyle',
          items: ['Sédentaire', 'Activité physique'],
        ),
      ],
    );
  }

  Widget _buildHospitalAdmissionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('2. Histoire de la Maladie & Admission'),
        
        _buildTextField(
          label: 'Motif d\'hospitalisation',
          field: 'hospitalizationReason',
          isRequired: true,
          maxLines: 3,
        ),
        
        const SizedBox(height: 16),
        const Text('Date d\'hospitalisation', style: TextStyle(fontWeight: FontWeight.bold)),
        ListTile(
          title: Text(
            _formData['hospitalizationDate'] == null
                ? 'Sélectionner une date'
                : 'Date: ${DateFormat('dd/MM/yyyy HH:mm').format((_formData['hospitalizationDate'] as Timestamp).toDate())}',
          ),
          trailing: const Icon(Icons.calendar_today),
          onTap: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: _formData['hospitalizationDate'] != null 
                  ? (_formData['hospitalizationDate'] as Timestamp).toDate() 
                  : DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            
            if (pickedDate != null) {
              final TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              
              if (pickedTime != null) {
                setState(() {
                  _formData['hospitalizationDate'] = Timestamp.fromDate(
                    DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    ),
                  );
                });
              }
            }
          },
        ),
        
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Mode d\'entrée à l\'hôpital',
          field: 'entryMode',
          items: ['Consultation', 'Urgence', 'Transfert'],
          isRequired: true,
        ),
        
        const SizedBox(height: 16),
        const Text('État d\'entrée', style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: [
            'Autonome',
            'Fauteuil roulant',
            'Alité',
            'Conscient',
            'Confus',
            'Inconscient',
          ].map((state) {
            return FilterChip(
              label: Text(state),
              selected: _entryStates.contains(state),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _entryStates.add(state);
                  } else {
                    _entryStates.remove(state);
                  }
                });
              },
            );
          }).toList(),
        ),
        
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Histoire de la maladie',
          field: 'diseaseHistory',
          isRequired: true,
          maxLines: 5,
        ),
      ],
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
   appBar: AppBar(
  leading: IconButton(
    icon: Icon(Icons.arrow_back),
    onPressed: () {
      Navigator.pop(context); // Revenir à la page précédente
    },
  ),
  title: Text(
    'Informations Médicales',
    style: TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    textAlign: TextAlign.center,
  ),
  centerTitle: true,
  backgroundColor: Colors.teal.shade700,
  elevation: 0,
),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               _buildMedicalInformationSection(),
              const SizedBox(height: 24),
              _buildHospitalAdmissionSection(),
              const SizedBox(height: 24),
              _buildSectionHeader('3. Antécédents Médicaux et Chirurgicaux'),

              const Text(
                '3.1 Antécédents médicaux personnels',
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
                  'Insuffisance rénale aiguë',
                  'Dialyse',
                  'Infection urinaire',
                  'Hypertrophie de la prostate',
                ],
              ),

              _buildAntecedentsSection(
                title: 'Neurologique/Psychiatrique',
                items: [
                  'Epilepsie',
                  'Accident vasculaire cérébral',
                  'Myasthénie',
                  'Hypertension intracrânienne (HTIC)',
                  'Antécédents psychiatriques',
                  'Autres'
                ],
              ),

              _buildAntecedentsSection(
                title: 'Gastro-intestinal',
                items: [
                  'Ulcère',
                  'Reflux gastro-œsophagien (RGO)',
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

              _buildTextField(
                label: 'Autres antécédents à préciser',
                field: 'autresAntecedents',
                maxLines: 3,
              ),

              const Text(
                '3.2 Antécédents chirurgicaux',
                style: TextStyle(
                 fontWeight: FontWeight.bold,
                 color: Colors.black, // Changement ici
                  ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Type d\'intervention',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    _buildTextField(
                      label: 'Précisez le type d\'intervention',
                      field: 'type_intervention',
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

                    _buildDropdown(
                      label: 'Sélectionner',
                      field: 'complications_chirurgie',
                      items: [
                        'Hémorragie',
                        'Infection',
                        'Cardio-respiratoire',
                        'Autre',
                      ],
                    ),

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
                                onPressed: () => _supprimerAntecedentChirurgical(antecedent),
                              ),
                            ),
                          )
                          .toList(),
                    ],
                  ],
                ),
              ),

              const Text(
                '3.3 Antécédents médicaux familiaux',
                style: TextStyle(
                 fontWeight: FontWeight.bold,
                 color: Colors.black, // Changement ici
                  ),
              ),

              ExpansionTile(
                title: const Text('Cardiovasculaire'),
                children: [
                  _buildCheckboxList(
                    items: ['HTA', 'Troubles du rythme', 'Autre'],
                    selectedItems: _antecedentsFamiliauxCardio,
                    onChanged: (selected) => setState(() => _antecedentsFamiliauxCardio = selected),
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
                    onChanged: (selected) => setState(() => _antecedentsFamiliauxRespiratoire = selected),
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
                    onChanged: (selected) => setState(() => _antecedentsFamiliauxRenal = selected),
                  ),
                ],
              ),

              ExpansionTile(
                title: const Text('Oncologique'),
                children: [
                  _buildCheckboxList(
                    items: ['Sein', 'Colon', 'Prostate', 'Autre'],
                    selectedItems: _antecedentsFamiliauxOncologique,
                    onChanged: (selected) => setState(() => _antecedentsFamiliauxOncologique = selected),
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
                    onChanged: (selected) => setState(() => _antecedentsFamiliauxNeuro = selected),
                  ),
                ],
              ),

              _buildTextField(
                label: 'Autres antécédents familiaux',
                field: 'autres_antecedents_familiaux',
                maxLines: 2,
              ),

              const Text(
                '3.4 Antécédents chirurgicaux familiaux',
                style: TextStyle(
                 fontWeight: FontWeight.bold,
                 color: Colors.black, // Changement ici
                  ),
              ),
              _buildTextField(
                label: 'Interventions connues dans la famille',
                field: 'antecedents_chirurgicaux_familiaux',
                maxLines: 3,
              ),

              const Text(
                '3.5 Maladies chroniques et traitement en cours',
                style: TextStyle(
                 fontWeight: FontWeight.bold,
                 color: Colors.black, // Changement ici
                  ),
              ),

              Wrap(
                spacing: 8,
                children: [
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
                _buildTextField(
                  label: 'Précisez la maladie chronique',
                  field: 'maladie_chronique_autre',
                ),

              _buildTextField(
                label: 'Traitement(s) en cours (nom, posologie, fréquence)',
                field: 'traitements_en_cours_details',
                maxLines: 4,
              ),

              const SizedBox(height: 24),
             Center(
  child: LayoutBuilder(
    builder: (context, constraints) {
      // Adapte la taille du bouton en fonction de la largeur de l'écran
      final buttonWidth = constraints.maxWidth > 600 
          ? constraints.maxWidth * 0.5  // 50% de largeur sur grands écrans
          : constraints.maxWidth * 0.9; // 90% de largeur sur petits écrans
      
      return ElevatedButton(
        onPressed: _saveData,
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
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}