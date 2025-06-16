import 'package:flutter/material.dart';
import 'SuperviseurRegisterPage.dart';
import 'NurseLoginPage.dart';

class AcceuilPage extends StatelessWidget {
  const AcceuilPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Fond avec dégradé et éléments décoratifs
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade50, Colors.white],
              ),
            ),
          ),

          // Éléments décoratifs médicaux
          Positioned(
            top: -30,
            right: -30,
            child: Icon(
              Icons.medical_services,
              size: 150,
              color: Colors.blue.shade100.withOpacity(0.3),
            ),
          ),

          Positioned(
            bottom: -40,
            left: -30,
            child: Icon(
              Icons.favorite,
              size: 150,
              color: Colors.red.shade100.withOpacity(0.3),
            ),
          ),

          Positioned(
            top: 100,
            left: 20,
            child: Icon(
              Icons.medication,
              size: 60,
              color: Colors.green.shade100.withOpacity(0.4),
            ),
          ),

          Positioned(
            bottom: 100,
            right: 20,
            child: Icon(
              Icons.monitor_heart,
              size: 60,
              color: Colors.purple.shade100.withOpacity(0.4),
            ),
          ),

          // Contenu principal
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center, // Centrage horizontal
              children: [
                // Logo et titre avec image de logo
                Column(
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('assets/images/logoApp.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'OptimCare',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified, size: 16, color: Colors.blue),
                        const SizedBox(width: 5),
                        const Text(
                          'Solution certifiée pour professionnels',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                // Boutons d'action avec icônes détaillées
                _buildRoleButton(
                  context: context,
                  icon: Icons.medical_information,
                  label: 'Espace Infirmier',
                  color: const Color(0xFF4285F4),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NurseLoginPage()),
                    );
                  },
                ),

                const SizedBox(height: 20),

                _buildRoleButton(
                  context: context,
                  icon: Icons.assignment_ind,
                  label: 'Espace Superviseur',
                  color: Colors.green,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SuperviseurRegisterPage()),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // Footer avec icônes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.security, size: 14, color: Colors.green),
                    const SizedBox(width: 5),
                    const Text(
                      'Données chiffrées',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 15),
                    Icon(
                      Icons.medical_information,
                      size: 14,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Normes HL7',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Align(
      alignment: Alignment.center,  // Centrer les boutons horizontalement
      child: SizedBox(
        width: 300,  // Limiter la largeur du bouton
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            shadowColor: color.withOpacity(0.3),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
