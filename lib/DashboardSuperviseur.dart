import 'package:flutter/material.dart';
import 'ListeInfermiers.dart';
import 'demandes_mdp_page.dart';

class DashboardSuperviseur extends StatefulWidget {
  final String superviseurEmail;

  const DashboardSuperviseur({Key? key, required this.superviseurEmail})
      : super(key: key);

  @override
  _DashboardSuperviseurState createState() => _DashboardSuperviseurState();
}

class _DashboardSuperviseurState extends State<DashboardSuperviseur> {
  @override
  Widget build(BuildContext context) {
    // Détermination de la taille de l'écran
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Adaptabilité pour différents écrans
    final isPhone = screenWidth < 600;
    final isLargeTablet = screenWidth > 900;
    
    // Configuration responsive
    final crossAxisCount = isPhone ? 2 : (isLargeTablet ? 4 : 3);
    final childAspectRatio = isPhone ? 0.9 : (isLargeTablet ? 1.0 : 0.95); // Ajusté
    final paddingValue = isPhone ? 12.0 : 20.0; // Réduit
    final spacingValue = isPhone ? 12.0 : 20.0; // Réduit
    final titleFontSize = isPhone ? 18.0 : 22.0; // Réduit
    final iconSize = isPhone ? 30.0 : 36.0; // Réduit

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tableau de board Superviseur",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: titleFontSize,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade800, Colors.green.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.green.shade50,
                      Colors.white,
                    ],
                  ),
                ),
                padding: EdgeInsets.all(paddingValue),
                child: GridView.count(
                  shrinkWrap: true, // Ajouté
                  physics: NeverScrollableScrollPhysics(), // Ajouté
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: spacingValue,
                  mainAxisSpacing: spacingValue,
                  childAspectRatio: childAspectRatio,
                  children: [
                    _buildDashboardCard(
                      context: context,
                      icon: Icons.people_alt_rounded,
                      title: 'Liste des Infirmiers',
                      subtitle: 'Gérer les infirmiers de votre service',
                      color: Colors.blue,
                      iconSize: iconSize,
                      isPhone: isPhone,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListeInfermier(
                              superviseurEmail: widget.superviseurEmail,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildDashboardCard(
                      context: context,
                      icon: Icons.password_rounded,
                      title: 'Réinitialisation MDP',
                      subtitle: 'Gérer les demandes de mot de passe',
                      color: Colors.orange,
                      iconSize: iconSize,
                      isPhone: isPhone,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DemandesMdpPage(),
                          ),
                        );
                      },
                    ),
                    _buildDashboardCard(
                      context: context,
                      icon: Icons.bar_chart_rounded,
                      title: 'Statistiques',
                      subtitle: 'Voir les statistiques du service',
                      color: Colors.green,
                      iconSize: iconSize,
                      isPhone: isPhone,
                      onTap: () {
                        // Navigation vers la page des statistiques
                      },
                    ),
                    
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required double iconSize,
    required bool isPhone,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: Container(
          padding: EdgeInsets.all(isPhone ? 10 : 16), // Réduit
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.08),
                color.withOpacity(0.02),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Changé
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isPhone ? 10 : 14), // Réduit
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.1),
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: color,
                ),
              ),
              Column(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isPhone ? 14 : 16, // Réduit
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isPhone ? 2 : 4), // Réduit
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: isPhone ? 10 : 12, // Réduit
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: color,
                size: isPhone ? 18 : 22, // Réduit
              ),
            ],
          ),
        ),
      ),
    );
  }
}