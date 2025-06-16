import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DemandesMdpPage extends StatelessWidget {
  const DemandesMdpPage({Key? key}) : super(key: key);

  String formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 600 && screenWidth <= 1024;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Demandes de réinitialisation de MDP"),
        backgroundColor: Colors.green[800],
        elevation: 4,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
        ),
      ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[50]!,
              Colors.white,
            ],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('demandes_mdp')
              .orderBy('date', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Erreur de chargement des données",
                      style: TextStyle(
                        color: Colors.green[900],
                        fontSize: isDesktop ? 18 : 16,
                      ),
                    ),
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green[800]!),
                ),
              );
            }

            final demandes = snapshot.data!.docs;

            if (demandes.isEmpty) {
              return Center(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "Aucune demande trouvée",
                      style: TextStyle(
                        color: Colors.green[900],
                        fontSize: isDesktop ? 20 : 18,
                      ),
                    ),
                  ),
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : isTablet ? 24 : 16,
                vertical: 16,
              ),
              child: ListView.builder(
                itemCount: demandes.length,
                itemBuilder: (context, index) {
                  final doc = demandes[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final String email = data['email'] ?? '';
                  final String etat = data['etat'] ?? '';
                  final Timestamp date = data['date'];

                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 0 : 8,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.green[50]!,
                            Colors.white,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isDesktop ? 20 : 16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: isDesktop ? 36 : 32,
                              color: Colors.green[800],
                            ),
                            SizedBox(width: isDesktop ? 20 : 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    email,
                                    style: TextStyle(
                                      fontSize: isDesktop ? 18 : 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[900],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Date : ${formatDate(date)}',
                                    style: TextStyle(
                                      fontSize: isDesktop ? 16 : 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'État : $etat',
                                    style: TextStyle(
                                      fontSize: isDesktop ? 16 : 14,
                                      color: etat == 'réinitialisée'
                                          ? Colors.green[600]
                                          : Colors.orange[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: isDesktop ? 20 : 16),
                            SizedBox(
                              width: isDesktop ? 150 : 120,
                              height: isDesktop ? 48 : 40,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: etat == 'réinitialisée'
                                      ? Colors.grey
                                      : Colors.green[700],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 2,
                                ),
                                onPressed: etat == 'réinitialisée'
                                    ? null
                                    : () async {
                                        try {
                                          await FirebaseAuth.instance
                                              .sendPasswordResetEmail(email: email);

                                          await FirebaseFirestore.instance
                                              .collection('demandes_mdp')
                                              .doc(doc.id)
                                              .update({'etat': 'réinitialisée'});

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Email envoyé à $email'),
                                              backgroundColor: Colors.green[700],
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Erreur : ${e.toString()}'),
                                              backgroundColor: Colors.red[700],
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                child: Text(
                                  "Réinitialiser",
                                  style: TextStyle(
                                    fontSize: isDesktop ? 16 : 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}