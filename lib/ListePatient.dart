import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dossierMedicale.dart';
import 'CollecteDonnes.dart';

class ListePatientPage extends StatefulWidget {
  final String userId;

  const ListePatientPage({Key? key, required this.userId}) : super(key: key);

  @override
  _ListePatientPageState createState() => _ListePatientPageState();
}

class _ListePatientPageState extends State<ListePatientPage> {
  late String infermierId;
  String? infermierService;
  final TextEditingController _searchController = TextEditingController();
  int notificationCount = 0;
  List<Map<String, dynamic>> notifications = [];
  Timer? _notificationTimer;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

 void _initializeUserData() async {
  infermierId = widget.userId; // Utilise bien l'ID passé à la page

  try {
    DocumentSnapshot infermierDoc = await FirebaseFirestore.instance
        .collection('Infermier')
        .doc(infermierId)
        .get();

    if (infermierDoc.exists) {
      setState(() {
        infermierService = infermierDoc['service'];
      });
      _startNotificationTimer();
    } else {
      debugPrint('Aucun infirmier trouvé avec cet ID');
    }
  } catch (e) {
    debugPrint('Erreur lors de la récupération de l\'infirmier : $e');
  }
}
void _startNotificationTimer() {
    _checkDelayedEvaluations();
    _notificationTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      _checkDelayedEvaluations();
    });
  }

  Future<void> _checkDelayedEvaluations() async {
    if (infermierService == null) return;

    try {
      QuerySnapshot patientsSnapshot = await FirebaseFirestore.instance
          .collection('Patients')
          .where('service', isEqualTo: infermierService)
          .get();

      DateTime alertThreshold = DateTime.now().subtract(const Duration(hours: 2));
      List<Map<String, dynamic>> newNotifications = [];

      for (QueryDocumentSnapshot patientDoc in patientsSnapshot.docs) {
        DocumentSnapshot planDoc = await patientDoc.reference
            .collection('DossierMedical')
            .doc('plan_soins_actuel')
            .get();

        if (planDoc.exists) {
          Map<String, dynamic>? planData = planDoc.data() as Map<String, dynamic>?;
          Timestamp? lastModification = planData?['derniereModification'] as Timestamp?;

          if (lastModification != null && lastModification.toDate().isBefore(alertThreshold)) {
            DocumentSnapshot infoDoc = await patientDoc.reference
                .collection('DossierMedical')
                .doc('info_personnelle')
                .get();

            if (infoDoc.exists) {
              Map<String, dynamic> infoData = infoDoc.data() as Map<String, dynamic>;
              Duration delay = DateTime.now().difference(lastModification.toDate());

              newNotifications.add({
                'patientId': patientDoc.id,
                'patientName': '${infoData['prenom']} ${infoData['nom']}',
                'lit': infoData['lit'] ?? 'N/A',
                'lastEvaluation': planData?['evaluation'] ?? 'Non évalué',
                'lastUpdate': lastModification.toDate(),
                'delay': delay,
                'message': '${infoData['prenom']} ${infoData['nom']} (Lit ${infoData['lit'] ?? 'N/A'}) '
                    'n\'a pas été réévalué depuis ${delay.inHours}h ${delay.inMinutes.remainder(60)}min',
              });
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          notifications = newNotifications;
          notificationCount = notifications.length;
        });
      }
    } catch (e) {
      debugPrint('Erreur de vérification: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _notificationTimer?.cancel();
    super.dispose();
  }

  IconData _getStatusIcon(String evaluation) {
    switch (evaluation) {
      case 'Amélioration':
        return Icons.arrow_upward;
      case 'Stagnation':
        return Icons.horizontal_rule;
      case 'Aggravation':
        return Icons.arrow_downward;
      default:
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AjoutPatientPage(userId: infermierId),
            ),
          );
        },
        backgroundColor: Colors.blue[800],
        child: const Icon(Icons.add, color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[800]!, Colors.lightBlue[400]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Liste des Patients',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () {
                      _showNotifications(context);
                    },
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          notificationCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Rechercher un patient...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: infermierService == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Patients')
                        .where('service', isEqualTo: infermierService)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Erreur: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return _buildEmptyState();
                      }

                      final patients = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: patients.length,
                        itemBuilder: (context, index) {
                          final patientDoc = patients[index];
                          final patientId = patientDoc.id;

                          return _buildPatientCard(patientId: patientId);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alertes de réévaluation'),
        content: SizedBox(
          width: double.maxFinite,
          child: notifications.isEmpty
              ? const Center(child: Text('Aucune alerte active'))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: const Icon(Icons.warning_amber, color: Colors.orange),
                        title: Text('Réévaluation nécessaire'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notif['message']),
                            const SizedBox(height: 4),
                            Text(
                              'Dernière modification: ${DateFormat('dd/MM à HH:mm').format(notif['lastUpdate'])}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DossierMedicalePage(
                                patientId: notif['patientId'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 300,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_alt_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Aucun patient trouvé',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Appuyez sur le bouton + pour ajouter un patient',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard({required String patientId}) {
    final infoStream = FirebaseFirestore.instance
        .collection('Patients')
        .doc(patientId)
        .collection('DossierMedical')
        .doc('info_personnelle')
        .snapshots();

    final planStream = FirebaseFirestore.instance
        .collection('Patients')
        .doc(patientId)
        .collection('DossierMedical')
        .doc('plan_soins_actuel')
        .snapshots();

    return StreamBuilder<DocumentSnapshot>(
      stream: infoStream,
      builder: (context, infoSnapshot) {
        if (infoSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (infoSnapshot.hasError || !infoSnapshot.hasData || !infoSnapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final infoData = infoSnapshot.data!.data() as Map<String, dynamic>?;
        if (infoData == null) return const SizedBox.shrink();

        return StreamBuilder<DocumentSnapshot>(
          stream: planStream,
          builder: (context, planSnapshot) {
            final nom = infoData['nom'] ?? 'Nom inconnu';
            final prenom = infoData['prenom'] ?? 'Prénom inconnu';
            final lit = infoData['lit'] ?? 'Lit inconnu';
            final searchTerm = _searchController.text.toLowerCase();

            if (_searchController.text.isNotEmpty &&
                !('$prenom $nom'.toLowerCase().contains(searchTerm))) {
              return const SizedBox.shrink();
            }

            String evaluation = 'En cours';
Color statusColor = Colors.grey;

if (planSnapshot.hasData && planSnapshot.data!.exists) {
  final planData = planSnapshot.data!.data() as Map<String, dynamic>?;
  if (planData != null && planData.containsKey('besoins')) {
    final besoins = planData['besoins'] as List<dynamic>?;

    if (besoins != null && besoins.isNotEmpty) {
      bool hasAggravation = false;
      bool hasStagnation = false;
      bool allAmelioration = true;

      for (var besoin in besoins) {
        final eval = besoin['evaluation'] ?? '';

        if (eval == 'Aggravation') {
          hasAggravation = true;
          allAmelioration = false;
          break; // Priorité absolue
        } else if (eval == 'Stagnation') {
          hasStagnation = true;
          allAmelioration = false;
        } else if (eval != 'Amélioration') {
          allAmelioration = false;
        }
      }

      if (hasAggravation) {
        evaluation = 'Aggravation';
        statusColor = Colors.red;
      } else if (hasStagnation) {
        evaluation = 'Stagnation';
        statusColor = Colors.orange;
      } else if (allAmelioration) {
        evaluation = 'Amélioration';
        statusColor = Colors.green;
      } else {
        evaluation = 'En cours';
        statusColor = Colors.grey;
      }
    }
  } else if (planData != null && planData.containsKey('evaluation')) {
    // fallback si pas de liste de besoins
    final eval = planData['evaluation'] ?? 'En cours';
    evaluation = eval;
    switch (eval) {
      case 'Aggravation':
        statusColor = Colors.red;
        break;
      case 'Stagnation':
        statusColor = Colors.orange;
        break;
      case 'Amélioration':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }
  }
}

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DossierMedicalePage(patientId: patientId),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.8),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              _getStatusIcon(evaluation),
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$prenom $nom',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (lit.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    'Lit: $lit',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'view',
                              child: ListTile(
                                leading: Icon(Icons.visibility, color: Colors.blue),
                                title: Text('Consulter'),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete, color: Colors.red),
                                title: Text('Archiver'),
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'view') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DossierMedicalePage(patientId: patientId),
                                ),
                              );
                            } else if (value == 'delete') {
                              _showDeleteDialog(patientId);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(String patientId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer ce patient ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePatient(patientId);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deletePatient(String patientId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Patients')
          .doc(patientId)
          .delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patient supprimé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}