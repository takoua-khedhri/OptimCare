import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ListePatient.dart';
import 'AcceuilPage.dart';

class DashboardInf extends StatefulWidget {
  final String userId;
  final bool isSuperviseur;

  const DashboardInf({
    Key? key,
    required this.userId,
    this.isSuperviseur = false,
  }) : super(key: key);

  @override
  _DashboardInfState createState() => _DashboardInfState();
}

class _DashboardInfState extends State<DashboardInf> {
  String nom = "";
  String prenom = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Infermier')
          .doc(widget.userId)
          .get();

      if (snapshot.exists) {
        setState(() {
          nom = snapshot['nom'] ?? "";
          prenom = snapshot['prenom'] ?? "";
          email = snapshot['email'] ?? "";
        });
      } else {
        print("Infirmier non trouvé");
      }
    } catch (e) {
      print("Erreur lors du chargement de l'infirmier : $e");
    }
  }

  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => AcceuilPage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print("Erreur lors de la déconnexion: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Une erreur s'est produite lors de la déconnexion"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Bonjour $prenom 👋',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue[800]!, Colors.lightBlue[400]!],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    MediaQuery.of(context).size.width,
                    80,
                    16,
                    0,
                  ),
                  items: [
                    PopupMenuItem(
                      child: ListTile(
                        leading: Icon(Icons.email, color: Colors.blue),
                        title: Text(
                          'Email : $email',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      enabled: false,
                    ),
                    PopupMenuItem(
                      child: ListTile(
                        leading: Icon(Icons.settings, color: Colors.blue),
                        title: Text('Paramètres'),
                        onTap: () {
                          Navigator.pop(context);
                          // Aller à la page Paramètres
                        },
                      ),
                    ),
                    PopupMenuItem(
                      child: ListTile(
                        leading: Icon(Icons.logout, color: Colors.red),
                        title: Text(
                          'Déconnexion',
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _signOut();
                        },
                      ),
                    ),
                  ],
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  prenom.isNotEmpty ? prenom[0] : '',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Détermine combien de colonnes afficher selon la taille de l'écran
          int crossAxisCount = 2;
          double width = constraints.maxWidth;

          if (width >= 1200) {
            crossAxisCount = 4;
          } else if (width >= 800) {
            crossAxisCount = 3;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tableau de bord',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Gérez vos activités quotidiennes',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 32),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildDashboardCard(
                      icon: Icons.people_alt_rounded,
                      color: [Colors.blue[800]!, Colors.lightBlue[400]!],
                      title: 'Patients',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ListePatientPage(userId: widget.userId),
                          ),
                        );
                      },
                    ),
                    _buildDashboardCard(
                      icon: Icons.calendar_today_rounded,
                      color: [Colors.purple[800]!, Colors.deepPurple[300]!],
                      title: 'Planning',
                      onTap: () {
                        // Aller vers page Planning
                      },
                    ),
                    _buildDashboardCard(
                      icon: Icons.assignment_rounded,
                      color: [Colors.teal[700]!, Colors.teal[300]!],
                      title: 'Rapports',
                      onTap: () {
                        // Aller vers page Rapports
                      },
                    ),
                    _buildDashboardCard(
                      icon: Icons.settings_rounded,
                      color: [Colors.orange[800]!, Colors.orange[300]!],
                      title: 'Paramètres',
                      onTap: () {
                        // Aller vers page Paramètres
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required List<Color> color,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: color,
            ),
            boxShadow: [
              BoxShadow(
                color: color[0].withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
