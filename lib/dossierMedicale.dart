import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'edit_info_generales.dart';
import 'edit_info_personnelle.dart';
import 'EditExamenClinique.dart';
import 'EditPassation.dart';
import 'edit_plan_soins.dart';
import 'edit_besoins.dart';
import 'pdf.dart';
import 'package:flutter/foundation.dart'; // Pour kDebugMode
import 'package:intl/intl.dart';

class DossierMedicalePage extends StatefulWidget {
  final String patientId;

  const DossierMedicalePage({Key? key, required this.patientId})
    : super(key: key);

  @override
  _DossierMedicalePageState createState() => _DossierMedicalePageState();
}

class _DossierMedicalePageState extends State<DossierMedicalePage> {
  final Map<String, bool> _expandedSections = {
    'info_personnelle': false,
    'informations_generales': false,
    'Examen_clinique': false,
    '14_besoins': false,
    'plan_soins_actuel': false,
    'passation': false,
  };

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Non spécifié';
    if (timestamp is Timestamp) {
      return DateFormat('dd/MM/yyyy HH:mm').format(timestamp.toDate());
    }
    return timestamp.toString();
  }

  Widget _buildInfoRow(String label, dynamic value, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                color: isHeader ? Colors.teal.shade700 : Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value?.toString() ?? 'Non spécifié',
              style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String sectionKey, {
    VoidCallback? onEdit,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onEdit != null)
            IconButton(
              icon: Icon(Icons.edit, color: Colors.white),
              onPressed: onEdit,
            ),
          Icon(
            _expandedSections[sectionKey]!
                ? Icons.expand_less
                : Icons.expand_more,
            color: Colors.white,
          ),
        ],
      ),
      tileColor: Colors.teal.shade700,
      onTap: () {
        setState(() {
          _expandedSections[sectionKey] = !_expandedSections[sectionKey]!;
        });
      },
    );
  }

 Widget _buildPersonalInfoSection(String infermierId) {
  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection('Patients')
        .doc(widget.patientId)
        .collection('DossierMedical')
        .doc('info_personnelle')
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return _buildLoadingCard();
      }
      if (!snapshot.hasData || !snapshot.data!.exists) {
        return _buildNoDataCard('Informations Personnelles');
      }

      final data = snapshot.data!.data() as Map<String, dynamic>;

      // Fonction helper pour gérer les valeurs nulles
      String _getValue(dynamic value) => value?.toString() ?? 'Non spécifié';

      return Card(
        elevation: 3,
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            _buildSectionHeader(
              'Informations Personnelles et Sociales',
              'info_personnelle',
              onEdit: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditInfoPersonnelle(
                      patientId: widget.patientId,
                      initialData: data,
                    ),
                  ),
                );
              },
            ),
            if (_expandedSections['info_personnelle']!) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(
                      'Nom complet',
                      '${_getValue(data['nom'])} ${_getValue(data['prenom'])}',
                      isHeader: true,
                    ),
                    const Divider(),
                    _buildInfoRow('Matricule', _getValue(data['matricule'])),
                    _buildInfoRow(
                      'Couverture sociale',
                      _getValue(data['couvertureSociale']),
                    ),
                    _buildInfoRow('Sexe', _getValue(data['sexe'])),
                    _buildInfoRow('Nationalité', _getValue(data['nationalite'])),
                    _buildInfoRow('Lit', _getValue(data['lit'])),
                    _buildInfoRow('Téléphone', _getValue(data['telephone'])),
                    _buildInfoRow('Profession', _getValue(data['profession'])),
                    _buildInfoRow(
                      'Date création',
                      data['createdAt'] != null
                          ? _formatTimestamp(data['createdAt'])
                          : 'Non spécifié',
                    ),
                    _buildInfoRow(
                      'Dernière mise à jour',
                      data['updatedAt'] != null
                          ? _formatTimestamp(data['updatedAt'])
                          : 'Non spécifié',
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
}

  Widget _buildGeneralInfoSection(String infermierId) {
  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection('Patients')
        .doc(widget.patientId)
        .collection('DossierMedical')
        .doc('informations_generales')
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return _buildLoadingCard();
      }
      if (!snapshot.hasData || !snapshot.data!.exists) {
        return _buildNoDataCard('Informations Générales');
      }

      final data = snapshot.data!.data() as Map<String, dynamic>;

      // Fonction pour formater les tableaux en String
      String _formatArray(List<dynamic>? array) {
        if (array == null || array.isEmpty) return 'Non spécifiée';
        return array.join(', ');
      }

      // Fonction pour gérer les valeurs null
      String _handleNull(dynamic value) {
        return value?.toString().isNotEmpty == true ? value.toString() : 'Non spécifiée';
      }

      return Card(
        elevation: 3,
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            _buildSectionHeader(
              'Informations Médicales',
              'informations_generales',
              onEdit: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditInformationsGenerales(
                      patientId: widget.patientId,
                      initialData: data,
                    ),
                  ),
                );
              },
            ),
            if (_expandedSections['informations_generales']!) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(
                      'Motif hospitalisation',
                      _handleNull(data['motifHospitalisation']),
                      isHeader: true,
                    ),
                    const Divider(),
                    _buildInfoRow('Mode d\'entrée', _handleNull(data['modeEntree'])),
                    _buildInfoRow(
                      'Date hospitalisation',
                      _formatTimestamp(data['dateHospitalisation']),
                    ),
                    _buildInfoRow(
                      'Allergies',
                      data['allergies'] == true
                          ? 'Oui (${_handleNull(data['typeAllergie'])})'
                          : 'Non',
                    ),
                    if (data['allergies'] == true)
                      _buildInfoRow(
                        'Détails allergies',
                        _handleNull(data['allergiesPrecision']),
                      ),
                    _buildInfoRow(
                      'Régime alimentaire',
                      _handleNull(data['regimeAlimentaire']),
                    ),
                    _buildInfoRow(
                      'Traitements en cours',
                      _handleNull(data['traitementsEnCours']),
                    ),
                    _buildInfoRow(
                      'Histoire de la maladie',
                      _handleNull(data['histoireMaladie']),
                    ),
                    _buildInfoRow(
                      'Mode de vie',
                      _handleNull(data['modeVie']),
                    ),
                    _buildInfoRow(
                      'Antécédents médicaux',
                      _formatArray(data['antecedentsMedicaux']),
                    ),
                    _buildInfoRow(
                      'Maladies chroniques',
                      _formatArray(data['maladiesChroniques']),
                    ),
                    _buildInfoRow(
                      'Antécédents chirurgicaux',
                      _formatArray(data['antecedentsChirurgicaux']),
                    ),
                    _buildInfoRow(
                      'Déficiences',
                      data['deficiences'] == true
                          ? 'Oui (${_handleNull(data['typeDeficience'])})'
                          : 'Non',
                    ),
                    if (data['deficiences'] == true)
                      _buildInfoRow(
                        'Détails déficiences',
                        _handleNull(data['deficiencesPrecision']),
                      ),
                    _buildInfoRow(
                      'Autres antécédents',
                      _handleNull(data['autresAntecedents']),
                    ),
                    _buildInfoRow(
                      'Antécédents familiaux cardio',
                      _formatArray(data['antecedentsFamiliauxCardio']),
                    ),
                    _buildInfoRow(
                      'Antécédents familiaux endocrino',
                      _formatArray(data['antecedentsFamiliauxEndocrino']),
                    ),
                    _buildInfoRow(
                      'Antécédents familiaux neuro',
                      _formatArray(data['antecedentsFamiliauxNeuro']),
                    ),
                    _buildInfoRow(
                      'Antécédents familiaux oncologique',
                      _formatArray(data['antecedentsFamiliauxOncologique']),
                    ),
                    _buildInfoRow(
                      'Antécédents familiaux renal',
                      _formatArray(data['antecedentsFamiliauxRenal']),
                    ),
                    _buildInfoRow(
                      'Antécédents familiaux respiratoire',
                      _formatArray(data['antecedentsFamiliauxRespiratoire']),
                    ),
                    _buildInfoRow(
                      'Autres antécédents familiaux',
                      _handleNull(data['autresAntecedentsFamiliaux']),
                    ),
                    _buildInfoRow(
                      'État à l\'entrée',
                      _formatArray(data['etatEntree']),
                    ),
                    
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
}

