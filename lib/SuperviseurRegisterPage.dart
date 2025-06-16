import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'SuperviseurConxPage.dart';

class SuperviseurRegisterPage extends StatefulWidget {
  const SuperviseurRegisterPage({Key? key}) : super(key: key);

  @override
  _SuperviseurRegisterPageState createState() => _SuperviseurRegisterPageState();
}

class _SuperviseurRegisterPageState extends State<SuperviseurRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedService;

  bool _isLoading = false;
  final List<String> _services = [
    'Dermatologie', 'Cardiologie', 'Pédiatrie', 'Gynécologie',
    'Neurologie', 'Oncologie', 'Orthopédie', 'Ophtalmologie',
    'Psychiatrie', 'Endocrinologie', 'Gastroentérologie', 'Hématologie',
    'Rhumatologie', 'Urologie', 'Chirurgie générale', 'Chirurgie esthétique',
    'Chirurgie vasculaire', 'Anesthésie et réanimation', 'Pneumologie',
    'Néphrologie', 'Radiologie',
  ];

  Future<void> _registerSuperviseur() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        await FirebaseFirestore.instance
            .collection('Superviseurs')
            .doc(userCredential.user!.uid)
            .set({
              'nom': _nomController.text.trim(),
              'prenom': _prenomController.text.trim(),
              'email': _emailController.text.trim(),
              'service': _selectedService,
            });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Compte créé avec succès !'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SuperviseurConxPage()),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Erreur lors de la création du compte';
        if (e.code == 'email-already-in-use') {
          errorMessage = 'Cet email est déjà utilisé.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'Le mot de passe est trop faible.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    // Valeurs responsive
    final iconSize = isMobile ? 100.0 : isTablet ? 120.0 : 150.0;
    final logoSize = isMobile ? 80.0 : isTablet ? 90.0 : 100.0;
    final titleFontSize = isMobile ? 20.0 : isTablet ? 22.0 : 24.0;
    final formPadding = isMobile ? 16.0 : isTablet ? 20.0 : 24.0;
    final verticalSpacing = isMobile ? 16.0 : isTablet ? 20.0 : 24.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Fond avec dégradé
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade50, Colors.white],
              ),
            ),
          ),

          // Éléments décoratifs médicaux (responsive)
          Positioned(
            top: isMobile ? -20 : -30,
            right: isMobile ? -20 : -30,
            child: Icon(
              Icons.medical_services,
              size: iconSize,
              color: Colors.blue.shade100.withOpacity(0.3),
            ),
          ),
          Positioned(
            bottom: isMobile ? -30 : -40,
            left: isMobile ? -20 : -30,
            child: Icon(
              Icons.favorite,
              size: iconSize,
              color: Colors.red.shade100.withOpacity(0.3),
            ),
          ),

          // Icône de retour
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.arrow_back, 
                color: Colors.green.shade800,
                size: isMobile ? 24 : 28,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Contenu principal
          SingleChildScrollView(
            padding: EdgeInsets.all(formPadding),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: isMobile ? 20 : 40),
                  
                  // Logo et titre
                  Column(
                    children: [
                      Container(
                        width: logoSize,
                        height: logoSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.supervisor_account,
                          size: logoSize * 0.5,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                      SizedBox(height: verticalSpacing),
                      Text(
                        'Créer un compte Superviseur',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E7D32),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: verticalSpacing / 2),
                      Text(
                        'Remplissez les informations requises',
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: verticalSpacing * 1.5),

                  // Carte contenant le formulaire
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: EdgeInsets.symmetric(
                      horizontal: isMobile ? 0 : screenWidth * 0.1),
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 16 : 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildResponsiveTextField(
                              controller: _nomController,
                              label: 'Nom',
                              icon: Icons.person_outline,
                              isMobile: isMobile,
                            ),
                            SizedBox(height: verticalSpacing),
                            _buildResponsiveTextField(
                              controller: _prenomController,
                              label: 'Prénom',
                              icon: Icons.person_outline,
                              isMobile: isMobile,
                            ),
                            SizedBox(height: verticalSpacing),
                            _buildResponsiveTextField(
                              controller: _emailController,
                              label: 'Email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              isMobile: isMobile,
                            ),
                            SizedBox(height: verticalSpacing),
                            _buildResponsiveTextField(
                              controller: _passwordController,
                              label: 'Mot de passe',
                              icon: Icons.lock_outline,
                              obscureText: true,
                              isMobile: isMobile,
                            ),
                            SizedBox(height: verticalSpacing * 1.5),

                            // Sélection du service
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'Service',
                                    border: InputBorder.none,
                                    prefixIcon: Icon(Icons.medical_services_outlined),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: isMobile ? 14 : 16,
                                    ),
                                  ),
                                  value: _selectedService,
                                  items: _services.map((service) {
                                    return DropdownMenuItem<String>(
                                      value: service,
                                      child: Text(
                                        service,
                                        style: TextStyle(
                                          fontSize: isMobile ? 14 : 16,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedService = newValue;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Veuillez sélectionner un service';
                                    }
                                    return null;
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  icon: const Icon(Icons.arrow_drop_down),
                                  isExpanded: true,
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: isMobile ? 14 : 16,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: verticalSpacing * 2),

                            // Bouton d'inscription
                            SizedBox(
                              width: double.infinity,
                              height: isMobile ? 45 : 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _registerSuperviseur,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: const Color(0xFF2E7D32),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : Text(
                                        'CRÉER LE COMPTE',
                                        style: TextStyle(
                                          fontSize: isMobile ? 14 : 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: verticalSpacing),

                  // Lien vers la page de connexion
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const SuperviseurConxPage()),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'Déjà un compte ? ',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: isMobile ? 12 : 14,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Se connecter',
                            style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: verticalSpacing),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isMobile,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            vertical: isMobile ? 14 : 16,
            horizontal: 16,
          ),
        ),
        validator: (value) =>
            value == null || value.trim().isEmpty
                ? 'Veuillez remplir ce champ'
                : null,
      ),
    );
  }
}