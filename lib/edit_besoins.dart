import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Page d'évaluation des besoins
class EditBesoins extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic> initialData;

  const EditBesoins({
    Key? key,
    required this.patientId,
    required this.initialData,
  }) : super(key: key);

  @override
  _EditBesoinsState createState() => _EditBesoinsState();
}

class _EditBesoinsState extends State<EditBesoins> {
  final List<Besoin> _besoins = [
    Besoin(id: 1, nom: "Respirer"),
    Besoin(id: 2, nom: "Boire et manger"),
    Besoin(id: 3, nom: "Éliminer"),
    Besoin(id: 4, nom: "Se mouvoir et maintenir une bonne posture et maintenir une circulation sanguine adéquate"),
    Besoin(id: 5, nom: "Dormir et se reposer"),
    Besoin(id: 6, nom: "Se vêtir et se dévêtir"),
    Besoin(id: 7, nom: "Maintenir la température corporelle"),
    Besoin(id: 8, nom: "Être propre, soigné et protéger ses téguments"),
    Besoin(id: 9, nom: "Éviter les dangers"),
    Besoin(id: 10, nom: "Communiquer avec ses semblables"),
    Besoin(id: 11, nom: "Agir selon ses croyances et ses valeurs"),
    Besoin(id: 12, nom: "S'occuper en vue de se réaliser"),
    Besoin(id: 13, nom: "Se divertir, Se récréer"),
    Besoin(id: 14, nom: "Apprendre"),
  ];

  final Map<int, bool?> _evaluationBesoins = {};
  final Map<int, TextEditingController> _commentairesControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    for (var besoin in _besoins) {
      _evaluationBesoins[besoin.id] = null;
      _commentairesControllers[besoin.id] = TextEditingController();
    }
    if (widget.initialData['besoins'] != null) {
      final List<dynamic> besoinsData = widget.initialData['besoins'];
      for (var besoinData in besoinsData) {
        final int besoinId = besoinData['id'];
        _evaluationBesoins[besoinId] = besoinData['satisfait'];
        _commentairesControllers[besoinId]?.text = besoinData['commentaire'] ?? '';
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _commentairesControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _enregistrerEvaluation() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final besoinsData = _besoins.map((besoin) {
        return {
          'id': besoin.id,
          'nom': besoin.nom,
          'satisfait': _evaluationBesoins[besoin.id],
          'commentaire': _commentairesControllers[besoin.id]?.text ?? '',
        };
      }).toList();

      final dataToSave = {
        'besoins': besoinsData,
        'derniereEvaluation': {
          'dateEvaluation': FieldValue.serverTimestamp(),
          'infirmier': user.displayName ?? user.email,
          'besoins': besoinsData,
        },
        'dateDerniereModification': FieldValue.serverTimestamp(),
      };

      final docRef = FirebaseFirestore.instance
          .collection('Patients')
          .doc(widget.patientId)
          .collection('DossierMedical')
          .doc('14_besoins');

      await docRef.set(dataToSave, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Évaluation enregistrée avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      await _genererPlanDeSoins();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'enregistrement: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _genererPlanDeSoins() async {
    final besoinsActuelsNonSatisfaits = _besoins
        .where((besoin) => _evaluationBesoins[besoin.id] == false)
        .toList();

    if (besoinsActuelsNonSatisfaits.isEmpty) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Aucun besoin non satisfait'),
          content: const Text('Tous les besoins sont maintenant satisfaits.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('Patients')
          .doc(widget.patientId)
          .collection('DossierMedical')
          .doc('plan_soins_actuel')
          .get();

      List<dynamic>? allExistingData;
      if (docSnapshot.exists) {
        allExistingData = docSnapshot.data()?['besoins'] as List<dynamic>?;
      }

      if (!mounted) return;
     Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PlanDeSoinsPage(
      patientId: widget.patientId,
      besoinsNonSatisfaits: besoinsActuelsNonSatisfaits,
      existingBesoinsData: allExistingData ?? [], // Correction ici
    ),
  ),
);
    }
  }

