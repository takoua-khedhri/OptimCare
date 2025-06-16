import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditPlanSoins extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic> initialData;

  const EditPlanSoins({
    Key? key,
    required this.patientId,
    required this.initialData,
  }) : super(key: key);

  @override
  _EditPlanSoinsState createState() => _EditPlanSoinsState();
}

class _EditPlanSoinsState extends State<EditPlanSoins> {
  final Map<int, TextEditingController> _commentairesControllers = {};
  final Map<int, String?> _evaluations = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    try {
      if (widget.initialData.containsKey('besoins') && 
          widget.initialData['besoins'] is List) {
        
        final List<dynamic> besoinsData = widget.initialData['besoins'];
        
        for (var besoinData in besoinsData) {
          if (besoinData is Map<String, dynamic> && 
              besoinData.containsKey('id') && 
              besoinData['id'] is int) {
            
            final int besoinId = besoinData['id'];
            
            _commentairesControllers[besoinId] = TextEditingController(
              text: besoinData['commentaire']?.toString() ?? '',
            );
            
            _evaluations[besoinId] = besoinData['evaluation']?.toString();
          }
        }
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation: $e');
    }
  }

  @override
  void dispose() {
    _commentairesControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _enregistrerModifications() async {
    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Vérification que les données initiales contiennent bien 'besoins'
      if (!widget.initialData.containsKey('besoins')) {
        throw Exception('Données initiales invalides: champ "besoins" manquant');
      }

      // Préparation des données à mettre à jour
      final List<dynamic> updatedBesoins = [];
      
      for (var besoin in widget.initialData['besoins']) {
        if (besoin is Map<String, dynamic> && besoin.containsKey('id')) {
          final int besoinId = besoin['id'] as int;
          
          updatedBesoins.add({
            'id': besoinId,
            'nom': besoin['nom']?.toString() ?? '',
            'objectif': besoin['objectif']?.toString() ?? '',
            'interventions': besoin['interventions'] is List 
                ? List<String>.from(besoin['interventions'].map((x) => x.toString()))
                : <String>[],
            'evaluation': _evaluations[besoinId] ?? '',
            'commentaire': _commentairesControllers[besoinId]?.text ?? '',
          });
        }
      }

      final updatedData = {
        'derniereModification': FieldValue.serverTimestamp(),
        'infirmier': user.displayName ?? user.email,
        'besoins': updatedBesoins,
      };

      await FirebaseFirestore.instance
          .collection('Patients')
          .doc(widget.patientId)
          .collection('DossierMedical')
          .doc('plan_soins_actuel')
          .update(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Évaluations mises à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildBesoinCard(Map<String, dynamic> besoin) {
    final int besoinId = besoin['id'] as int;
    final String currentEvaluation = _evaluations[besoinId] ?? '';

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
              besoin['nom']?.toString() ?? 'Nom non spécifié',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Objectif: ${besoin['objectif']?.toString() ?? 'Non spécifié'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (besoin['interventions'] is List && (besoin['interventions'] as List).isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Interventions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...(besoin['interventions'] as List).map<Widget>((intervention) {
                    return Text('- ${intervention?.toString() ?? ''}');
                  }).toList(),
                  const SizedBox(height: 12),
                ],
              ),
            const Text(
              'Évaluation actuelle:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Column(
              children: ['En cours', 'Amélioration', 'Stagnation', 'Aggravation'].map((value) {
                return RadioListTile<String>(
                  title: Text(value),
                  value: value,
                  groupValue: currentEvaluation,
                  onChanged: (newValue) {
                    setState(() {
                      _evaluations[besoinId] = newValue;
                    });
                  },
                  dense: true,
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentairesControllers[besoinId],
              decoration: InputDecoration(
                labelText: 'Commentaires',
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

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> besoins = [];
    
    if (widget.initialData['besoins'] is List) {
      for (var item in widget.initialData['besoins']) {
        if (item is Map<String, dynamic>) {
          besoins.add(item);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Plan de Soins',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (besoins.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Aucun plan de soins trouvé'),
                ),
              )
            else
              ...besoins.map((besoin) => _buildBesoinCard(besoin)).toList(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _enregistrerModifications,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
              ),
              child: _isSaving
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(width: 12),
                        Text('Enregistrement...'),
                      ],
                    )
                  : const Text('Enregistrer la modification'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}