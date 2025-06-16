import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class EditBesoins extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic> initialData;

  const EditBesoins({Key? key, required this.patientId, required this.initialData}) : super(key: key);

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
    // Initialisation des contrôleurs
    for (var besoin in _besoins) {
      _evaluationBesoins[besoin.id] = null;
      _commentairesControllers[besoin.id] = TextEditingController();
    }

    // Pré-remplissage avec les données existantes
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
    _commentairesControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _enregistrerEvaluation() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      Map<String, dynamic> evaluationData = {
        'dateEvaluation': FieldValue.serverTimestamp(),
        'infirmier': user.displayName ?? user.email,
        'besoins': _besoins.map((besoin) {
          return {
            'id': besoin.id,
            'nom': besoin.nom,
            'satisfait': _evaluationBesoins[besoin.id],
            'commentaire': _commentairesControllers[besoin.id]?.text,
          };
        }).toList(),
      };

      

      // Mise à jour de la dernière évaluation (sans écraser l'historique)
      await FirebaseFirestore.instance
          .collection('Patients')
          .doc(widget.patientId)
          .collection('DossierMedical')
          .doc('14_besoins')
          .set({
            'derniereEvaluation': evaluationData,
            'dateDerniereModification': FieldValue.serverTimestamp()
          }, SetOptions(merge: true));

      _genererPlanDeSoins();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Évaluation enregistrée avec succès'),
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

  void _genererPlanDeSoins() {
    final besoinsNonSatisfaits = _besoins.where((besoin) => _evaluationBesoins[besoin.id] == false).toList();

    if (besoinsNonSatisfaits.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Aucun besoin non satisfait'),
          content: const Text('Tous les besoins semblent satisfaits. Souhaitez-vous tout de même créer un plan de soins?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Non'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _afficherPlanDeSoins([]);
              },
              child: const Text('Oui'),
            ),
          ],
        ),
      );
    } else {
      _afficherPlanDeSoins(besoinsNonSatisfaits);
    }
  }

  void _afficherPlanDeSoins(List<Besoin> besoinsNonSatisfaits) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPlanSoins(
          patientId: widget.patientId,
          besoinsNonSatisfaits: besoinsNonSatisfaits,
          initialData: widget.initialData,
        ),
      ),
    );
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
        title: const Text('Évaluation des 14 besoins'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade700, Colors.teal.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
            const Text(
              'Étape 1: Évaluation clinique - Cochez les besoins non satisfaits',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._besoins.map((besoin) => _buildBesoinCard(besoin)).toList(),
            const SizedBox(height: 24),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _enregistrerEvaluation,
                      child: const Text('Enregistrer les modifications et générer un plan de soin'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class EditPlanSoins extends StatefulWidget {
  final String patientId;
  final List<Besoin> besoinsNonSatisfaits;
  final Map<String, dynamic> initialData;

  const EditPlanSoins({
    Key? key,
    required this.patientId,
    required this.besoinsNonSatisfaits,
    required this.initialData,
  }) : super(key: key);

  @override
  _EditPlanSoinsState createState() => _EditPlanSoinsState();
}

class _EditPlanSoinsState extends State<EditPlanSoins> {
  final Map<int, TextEditingController> _objectifsControllers = {};
  final Map<int, TextEditingController> _commentairesControllers = {};
  final Map<int, List<String>> _interventionsSelectionnees = {};
  final Map<int, String?> _evaluations = {};

  final Map<String, List<String>> _interventionsParBesoin = {
    'Respirer': [
      'Surveillance respiratoire',
      'Oxygénothérapie',
      'Kinésithérapie respiratoire',
    ],
    'Boire et manger': [
      'Aide à l\'alimentation',
      'Adaptation des repas',
      'Surveillance hydrique',
    ],
    'Éliminer': [
      'Gestion de la constipation',
      'Surveillance diurèse',
      'Toilettage intime',
    ],
    'Dormir et se reposer': [
      'Amélioration du sommeil',
      'Relaxation',
      'Adaptation environnement',
    ],
    'Se mouvoir et maintenir une bonne posture et maintenir une circulation sanguine adéquate': [
      'Thérapie de la marche',
      'Mobilisation',
      'Prévention escarres',
    ],
    'Se vêtir et se dévêtir': ['Aide à l\'habillage', 'Adaptation vêtements'],
    'Maintenir la température corporelle': [
      'Surveillance température',
      'Couvertures adaptées',
    ],
    'Être propre, soigné et protéger ses téguments': [
      'Toilette complète',
      'Soins de peau',
      'Prévention escarres',
    ],
    'Éviter les dangers': ['Prévention chutes', 'Environnement sécurisé'],
    'Communiquer avec ses semblables': ['Stimulation communication', 'Aides techniques'],
    'Agir selon ses croyances et ses valeurs': [
      'Respect des croyances',
      'Accompagnement spirituel',
    ],
    'S\'occuper en vue de se réaliser': [
      'Activités adaptées',
      'Stimulation cognitive',
    ],
    'Se divertir, Se récréer': ['Activités ludiques', 'Sorties'],
    'Apprendre': ['Éducation thérapeutique', 'Information patient'],
  };

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    // Initialisation avec données existantes ou valeurs par défaut
    for (var besoin in widget.besoinsNonSatisfaits) {
      _objectifsControllers[besoin.id] = TextEditingController();
      _commentairesControllers[besoin.id] = TextEditingController();
      _interventionsSelectionnees[besoin.id] = [];
      _evaluations[besoin.id] = null;
    }

    // Pré-remplissage avec les données existantes
    if (widget.initialData['besoins'] != null) {
      final List<dynamic> besoinsData = widget.initialData['besoins'];
      for (var besoinData in besoinsData) {
        final int besoinId = besoinData['id'];
        _objectifsControllers[besoinId]?.text = besoinData['objectif'] ?? '';
        _interventionsSelectionnees[besoinId] = 
            List<String>.from(besoinData['interventions'] ?? []);
        _evaluations[besoinId] = besoinData['evaluation'];
        _commentairesControllers[besoinId]?.text = besoinData['commentaire'] ?? '';
      }
    }
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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final planDeSoinsData = _preparePlanDeSoinsData();

      // Enregistrement dans l'historique
      await FirebaseFirestore.instance
          .collection('Patients')
          .doc(widget.patientId)
          .collection('DossierMedical')
          .doc('plans_de_soins')
          .collection('historique')
          .add(planDeSoinsData);

      // Mise à jour du plan actuel (sans écraser l'historique)
      await FirebaseFirestore.instance
          .collection('Patients')
          .doc(widget.patientId)
          .collection('DossierMedical')
          .doc('plan_de_soins_actuel')
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
    for (var besoin in widget.besoinsNonSatisfaits) {
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

  Map<String, dynamic> _preparePlanDeSoinsData() {
    final user = FirebaseAuth.instance.currentUser;
    
    return {
      'dateCreation': FieldValue.serverTimestamp(),
      'derniereModification': FieldValue.serverTimestamp(),
      'infirmier': user?.displayName ?? user?.email,
      'statut': 'actif',
      'besoins': widget.besoinsNonSatisfaits.map((besoin) {
        return {
          'id': besoin.id,
          'nom': besoin.nom,
          'objectif': _objectifsControllers[besoin.id]?.text,
          'interventions': _interventionsSelectionnees[besoin.id],
          'evaluation': _evaluations[besoin.id],
          'commentaire': _commentairesControllers[besoin.id]?.text,
        };
      }).toList(),
    };
  }

  Widget _buildTableauSoins(Besoin besoin) {
    final interventions = _interventionsParBesoin[besoin.nom] ?? [];
    final diagnostics = _getDiagnosticsForBesoin(besoin.nom);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              besoin.nom,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return _buildMobileLayout(besoin, interventions, diagnostics);
                } else {
                  return _buildDesktopLayout(besoin, interventions, diagnostics);
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentairesControllers[besoin.id],
              decoration: InputDecoration(
                labelText: 'Commentaires pour ${besoin.nom}',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    Besoin besoin,
    List<String> interventions,
    List<String> diagnostics,
  ) {
    return Column(
      children: [
        _buildMobileSection(
          'Diagnostics',
          diagnostics.map((d) => Text(d)).toList(),
        ),
        const SizedBox(height: 12),
        _buildMobileSection('Objectif', [
          TextField(
            controller: _objectifsControllers[besoin.id],
            decoration: InputDecoration(
              hintText: 'Objectif pour ${besoin.nom}',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            maxLines: 3,
          ),
        ]),
        const SizedBox(height: 12),
        _buildMobileSection('Interventions', [
          ...interventions.map((intervention) {
            return CheckboxListTile(
              title: Text(intervention),
              value: _interventionsSelectionnees[besoin.id]!.contains(intervention),
              onChanged: (selected) {
                setState(() {
                  if (selected == true) {
                    _interventionsSelectionnees[besoin.id]!.add(intervention);
                  } else {
                    _interventionsSelectionnees[besoin.id]!.remove(intervention);
                  }
                });
              },
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
            );
          }).toList(),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Ajouter une intervention personnalisée',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  _interventionsSelectionnees[besoin.id]!.add(value);
                });
              }
            },
          ),
        ]),
        const SizedBox(height: 12),
        _buildMobileSection('Évaluation', [
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
        ]),
      ],
    );
  }

  Widget _buildDesktopLayout(
    Besoin besoin,
    List<String> interventions,
    List<String> diagnostics,
  ) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...diagnostics.map((diagnostic) => Text('- $diagnostic')).toList(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: _objectifsControllers[besoin.id],
                decoration: InputDecoration(
                  hintText: 'Objectif pour ${besoin.nom}',
                  border: InputBorder.none,
                ),
                maxLines: 3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  ...interventions.map((intervention) {
                    return CheckboxListTile(
                      title: Text(intervention),
                      value: _interventionsSelectionnees[besoin.id]!.contains(intervention),
                      onChanged: (selected) {
                        setState(() {
                          if (selected == true) {
                            _interventionsSelectionnees[besoin.id]!.add(intervention);
                          } else {
                            _interventionsSelectionnees[besoin.id]!.remove(intervention);
                          }
                        });
                      },
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Ajouter une intervention personnalisée',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          _interventionsSelectionnees[besoin.id]!.add(value);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
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
              ),
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

  List<String> _getDiagnosticsForBesoin(String nomBesoin) {
    switch (nomBesoin) {
      case 'Respirer': return ['Mode de respiration inefficace'];
      case 'Boire et manger': return ['Alimentation déficiente'];
      case 'Éliminer': return ['Constipation', 'Rétention urinaire'];
      case 'Dormir et se reposer': return ['Habitudes de sommeil perturbé'];
      case 'Se mouvoir et maintenir une bonne posture': return ['Mobilité physique réduite'];
      case 'Se vêtir et se dévêtir': return ['Déficit des soins personnels'];
      case 'Maintenir la température corporelle': return ['Risque d\'hypothermie/hyperthermie'];
      case 'Être propre, soigné et protéger ses téguments': return ['Risque d''atteinte à l''intégrité de la peau'];
      case 'Éviter les dangers': return ['Risque de chute'];
      case 'Communiquer avec ses semblables': return ['Motivation à ameliorer sa communication'];
      case 'Agir selon ses croyances et ses valeurs': return ['Motivation à ameliorer son bien-etre spirtuel'];
      case 'S\'occuper en vue de se réaliser': return ['Exercice inefficace du role'];
      case 'Se divertir, Se récréer': return ['Diminution de l''implication dans des activités de loisirs'];
      case 'Apprendre': return ['Motivation à améliorer ses connaissances'];  
      default: return ['Diagnostic à définir'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan de soins individualisé'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade700, Colors.teal.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Plan de soins individualisé',
              style: TextStyle(
                color: Colors.teal.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            if (widget.besoinsNonSatisfaits.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Aucun besoin non satisfait identifié'),
                ),
              )
            else
              ...widget.besoinsNonSatisfaits
                  .map((besoin) => _buildTableauSoins(besoin))
                  .toList(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Retour'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    backgroundColor: Colors.grey,
                  ),
                ),
                ElevatedButton(
                  onPressed: _enregistrerPlanDeSoins,
                  child: const Text('Enregistrer les modifications'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    backgroundColor: Colors.teal.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
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