  Widget _buildBesoinCard(Besoin besoin) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${besoin.id}. ${besoin.nom}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Row(
                  children: [
                    _buildEvaluationButton(besoin.id, true),
                    const SizedBox(width: 8),
                    _buildEvaluationButton(besoin.id, false),
                  ],
                ),
              ],
            ),
            if (_evaluationBesoins[besoin.id] == false) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _commentairesControllers[besoin.id],
                decoration: InputDecoration(
                  labelText: 'Observations cliniques',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                maxLines: 2,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEvaluationButton(int besoinId, bool satisfait) {
    return ChoiceChip(
      label: Text(satisfait ? 'Satisfait' : 'Non satisfait'),
      selected: _evaluationBesoins[besoinId] == satisfait,
      selectedColor: satisfait ? Colors.green : Colors.orange,
      labelStyle: TextStyle(
        color: _evaluationBesoins[besoinId] == satisfait ? Colors.white : null,
      ),
      onSelected: (selected) {
        setState(() {
          _evaluationBesoins[besoinId] = selected ? satisfait : null;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Évaluation des 14 besoins fondamentaux',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Évaluation des 14 besoins fondamentaux',
              style: TextStyle(
                color: Colors.teal.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Virginia Henderson',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ..._besoins.map((besoin) => _buildBesoinCard(besoin)).toList(),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _enregistrerEvaluation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                ),
                child: const Text('Enregistrer la modification et générer un plan de soin'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

//classe plan de soins 

class PlanDeSoinsPage extends StatefulWidget {
  final String patientId;
  final List<Besoin> besoinsNonSatisfaits;
  final List<dynamic> existingBesoinsData; // Nom clair et cohérent

  const PlanDeSoinsPage({
    Key? key,
    required this.patientId,
    required this.besoinsNonSatisfaits,
    required this.existingBesoinsData, // Même nom partout
  }) : super(key: key);

  @override
  _PlanDeSoinsPageState createState() => _PlanDeSoinsPageState();
}

class _PlanDeSoinsPageState extends State<PlanDeSoinsPage> {
  final Map<int, TextEditingController> _objectifsControllers = {};
  final Map<int, TextEditingController> _commentairesControllers = {};
  final Map<int, List<String>> _interventionsSelectionnees = {};
  final Map<int, String?> _evaluations = {};
  final Map<int, bool> _usingCustomObjective = {};
  final Map<int, List<String>> _diagnosticsSelectionnes = {};
  late List<Besoin> _orderedBesoins;
  Besoin? _draggedBesoin;

  final Map<String, List<String>> _interventionsParDiagnostic = {
    'Mode de respiration inefficace': [
      'Surveillance respiratoire',
      'Assistance à la ventilation',
      'Position semi-Fowler',
    ],
    'Respiration spontanée altérée': [
      'Sevrage de l\'assistance respiratoire',
      'Surveillance neurologique',
      'Evaluation de la tolérance à l\'effort',
    ],
    'Alimentation déficiente': [
      'Aide à l\'alimentation',
      'Surveillance de l\'alimentation',
      'Education nutritionnelle',
    ],
    'Troubles de la déglutition': [
      'Surveillance de la déglutition',
      'Modifications de texture des aliments',
      'Positionnement',
    ],
    'Constipation': [
      'Gestion de la constipation',
      'Encouragement à l\'hydratation',
      'Conseil diététique : fibres alimentaires',
    ],
    'Diarrhée': [
      'Surveillance du transit intestinal',
      'Gestion de la diarrhée',
      'Surveillance des signes de déshydratation',
    ],
    'Habitudes de sommeil perturbé': [
      'Amélioration du sommeil',
      'Réduction des stimuli environnementaux',
      'Enseignement des techniques de relaxation',
    ],
    'Insomnie': [
      'Thérapie du sommeil',
      'Gestion de l\'environnement',
      'Surveillance du sommeil',
    ],
    'Mobilité physique réduite': [
      'Thérapie de la marche',
      'Assistance au transfert',
      'Programme d\'exercice de mobilité',
    ],
    'Mobilité réduite au fauteuil roulant': [
      'Renforcement de la mobilité',
      'Entrainement à l\'autonomie',
      'Surveillance du risque de lésion cutanée',
    ],
    'Déficit des soins personnels': [
      'Aide à l\'habillage', 
      'Adaptation vêtements'
    ],
    'Risque d\'hypothermie/hyperthermie': [
      'Surveillance température',
      'Couvertures adaptées',
    ],
    'Risque d''atteinte à l''intégrité de la peau': [
      'Toilette complète',
      'Soins de peau',
      'Prévention escarres',
    ],
    'Risque de chute': [
      'Prévention chutes', 
      'Environnement sécurisé'
    ],
    'Motivation à ameliorer sa communication': [
      'Stimulation communication', 
      'Aides techniques'
    ],
    'Motivation à ameliorer son bien-etre spirtuel': [
      'Respect des croyances',
      'Accompagnement spirituel',
    ],
    'Exercice inefficace du role': [
      'Activités adaptées',
      'Stimulation cognitive',
    ],
    'Diminution de l''implication dans des activités de loisirs': [
      'Activités ludiques', 
      'Sorties'
    ],
    'Motivation à améliorer ses connaissances': [
      'Éducation thérapeutique', 
      'Information patient'
    ],
  };

 @override
void initState() {
  super.initState();
  _orderedBesoins = List.from(widget.besoinsNonSatisfaits);
    
  // Initialiser les contrôleurs et les maps
  for (var besoin in _orderedBesoins) {
    _objectifsControllers[besoin.id] = TextEditingController();
    _commentairesControllers[besoin.id] = TextEditingController();
    _interventionsSelectionnees[besoin.id] = [];
    _evaluations[besoin.id] = null;
    _usingCustomObjective[besoin.id] = false;
    _diagnosticsSelectionnes[besoin.id] = [];
  }

  _loadExistingPlanData();
}

 void _loadExistingPlanData() {
  if (widget.existingBesoinsData.isEmpty) return;

  for (var besoinData in widget.existingBesoinsData) {
    if (besoinData is! Map<String, dynamic>) continue;
    
    final besoinId = besoinData['id'] as int?;
    if (besoinId == null) continue;

    final besoinIndex = _orderedBesoins.indexWhere((b) => b.id == besoinId);
    if (besoinIndex == -1) continue;

    // Chargement des diagnostics
    if (besoinData['diagnostics'] is List) {
      _diagnosticsSelectionnes[besoinId] = 
          List<String>.from(besoinData['diagnostics'].whereType<String>());
    }
    
    // Chargement de l'objectif
    if (besoinData['objectif'] is String) {
      _objectifsControllers[besoinId]?.text = besoinData['objectif'];
      final diagnostics = _diagnosticsSelectionnes[besoinId] ?? [];
      final allObjectives = diagnostics
          .expand((diagnostic) => _getObjectifForDiagnostic(diagnostic))
          .toList();
      
      _usingCustomObjective[besoinId] = !allObjectives.contains(besoinData['objectif']);
    }
    
    // Chargement des interventions
    if (besoinData['interventions'] is List) {
      _interventionsSelectionnees[besoinId] = 
          List<String>.from(besoinData['interventions'].whereType<String>());
    }
    
    // Chargement de l'évaluation
    if (besoinData['evaluation'] is String) {
      _evaluations[besoinId] = besoinData['evaluation'];
    }
    
    // Chargement des commentaires
    if (besoinData['commentaire'] is String) {
      _commentairesControllers[besoinId]?.text = besoinData['commentaire'];
    }
  }
}

  List<String> _getDiagnosticsForBesoin(String nomBesoin) {
    switch (nomBesoin) {
      case 'Respirer':
        return [
          'Mode de respiration inefficace',
          'Respiration spontanée altérée',
        ];
      case 'Boire et manger':
        return ['Alimentation déficiente', 'Troubles de la déglutition'];
      case 'Éliminer':
        return ['Constipation', 'Diarrhée'];
      case 'Dormir et se reposer':
        return ['Habitudes de sommeil perturbé', 'Insomnie'];
      case 'Se mouvoir et maintenir une bonne posture et maintenir une circulation sanguine adéquate':
        return [
          'Mobilité physique réduite',
          'Mobilité réduite au fauteuil roulant',
        ];
      case 'Se vêtir et se dévêtir':
        return ['Dépendance pour l\'habillage'];
      case 'Maintenir la température corporelle':
        return ['Risque d\'hypothermie/hyperthermie'];
      case 'Être propre, soigné et protéger ses téguments':
        return ['Risque d\'escarres'];
      case 'Éviter les dangers':
        return ['Risque de chute'];
      case 'Communiquer avec ses semblables':
        return ['Difficultés de communication'];
      case 'Agir selon ses croyances et ses valeurs':
        return ['Besoins spirituels non satisfaits'];
      case 'S\'occuper en vue de se réaliser':
        return ['Manque d\'activités stimulantes'];
      case 'Se divertir, Se récréer':
        return ['Manque de loisirs adaptés'];
      case 'Apprendre':
        return ['Motivation à améliorer ses connaissances'];
      default:
        return ['Diagnostic à définir'];
    }
  }

  List<String> _getObjectifForDiagnostic(String diagnostic) {
    switch (diagnostic) {
      case 'Mode de respiration inefficace':
        return ['maintiendra une fréquence respiratoire entre 12 et 20/min dans les 24h.'];
      case 'Respiration spontanée altérée':
        return ['respirera de manière autonome sans assistance dans les 48h.'];
      case 'Alimentation déficiente':
        return ['ingérera ≥ 75% de ses repas pendant 2 jours consécutifs.'];
      case 'Troubles de la déglutition':
        return ['s\'alimentera sans épisodes de fausse route pendant 48h.'];
      case 'Constipation':
        return ['aura une élimination intestinale régulière dans les 3 jours'];
      case 'Diarrhée':
        return ['aura un transit intestinal stabilisé dans les 48h'];
      case 'Habitudes de sommeil perturbé':
        return ['dormira 6 à 8 heures par nuit d\'ici 48h'];
      case 'Insomnie':
        return ['s\'endormira dans un délai de 30 minutes chaque nuit pendant 3 jours'];
      case 'Mobilité physique réduite':
        return ['marchera 20 mètres avec aide dans les 72h'];
      case 'Mobilité réduite au fauteuil roulant':
        return ['pourra se déplacer seule en fauteuil sur 10 mètres d\'ici 48h'];
        

      case 'Déficit des soins personnels':
        return [
          'pourra s\'habiller seul avec assistance minimale d\'ici 1 semaine',
          'utilisera des vêtements adaptés d\'ici 3 jours'
        ];
      case 'Risque d\'hypothermie/hyperthermie':
        return [
          'maintiendra une température entre 36.5°C et 37.5°C pendant 48h',
          'n\'aura pas d\'épisode d\'hypothermie/hyperthermie pendant 72h'
        ];
      case 'Risque d''atteinte à l''intégrité de la peau':
        return [
          'aura une peau intacte pendant toute la durée du séjour',
          'participera à sa toilette quotidienne d\'ici 3 jours'
        ];
      case 'Risque de chute':
        return [
          'n\'aura pas de chute pendant son séjour',
          'utilisera les aides techniques correctement d\'ici 48h'
        ];
      case 'Motivation à ameliorer sa communication':
        return [
          'exprimera ses besoins de manière compréhensible d\'ici 1 semaine',
          'utilisera un moyen de communication alternatif si nécessaire'
        ];
      case 'Motivation à ameliorer son bien-etre spirtuel':
        return [
          'pourra pratiquer ses rites religieux si désiré',
          'exprimera ses besoins spirituels'
        ];
      case 'Exercice inefficace du role':
        return [
          'participera à une activité adaptée quotidienne',
          'exprimera une satisfaction concernant ses activités'
        ];
      case 'Diminution de l''implication dans des activités de loisirs':
        return [
          'participera à au moins une activité de loisir par jour',
          'exprimera du plaisir lors des activités'
        ];
      case 'Motivation à améliorer ses connaissances':
        return [
          'démontrera la compréhension des enseignements reçus',
          'posera des questions sur sa condition si nécessaire'
        ];
      default:
        return [
          
        ];
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    setState(() {
      final Besoin item = _orderedBesoins.removeAt(oldIndex);
      _orderedBesoins.insert(newIndex, item);
    });
  }

  void _moveItem(Besoin draggedBesoin, int newIndex) {
    setState(() {
      final oldIndex = _orderedBesoins.indexWhere((b) => b.id == draggedBesoin.id);
      if (oldIndex != -1) {
        final item = _orderedBesoins.removeAt(oldIndex);
        final adjustedNewIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
        _orderedBesoins.insert(adjustedNewIndex, item);
      }
    });
  }

  @override
  void dispose() {
    _objectifsControllers.values.forEach((controller) => controller.dispose());
    _commentairesControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _enregistrerPlanDeSoins() async {
    if (!_validateForm()) return;

    try {
      final planDeSoinsData = {
       // 'dateCreation': widget.existingBesoinsData?['dateCreation'] ?? FieldValue.serverTimestamp(),
        'derniereModification': FieldValue.serverTimestamp(),
        'statut': 'actif',
        'besoins': _orderedBesoins.map((besoin) {
          return {
            'id': besoin.id,
            'nom': besoin.nom,
            'diagnostics': _diagnosticsSelectionnes[besoin.id],
            'objectif': _objectifsControllers[besoin.id]?.text,
            'interventions': _interventionsSelectionnees[besoin.id],
            'evaluation': _evaluations[besoin.id],
            'commentaire': _commentairesControllers[besoin.id]?.text,
          };
        }).toList(),
      };

      await FirebaseFirestore.instance
          .collection('Patients')
          .doc(widget.patientId)
          .collection('DossierMedical')
          .doc('plan_soins_actuel')
          .set(planDeSoinsData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plan de soins enregistré avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'enregistrement: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _validateForm() {
    for (var besoin in _orderedBesoins) {
      if ((_diagnosticsSelectionnes[besoin.id]?.isEmpty ?? true)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veuillez sélectionner au moins un diagnostic pour ${besoin.nom}'),
            backgroundColor: Colors.orange,
          ),
        );
        return false;
      }

      if (_objectifsControllers[besoin.id]?.text.isEmpty ?? true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veuillez saisir un objectif pour ${besoin.nom}'),
            backgroundColor: Colors.orange,
          ),
        );
        return false;
      }

      if (_evaluations[besoin.id] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veuillez sélectionner une évaluation pour ${besoin.nom}'),
            backgroundColor: Colors.orange,
          ),
        );
        return false;
      }
    }
    return true;
  }

  Widget _buildObjectiveSection(Besoin besoin) {
    final selectedDiagnostics = _diagnosticsSelectionnes[besoin.id] ?? [];
    final allObjectives = selectedDiagnostics
        .expand((diagnostic) => _getObjectifForDiagnostic(diagnostic))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (allObjectives.isNotEmpty) ...[
          ...allObjectives.map((objectif) {
            return CheckboxListTile(
              title: Text(objectif),
              value: !_usingCustomObjective[besoin.id]! && 
                     _objectifsControllers[besoin.id]?.text == objectif,
              onChanged: (selected) {
                setState(() {
                  if (selected == true) {
                    _objectifsControllers[besoin.id]?.text = objectif;
                    _usingCustomObjective[besoin.id] = false;
                  } else if (!_usingCustomObjective[besoin.id]! && 
                             _objectifsControllers[besoin.id]?.text == objectif) {
                    _objectifsControllers[besoin.id]?.clear();
                  }
                });
              },
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
            );
          }).toList(),
        ],
        CheckboxListTile(
          title: const Text('Objectif personnalisé'),
          value: _usingCustomObjective[besoin.id]!,
          onChanged: (selected) {
            setState(() {
              _usingCustomObjective[besoin.id] = selected ?? false;
              if (selected == true) {
                _objectifsControllers[besoin.id]?.clear();
              }
            });
          },
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        if (_usingCustomObjective[besoin.id]!)
          TextField(
            controller: _objectifsControllers[besoin.id],
            decoration: const InputDecoration(
              hintText: 'Saisir votre objectif personnalisé',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            maxLines: 2,
            onChanged: (value) {
              setState(() {});
            },
          ),
      ],
    );
  }

  Widget _buildInterventionsSection(Besoin besoin) {
    final selectedDiagnostics = _diagnosticsSelectionnes[besoin.id] ?? [];
    final interventions = selectedDiagnostics
        .expand((diagnostic) => _interventionsParDiagnostic[diagnostic] ?? [])
        .toSet() // Pour éviter les doublons
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (interventions.isNotEmpty) ...[
          ...interventions.map((intervention) {
            return CheckboxListTile(
              title: Text(intervention),
              value: _interventionsSelectionnees[besoin.id]?.contains(intervention) ?? false,
              onChanged: (selected) {
                setState(() {
                  if (selected == true) {
                    _interventionsSelectionnees[besoin.id] ??= [];
                    _interventionsSelectionnees[besoin.id]!.add(intervention);
                  } else {
                    _interventionsSelectionnees[besoin.id]?.remove(intervention);
                  }
                });
              },
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
            );
          }).toList(),
        ],
        TextField(
          decoration: const InputDecoration(
            hintText: 'Ajouter une intervention personnalisée',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              setState(() {
                _interventionsSelectionnees[besoin.id] ??= [];
                _interventionsSelectionnees[besoin.id]!.add(value);
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildEvaluationSection(Besoin besoin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...['En cours', 'Amélioration', 'Stagnation', 'Aggravation'].map((value) {
          return RadioListTile<String>(
            title: Text(value),
            value: value,
            groupValue: _evaluations[besoin.id],
            onChanged: (value) {
              setState(() {
                _evaluations[besoin.id] = value;
              });
            },
            dense: true,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDiagnosticsSection(Besoin besoin) {
    final diagnostics = _getDiagnosticsForBesoin(besoin.nom);
    final selectedDiagnostics = _diagnosticsSelectionnes[besoin.id] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...diagnostics.map((diagnostic) {
          return CheckboxListTile(
            title: Text(diagnostic),
            value: selectedDiagnostics.contains(diagnostic),
            onChanged: (selected) {
              setState(() {
                if (selected == true) {
                  _diagnosticsSelectionnes[besoin.id] ??= [];
                  _diagnosticsSelectionnes[besoin.id]!.add(diagnostic);
                } else {
                  _diagnosticsSelectionnes[besoin.id]?.remove(diagnostic);
                }
              });
            },
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTableauContent(Besoin besoin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.drag_handle, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                besoin.nom,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.teal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return _buildMobileLayout(besoin);
            } else {
              return _buildDesktopLayout(besoin);
            }
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _commentairesControllers[besoin.id],
          decoration: InputDecoration(
            labelText: 'Commentaires pour ${besoin.nom}',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildMobileLayout(Besoin besoin) {
    return Column(
      children: [
        _buildMobileSection('Diagnostics', [_buildDiagnosticsSection(besoin)]),
        const SizedBox(height: 12),
        _buildMobileSection('Objectif', [_buildObjectiveSection(besoin)]),
        const SizedBox(height: 12),
        _buildMobileSection('Interventions', [_buildInterventionsSection(besoin)]),
        const SizedBox(height: 12),
        _buildMobileSection('Évaluation', [_buildEvaluationSection(besoin)]),
      ],
    );
  }

  Widget _buildDesktopLayout(Besoin besoin) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(3),
        3: FlexColumnWidth(2),
      },
      border: TableBorder.all(color: Colors.grey[300]!),
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[200]),
          children: const [
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Diagnostic infirmier',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Objectif (NOC)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Interventions (NIC)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Évaluation',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: _buildDiagnosticsSection(besoin),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: _buildObjectiveSection(besoin),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: _buildInterventionsSection(besoin),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: _buildEvaluationSection(besoin),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        ...children,
      ],
    );
  }

  Widget _buildTableauSoins(Besoin besoin) {
    return LongPressDraggable<Besoin>(
      data: besoin,
      feedback: Material(
        child: Card(
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: _buildTableauContent(besoin),
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: _buildTableauContent(besoin),
          ),
        ),
      ),
      onDragStarted: () {
        setState(() {
          _draggedBesoin = besoin;
        });
      },
      onDragCompleted: () {
        setState(() {
          _draggedBesoin = null;
        });
      },
      child: Card(
        key: ValueKey(besoin.id),
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: _buildTableauContent(besoin),
        ),
      ),
    );
  }

  Widget _buildDropZone(int index) {
    return DragTarget<Besoin>(
      builder: (context, candidateData, rejectedData) {
        return Container(
          height: 40,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty
                ? Colors.teal.withOpacity(0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
      onWillAccept: (data) => true,
      onAccept: (besoin) {
        if (_draggedBesoin != null) {
          _moveItem(besoin, index);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingBesoinsData != null 
              ? 'Modifier le plan de soins' 
              : 'Nouveau plan de soins',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade700,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: DragTarget<Besoin>(
          builder: (context, candidateData, rejectedData) {
            return Column(
              children: [
                const SizedBox(height: 16),
                if (_orderedBesoins.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Aucun besoin non satisfait identifié'),
                    ),
                  )
                else
                  ..._orderedBesoins.asMap().entries.map((entry) {
                    final index = entry.key;
                    final besoin = entry.value;
                    return Column(
                      children: [
                        _buildDropZone(index),
                        _buildTableauSoins(besoin),
                      ],
                    );
                  }).toList(),
                _buildDropZone(_orderedBesoins.length),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[600],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: MediaQuery.of(context).size.width < 400 ? 14 : 16,
                              horizontal: MediaQuery.of(context).size.width < 400 ? 12 : 24,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(
                            Icons.arrow_back,
                            size: MediaQuery.of(context).size.width < 400 ? 18 : 20,
                          ),
                          label: Text(
                            'Retour',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width < 400 ? 14 : 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _enregistrerPlanDeSoins();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal[700],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.width < 400 ? 14 : 16,
                            horizontal: MediaQuery.of(context).size.width < 400 ? 12 : 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(
                          Icons.save,
                          size: MediaQuery.of(context).size.width < 400 ? 18 : 20,
                        ),
                        label: Text(
                          'Enregistrer',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width < 400 ? 14 : 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            );
          },
          onAccept: (besoin) {},
        ),
      ),
    );
  }
}

class Besoin {
  final int id;
  final String nom;

  Besoin({required this.id, required this.nom});
}