Widget _buildClinicalExamSection(String infermierId) {
  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection('Patients')
        .doc(widget.patientId)
        .collection('DossierMedical')
        .doc('Examen_clinique')
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return _buildLoadingCard();
      }
      if (!snapshot.hasData || !snapshot.data!.exists) {
        return _buildNoDataCard('Examen Clinique');
      }

      final data = snapshot.data!.data() as Map<String, dynamic>;

      // Fonction helper pour gérer les valeurs nulles
      String _getValue(dynamic value) => value?.toString() ?? 'Non spécifié';

      return Card(
        elevation: 3,
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            _buildSectionHeader(
              'Examen Clinique',
              'Examen_clinique',
              onEdit: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditExamenClinique(
                      patientId: widget.patientId,
                      initialData: data,
                    ),
                  ),
                );
              },
            ),
            if (_expandedSections['Examen_clinique']!) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      'Date examen',
                      _formatTimestamp(data['dateExamen']),
                      isHeader: true,
                    ),
                  
                    const Divider(),
               // Observation générale
                    const Text(
                      'Observation générale',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    if (data['observationGenerale'] != null) ...[
                      _buildInfoRow('État de conscience', _getValue(data['observationGenerale']['etatConscience'])),
                      _buildInfoRow('Apparence générale', _getValue(data['observationGenerale']['apparenceGenerale'])),
                      _buildInfoRow('Mobilité', _getValue(data['observationGenerale']['mobilite'])),
                      _buildInfoRow('Langage', _getValue(data['observationGenerale']['langage'])),
                      if (_getValue(data['observationGenerale']['observationLibre']).isNotEmpty)
                        _buildInfoRow('Observations', _getValue(data['observationGenerale']['observationLibre'])),
                    ] else ...[
                      _buildInfoRow('État de conscience', 'Non spécifié'),
                      _buildInfoRow('Apparence générale', 'Non spécifié'),
                      _buildInfoRow('Mobilité', 'Non spécifié'),
                      _buildInfoRow('Langage', 'Non spécifié'),
                    ],
                const Divider(),

                const Text(
                      'Système neurologique',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    if (data['systemeNeurologique'] != null) ...[
                      _buildInfoRow('Orientation', _getValue(data['systemeNeurologique']['orientation'])),
                      _buildInfoRow('Pupilles', _getValue(data['systemeNeurologique']['pupilles'])),
                      _buildInfoRow('Troubles neurologiques', _getValue(data['systemeNeurologique']['troublesNeurologiques'])),
                      if (_getValue(data['systemeNeurologique']['observationLibre']).isNotEmpty)
                        _buildInfoRow('Observations', _getValue(data['systemeNeurologique']['observationLibre'])),
                    ] else ...[
                      _buildInfoRow('Orientation', 'Non spécifié'),
                      _buildInfoRow('Pupilles', 'Non spécifié'),
                      _buildInfoRow('Troubles neurologiques', 'Non spécifié'),
                    ],
                    const Divider(),
                    // Appareil respiratoire
                    const Text(
                      'Appareil respiratoire',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    if (data['appareilRespiratoire'] != null) ...[
                      _buildInfoRow('Respiration', _getValue(data['appareilRespiratoire']['respiration'])),
                      _buildInfoRow('Bruits respiratoires', _getValue(data['appareilRespiratoire']['bruitsRespiratoires'])),
                      _buildInfoRow('Toux', _getValue(data['appareilRespiratoire']['toux'])),
                      if (_getValue(data['appareilRespiratoire']['observationLibre']).isNotEmpty)
                        _buildInfoRow('Observations', _getValue(data['appareilRespiratoire']['observationLibre'])),
                    ] else ...[
                      _buildInfoRow('Respiration', 'Non spécifié'),
                      _buildInfoRow('Bruits respiratoires', 'Non spécifié'),
                      _buildInfoRow('Toux', 'Non spécifié'),
                    ],
                    const Divider(),
                    // Appareil cardiovasculaire
                    const Text(
                      'Appareil cardiovasculaire',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    if (data['appareilCardiovasculaire'] != null) ...[
                      _buildInfoRow('Pouls', _getValue(data['appareilCardiovasculaire']['pouls'])),
                      _buildInfoRow('Œdèmes', _getValue(data['appareilCardiovasculaire']['oedemes'])),
                      _buildInfoRow('Coloration cutanée', _getValue(data['appareilCardiovasculaire']['colorationCutane'])),
                      if (_getValue(data['appareilCardiovasculaire']['observationLibre']).isNotEmpty)
                        _buildInfoRow('Observations', _getValue(data['appareilCardiovasculaire']['observationLibre'])),
                    ] else ...[
                      _buildInfoRow('Pouls', 'Non spécifié'),
                      _buildInfoRow('Œdèmes', 'Non spécifié'),
                      _buildInfoRow('Coloration cutanée', 'Non spécifié'),
                    ],
                    const Divider(),
// Système digestif
                    const Text(
                      'Système digestif',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    if (data['systemeDigestif'] != null) ...[
                      _buildInfoRow('Abdomen', _getValue(data['systemeDigestif']['abdomen'])),
                      _buildInfoRow('Appétit', _getValue(data['systemeDigestif']['appetit'])),
                      _buildInfoRow('Transit intestinal', _getValue(data['systemeDigestif']['transitIntestinal'])),
                      if (_getValue(data['systemeDigestif']['observationLibre']).isNotEmpty)
                        _buildInfoRow('Observations', _getValue(data['systemeDigestif']['observationLibre'])),
                    ] else ...[
                      _buildInfoRow('Abdomen', 'Non spécifié'),
                      _buildInfoRow('Appétit', 'Non spécifié'),
                      _buildInfoRow('Transit intestinal', 'Non spécifié'),
                    ],
                    const Divider(),
                   // Appareil urinaire
                    const Text(
                      'Appareil urinaire',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    if (data['appareilUrinaire'] != null) ...[
                      _buildInfoRow('Diurèse', _getValue(data['appareilUrinaire']['diurese'])),
                      _buildInfoRow('Aspect des urines', _getValue(data['appareilUrinaire']['aspectUrines'])),
                      _buildInfoRow('Miction', _getValue(data['appareilUrinaire']['miction'])),
                      if (_getValue(data['appareilUrinaire']['observationLibre']).isNotEmpty)
                        _buildInfoRow('Observations', _getValue(data['appareilUrinaire']['observationLibre'])),
                    ] else ...[
                      _buildInfoRow('Diurèse', 'Non spécifié'),
                      _buildInfoRow('Aspect des urines', 'Non spécifié'),
                      _buildInfoRow('Miction', 'Non spécifié'),
                    ],
                    const Divider(),

                    // Peau et téguments
                    const Text(
                      'Peau et téguments',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    if (data['peauTeguments'] != null) ...[
                      _buildInfoRow('Intégrité cutanée', _getValue(data['peauTeguments']['integriteCutane'])),
                      _buildInfoRow('Risque escarre', _getValue(data['peauTeguments']['risqueEscarre'])),
                      if (_getValue(data['peauTeguments']['observationLibre']).isNotEmpty)
                        _buildInfoRow('Observations', _getValue(data['peauTeguments']['observationLibre'])),
                    ] else ...[
                      _buildInfoRow('Intégrité cutanée', 'Non spécifié'),
                      _buildInfoRow('Risque escarre', 'Non spécifié'),
                    ],
                    const Divider(),
  // Locomotion et autonomie
                    const Text(
                      'Locomotion et autonomie',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    if (data['locomotionAutonomie'] != null) ...[
                      _buildInfoRow('Déplacement', _getValue(data['locomotionAutonomie']['deplacement'])),
                      _buildInfoRow('Autonomie AVQ', _getValue(data['locomotionAutonomie']['autonomieAVQ'])),
                      _buildInfoRow('Aides techniques', _getValue(data['locomotionAutonomie']['aidesTechniques'])),
                      if (_getValue(data['locomotionAutonomie']['observationLibre']).isNotEmpty)
                        _buildInfoRow('Observations', _getValue(data['locomotionAutonomie']['observationLibre'])),
                    ] else ...[
                      _buildInfoRow('Déplacement', 'Non spécifié'),
                      _buildInfoRow('Autonomie AVQ', 'Non spécifié'),
                      _buildInfoRow('Aides techniques', 'Non spécifié'),
                    ],
                    const Divider(),
                    // Paramètres vitaux
                    const Text(
                      'Paramètres vitaux',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    if (data['parametresVitaux'] != null) ...[
                      _buildInfoRow('Température', '${_getValue(data['parametresVitaux']['temperature'])} °C'),
                      _buildInfoRow('Tension artérielle', '${_getValue(data['parametresVitaux']['tensionArterielle'])} mmHg'),
                      _buildInfoRow('Fréquence cardiaque', '${_getValue(data['parametresVitaux']['freqCardiaque'])} bpm'),
                      _buildInfoRow('Fréquence respiratoire', '${_getValue(data['parametresVitaux']['freqRespiratoire'])} rpm'),
                      _buildInfoRow('Saturation O2', '${_getValue(data['parametresVitaux']['saturationO2'])}%'),
                      _buildInfoRow('Glycémie', '${_getValue(data['parametresVitaux']['glycemie'])} g/L'),
                    ] else ...[
                      _buildInfoRow('Température', 'Non spécifié'),
                      _buildInfoRow('Tension artérielle', 'Non spécifié'),
                      _buildInfoRow('Fréquence cardiaque', 'Non spécifié'),
                      _buildInfoRow('Fréquence respiratoire', 'Non spécifié'),
                      _buildInfoRow('Saturation O2', 'Non spécifié'),
                      _buildInfoRow('Glycémie', 'Non spécifié'),
                    ],
                    const Divider(),

                  ],
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
}

Widget _buildNeedsSection(String infermierId) {
  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection('Patients')
        .doc(widget.patientId)
        .collection('DossierMedical')
        .doc('14_besoins')
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return _buildLoadingCard();
      }
      if (!snapshot.hasData || !snapshot.data!.exists) {
        return _buildNoDataCard('14 Besoins Fondamentaux');
      }

      final data = snapshot.data!.data() as Map<String, dynamic>;
      final derniereEvaluation = data['derniereEvaluation'] as Map<String, dynamic>?;
      final besoins = (derniereEvaluation != null 
          ? derniereEvaluation['besoins'] 
          : data['besoins']) as List<dynamic>? ?? [];

      // Fonction robuste pour formater la date
      String getEvaluationDate() {
        try {
          if (derniereEvaluation == null) return 'Non spécifiée';
          
          // Vérification en profondeur du champ dateEvaluation
          final dateField = derniereEvaluation['dateEvaluation'];
          if (dateField == null) return 'Non spécifiée';

          // Si c'est déjà une string formatée
          if (dateField is String) {
            return dateField.isNotEmpty ? dateField : 'Non spécifiée';
          }
          // Si c'est un Timestamp Firestore
          else if (dateField is Timestamp) {
            return DateFormat('d MMMM y', 'fr_FR').format(dateField.toDate());
          }
          // Si c'est un DateTime
          else if (dateField is DateTime) {
            return DateFormat('d MMMM y', 'fr_FR').format(dateField);
          }
          // Si c'est un Map (timestamp Firestore formaté)
          else if (dateField is Map && dateField['_seconds'] != null) {
            final timestamp = Timestamp(dateField['_seconds'], dateField['_nanoseconds'] ?? 0);
            return DateFormat('d MMMM y', 'fr_FR').format(timestamp.toDate());
          }
        } catch (e) {
          debugPrint('Erreur de formatage de date: $e');
          if (kDebugMode) print('Contenu de dateEvaluation: ${derniereEvaluation?['dateEvaluation']}');
        }
        return 'Non spécifiée';
      }

      return Card(
        elevation: 3,
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            _buildSectionHeader(
              '14 Besoins Fondamentaux',
              '14_besoins',
              onEdit: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditBesoins(
                      patientId: widget.patientId,
                      initialData: data,
                    ),
                  ),
                );
              },
            ),
            if (_expandedSections['14_besoins']!) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(
                      'Derniere Mise à jour',
                      getEvaluationDate(),
                      isHeader: true,
                    ),
                    const Divider(),
                    ...besoins.map((besoin) => _buildBesoinTile(besoin)).toList(),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
}

// Fonction séparée pour construire un ListTile de besoin
Widget _buildBesoinTile(dynamic besoin) {
  return ListTile(
    contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
    dense: true,
    title: Text(
      '${besoin['id']}. ${besoin['nom']}',
      style: TextStyle(fontSize: 14),
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
    ),
    trailing: Chip(
      label: Text(
        besoin['satisfait'] == true ? 'Satisfait' :
        besoin['satisfait'] == false ? 'Non satisfait' : 'Non évalué',
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: besoin['satisfait'] == true ? Colors.green :
                     besoin['satisfait'] == false ? Colors.orange : Colors.grey,
    ),
    subtitle: besoin['satisfait'] == false && besoin['commentaire'] != null
        ? Text(besoin['commentaire'], style: TextStyle(fontSize: 12))
        : null,
  );
}
 Widget _buildCarePlanSection(String infermierId) {
  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection('Patients')
        .doc(widget.patientId)
        .collection('DossierMedical')
        .doc('plan_soins_actuel')
        .snapshots(),


    builder: (context, snapshot) {
  if (snapshot.connectionState == ConnectionState.waiting) {
    return _buildLoadingCard();
  }

  if (!snapshot.hasData || !snapshot.data!.exists) {
    return _buildNoDataCard('Plan de Soins Actuel');
  }

  try {
    final data = snapshot.data!.data() as Map<String, dynamic>;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          _buildSectionHeader(
            'Plan de Soins Actuel',
            'plan_soins_actuel',
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPlanSoins(
                    patientId: widget.patientId,
                    initialData: Map<String, dynamic>.from(data),
                  ),
                ),
              );
            },
          ),
          if (_expandedSections['plan_soins_actuel']!) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildCarePlanContent(data),
            ),
          ],
        ],
      ),
    );
  } catch (e) {
    debugPrint('Erreur d\'affichage du plan de soins: $e');
    return _buildNoDataCard('Erreur de chargement du plan de soins');
  }
},

  );
}

