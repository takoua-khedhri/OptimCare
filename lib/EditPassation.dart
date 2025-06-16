import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class EditPassationPage extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic> initialData;

  const EditPassationPage({
    Key? key, 
    required this.patientId,
    required this.initialData,
  }) : super(key: key);

  @override
  _EditPassationPageState createState() => _EditPassationPageState();
}

class _EditPassationPageState extends State<EditPassationPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Map<String, bool> _soinsRealises = {
    'Pansement': false,
    'Injection': false,
    'Perfusion': false,
    'Prise de sang': false,
    'Pose/surveillance de sonde urinaire': false,
    'Soins d\'hygiène': false,
    'Administration médicamenteuse': false,
    'Surveillance paramètres vitaux': false,
    'Vaccination': false,
    'Prélèvement biologique': false,
    'Toilette au lit': false,
    'Changement de position': false,
  };

  final TextEditingController _observationController = TextEditingController();
  final TextEditingController _autreSoinController = TextEditingController();
  final List<Map<String, dynamic>> _historiqueSoins = [];
  final _formKey = GlobalKey<FormState>();
  bool _aucunSoin = false;
  String? _transmettreA;
  List<Map<String, dynamic>> _personnelService = [];
  bool _chargementPersonnel = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _chargerPersonnelService();
  }

  void _initializeData() {
    _observationController.text = widget.initialData['observation'] ?? '';
    
    if (widget.initialData['soins'] != null) {
      final List<dynamic> soins = widget.initialData['soins'];
      
      if (soins.contains('Aucun soin à transmettre')) {
        _aucunSoin = true;
      } else {
        for (var soin in soins) {
          if (_soinsRealises.containsKey(soin)) {
            _soinsRealises[soin] = true;
          } else if (soin != 'Aucun soin à transmettre') {
            _autreSoinController.text = soin;
          }
        }
      }
    }

    if (widget.initialData['transmisA'] != null) {
      // Initialiser _transmettreA si disponible
      final nomTransmis = widget.initialData['transmisA'] as String;
      final personne = _personnelService.firstWhere(
        (p) => '${p['prenom']} ${p['nom']}' == nomTransmis,
        orElse: () => {'id': null},
      );
      if (personne['id'] != null) {
        _transmettreA = personne['id'];
      }
    }
  }

  Future<void> _chargerPersonnelService() async {
    setState(() => _chargementPersonnel = true);

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Récupérer le service de l'utilisateur
      final userDocInf = await _firestore.collection('Infermier').doc(user.uid).get();
      final userDocSup = await _firestore.collection('Superviseurs').doc(user.uid).get();

      String? userService;

      if (userDocInf.exists) {
        userService = userDocInf.data()?['service'];
      } else if (userDocSup.exists) {
        userService = userDocSup.data()?['service'];
      }

      if (userService == null) return;

      List<Map<String, dynamic>> personnel = [];

      // Charger le personnel infirmier
      final infSnapshot = await _firestore
          .collection('Infermier')
          .where('service', isEqualTo: userService)
          .get();

      personnel.addAll(infSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'nom': data['nom'] ?? 'Inconnu',
          'prenom': data['prenom'] ?? '',
          'role': 'infirmier',
        };
      }));

      // Charger les superviseurs
      final supSnapshot = await _firestore
          .collection('Superviseurs')
          .where('service', isEqualTo: userService)
          .get();

      personnel.addAll(supSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'nom': data['nom'] ?? 'Inconnu',
          'prenom': data['prenom'] ?? '',
          'role': 'superviseur',
        };
      }));

      setState(() {
        _personnelService = personnel;
      });
    } catch (e) {
      debugPrint('Erreur chargement personnel: $e');
    } finally {
      setState(() => _chargementPersonnel = false);
    }
  }

  @override
  void dispose() {
    _observationController.dispose();
    _autreSoinController.dispose();
    super.dispose();
  }

  Future<void> _enregistrerSoins() async {
    if (!_aucunSoin && !_soinsRealises.containsValue(true) && _autreSoinController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins un soin'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Utilisateur non connecté'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final soinsSelectionnes = _soinsRealises.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      if (_autreSoinController.text.isNotEmpty) {
        soinsSelectionnes.add(_autreSoinController.text);
      }

      // Récupérer le nom complet de la personne à qui transmettre
      final personneTransmise = _personnelService.firstWhere(
        (personne) => personne['id'] == _transmettreA,
        orElse: () => {'prenom': '', 'nom': 'Inconnu'},
      );
      final nomComplet = '${personneTransmise['prenom']} ${personneTransmise['nom']}';

      final soinData = {
        'date': FieldValue.serverTimestamp(),
        'infirmier': user.displayName ?? user.email ?? 'Infirmier inconnu',
        'soins': _aucunSoin ? ['Aucun soin à transmettre'] : soinsSelectionnes,
        'observation': _observationController.text,
        'patientId': widget.patientId,
        'transmisA': nomComplet,
      };

      await _firestore
          .collection('Patients')
          .doc(widget.patientId)
          .collection('DossierMedical')
          .doc('passation')
          .collection('Soins')
          .add(soinData);

      setState(() {
        _historiqueSoins.add({
          ...soinData,
          'date': DateTime.now(),
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passation enregistrée avec succès'),
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

  Widget _buildCheckboxList() {
    return Column(
      children: _soinsRealises.entries.map((entry) {
        return CheckboxListTile(
          title: Text(
            entry.key,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: entry.value ? Colors.deepPurple.shade800 : Colors.grey.shade800,
            ),
          ),
          value: entry.value,
          onChanged: _aucunSoin
              ? null
              : (value) {
                  setState(() {
                    _soinsRealises[entry.key] = value ?? false;
                  });
                },
          secondary: Icon(
            _getIconForSoin(entry.key),
            color: entry.value ? Colors.deepPurple : Colors.grey.shade600,
            size: 24,
          ),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: Colors.deepPurple,
          checkColor: Colors.white,
          tileColor: entry.value ? Colors.deepPurple.withOpacity(0.05) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        );
      }).toList(),
    );
  }

  IconData _getIconForSoin(String soin) {
    switch (soin) {
      case 'Pansement': return Icons.healing;
      case 'Injection': return Icons.medical_services;
      case 'Perfusion': return Icons.medication;
      case 'Prise de sang': return Icons.bloodtype;
      case 'Vaccination': return Icons.vaccines;
      default: return Icons.medical_services_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Édition de Passation', 
          style: TextStyle(
            fontSize: 22, 
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade800, Colors.purple.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              shadowColor: Colors.deepPurple.withOpacity(0.2),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey.shade50],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Soins réalisés',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildCheckboxList(),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _autreSoinController,
                          decoration: InputDecoration(
                            labelText: 'Autre soin (préciser)',
                            labelStyle: TextStyle(color: Colors.deepPurple.shade700),
                            floatingLabelStyle: TextStyle(color: Colors.deepPurple),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Icon(Icons.add_circle_outline, color: Colors.deepPurple),
                          ),
                          enabled: !_aucunSoin,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _observationController,
                          decoration: InputDecoration(
                            labelText: 'Observations',
                            labelStyle: TextStyle(color: Colors.deepPurple.shade700),
                            floatingLabelStyle: TextStyle(color: Colors.deepPurple),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Icon(Icons.note_add, color: Colors.deepPurple),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Theme(
                              data: Theme.of(context).copyWith(
                                unselectedWidgetColor: Colors.deepPurple,
                              ),
                              child: Checkbox(
                                value: _aucunSoin,
                                onChanged: (value) {
                                  setState(() {
                                    _aucunSoin = value ?? false;
                                    if (_aucunSoin) {
                                      for (var key in _soinsRealises.keys) {
                                        _soinsRealises[key] = false;
                                      }
                                    }
                                  });
                                },
                                activeColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            Text(
                              'Aucun soin à transmettre',
                              style: TextStyle(
                                color: _aucunSoin ? Colors.deepPurple : Colors.grey.shade800,
                                fontWeight: _aucunSoin ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _chargementPersonnel
                            ? const CircularProgressIndicator()
                            : DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Transmettre à',
                                  border: OutlineInputBorder(),
                                ),
                                isExpanded: true,
                                value: _transmettreA,
                                items: _personnelService.map((personne) {
                                  final fullName = "${personne['prenom']} ${personne['nom']} (${personne['role']})";
                                  return DropdownMenuItem<String>(
                                    value: personne['id'],
                                    child: Text(fullName),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _transmettreA = value;
                                  });
                                },
                              ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _enregistrerSoins,
                            icon: Icon(Icons.save_rounded, size: 24),
                            label: const Text(
                              'Enregistrer la modification',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple[700],
                              foregroundColor: Colors.white,
                              disabledForegroundColor: Colors.white.withOpacity(0.38),
                              disabledBackgroundColor: Colors.deepPurple[700]!.withOpacity(0.12),
                              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide.none,
                              ),
                              elevation: 4,
                              shadowColor: Colors.deepPurple.withOpacity(0.4),
                              animationDuration: const Duration(milliseconds: 200),
                              enableFeedback: true,
                              alignment: Alignment.center,
                              splashFactory: InkRipple.splashFactory,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Historique des passations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('Patients')
                  .doc(widget.patientId)
                  .collection('DossierMedical')
                  .doc('passation')
                  .collection('Soins')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Erreur: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final passations = snapshot.data?.docs ?? [];

                if (passations.isEmpty) {
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Aucune passation enregistrée',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: passations.length,
                  itemBuilder: (context, index) {
                    final passation = passations[index].data() as Map<String, dynamic>;
                    final dynamic dateData = passation['date'];
                    final DateTime? date;

                    if (dateData is Timestamp) {
                      date = dateData.toDate();
                    } else if (dateData is DateTime) {
                      date = dateData;
                    } else {
                      date = null;
                    }

                    final dateStr = date != null 
                        ? DateFormat('dd/MM/yyyy - HH:mm').format(date)
                        : 'Date inconnue';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.grey.shade50, Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ExpansionTile(
                          leading: Icon(
                            Icons.medical_services_rounded, 
                            color: Colors.deepPurple, 
                            size: 28,
                          ),
                          title: Text(
                            dateStr,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple.shade800,
                            ),
                          ),
                          subtitle: Text(
                            'Par ${passation['infirmier'] ?? 'Inconnu'}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          childrenPadding: EdgeInsets.zero,
                          expandedAlignment: Alignment.centerLeft,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Soins réalisés:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  ...(passation['soins'] as List<dynamic>?)
                                      ?.map((s) => Text('- $s'))
                                      .toList() ??
                                      [const Text('Aucun soin spécifié')],
                                  if (passation['observation'] != null && 
                                      passation['observation'].toString().isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Observations:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(passation['observation']),
                                  ],
                                  if (passation['transmisA'] != null) ...[
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Transmis à:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(passation['transmisA']),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}