Widget _buildCarePlanContent(Map<String, dynamic> data) {
  final List<Map<String, dynamic>> besoins = [];
  
  if (data['besoins'] is List) {
    for (var item in data['besoins']) {
      if (item is Map<String, dynamic>) {
        besoins.add(item);
      }
    }
  }

  return Column(
    children: [
      _buildInfoRow('Statut', data['statut']?.toString() ?? '', isHeader: true),
      _buildInfoRow(
        'Date création',
        data['dateCreation'] != null 
            ? _formatTimestamp(data['dateCreation'])
            : 'Non spécifiée',
      ),
      _buildInfoRow(
        'Dernière modification',
        data['derniereModification'] != null
            ? _formatTimestamp(data['derniereModification'])
            : 'Non spécifiée',
      ),
      const Divider(),
      ...besoins.map((besoin) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              besoin['nom']?.toString() ?? 'Nom non spécifié',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            _buildInfoRow('Objectif', besoin['objectif']?.toString() ?? ''),
            
            if (besoin['interventions'] is List && 
                (besoin['interventions'] as List).isNotEmpty) ...[
              const Text(
                'Interventions:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              ...(besoin['interventions'] as List).map(
                (intervention) => Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text('- ${intervention?.toString() ?? ''}'),
                ),
              ).toList(),
            ],
            
            _buildInfoRow('Évaluation', besoin['evaluation']?.toString() ?? ''),
            _buildInfoRow('Commentaire', besoin['commentaire']?.toString() ?? ''),
            const Divider(),
          ],
        );
      }).toList(),
    ],
  );
}

  Widget _buildHandoverSection(String infermierId) {
    return FutureBuilder<QuerySnapshot>(
      future:
          FirebaseFirestore.instance
              .collection('Patients')
              .doc(widget.patientId)
              .collection('DossierMedical')
              .doc('passation')
              .collection('Soins')
              .orderBy('date', descending: true)
              .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildNoDataCard('Passation');
        }
        final latestHandover =
            snapshot.data!.docs.first.data() as Map<String, dynamic>;

  return Card(
  elevation: 3,
  margin: const EdgeInsets.only(bottom: 16),
  child: Column(
    children: [
      _buildSectionHeader(
        'Passation',
        'passation',
        onEdit: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditPassationPage(
                patientId: widget.patientId,
                initialData: latestHandover,
              ),
            ),
          );
        },
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
            tooltip: 'Exporter tous les soins en PDF',
            onPressed: () {
              generateAllSoinsPdf(snapshot.data!.docs);
            },
          ),
        ],
      ),
      if (_expandedSections['passation']!) ...[
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final soinsList = data['soins'] as List<dynamic>? ?? [];

              return ExpansionTile(
                title: Text(
                  _formatTimestamp(data['date']),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Infirmier: ${data['infirmier'] ?? ''}'),
                    Text('Passation à: ${data['transmisA'] ?? ''}'),
                  ],
                ),
                children: [
                  if (data['observation'] != null &&
                      data['observation'].toString().isNotEmpty)
                    ListTile(
                      title: Text(
                        'Observation: ${data['observation']}',
                      ),
                    ),
                  if (soinsList.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: soinsList.map((soin) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: Text('- $soin'),
                        );
                      }).toList(),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    ],
  ),
);
      },
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildNoDataCard(String sectionTitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('$sectionTitle : Aucune donnée disponible'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String infermierId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
        'Dossier Médical',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPersonalInfoSection(infermierId),
            _buildGeneralInfoSection(infermierId),
            _buildClinicalExamSection(infermierId),
            _buildNeedsSection(infermierId),
            _buildCarePlanSection(infermierId),
            _buildHandoverSection(infermierId),
          ],
        ),
      ),
    );
  }
}
