import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'SuperviseurConxPage.dart';
import 'test.dart';

class NurseLoginPage extends StatefulWidget {
  const NurseLoginPage({Key? key}) : super(key: key);

  @override
  _NurseLoginPageState createState() => _NurseLoginPageState();
}

class _NurseLoginPageState extends State<NurseLoginPage> {
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
            .collection('Infermier')
            .doc(userCredential.user!.uid)
            .set({
              'nom': _nomController.text.trim(),
              'prenom': _prenomController.text.trim(),
              'email': _emailController.text.trim(),
              'service': _selectedService,
            });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Compte créé avec succès !'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const Test(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );

        _nomController.clear();
        _prenomController.clear();
        _emailController.clear();
        _passwordController.clear();
      } on FirebaseAuthException catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.message}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 600 && screenWidth <= 1024;
    final isMobile = screenWidth <= 600;

    return Scaffold(
      body: Stack(
        children: [
          // Arrière-plan avec dégradé
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade50,
                  Colors.white,
                  Colors.green.shade50,
                ],
              ),
            ),
          ),

          // Éléments décoratifs
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade100.withOpacity(0.1),
              ),
            ),
          ),
          
          // Bouton de retour en haut à gauche
         Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back, 
                color: Colors.green.shade800,
                size: isDesktop ? 32 : isTablet ? 28 : 24,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          
          // Contenu principal
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? screenWidth * 0.1 : 
                          isTablet ? screenWidth * 0.1 : 24.0,
                vertical: 24.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight,
                  maxWidth: isDesktop ? 800 : 600,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Hero(
                      tag: 'app-logo',
                      child: Container(
                        width: isDesktop ? 180 : 
                               isTablet ? 150 : 120,
                        height: isDesktop ? 180 : 
                                isTablet ? 150 : 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.2),
                              blurRadius: 12,
                              spreadRadius: 3,
                            ),
                          ],
                          image: DecorationImage(
                            image: AssetImage('assets/images/logoApp.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: isDesktop ? 40 : 30),
                    
                    // Titre
                    Text(
                      'Créer un compte',
                      style: TextStyle(
                        fontSize: isDesktop ? 28 : 
                                 isTablet ? 26 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    
                    SizedBox(height: isDesktop ? 50 : 40),

                    // Carte du formulaire
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 700 : 600,
                      ),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isDesktop ? 40.0 : 
                                                 isTablet ? 32.0 : 24.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Formulaire en ligne pour les écrans larges
                                if (isDesktop) ...[
                                  _buildDesktopFormRow(),
                                ] else ...[
                                  // Formulaire en colonne pour les petits écrans
                                  _buildTextField(
                                    controller: _nomController,
                                    label: 'Nom',
                                    icon: Icons.person_outline,
                                  ),
                                  SizedBox(height: isTablet ? 24 : 16),
                                  _buildTextField(
                                    controller: _prenomController,
                                    label: 'Prénom',
                                    icon: Icons.person_outline,
                                  ),
                                  SizedBox(height: isTablet ? 24 : 16),
                                  _buildTextField(
                                    controller: _emailController,
                                    label: 'Email',
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  SizedBox(height: isTablet ? 24 : 16),
                                  _buildTextField(
                                    controller: _passwordController,
                                    label: 'Mot de passe',
                                    icon: Icons.lock_outline,
                                    obscureText: true,
                                  ),
                                ],
                                
                                SizedBox(height: isDesktop ? 30 : 20),

                                // Menu déroulant Service
                                DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'Service',
                                    prefixIcon: Icon(Icons.medical_services_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: isDesktop ? 20 : 
                                               isTablet ? 18 : 16,
                                      horizontal: 16,
                                    ),
                                  ),
                                  value: _selectedService,
                                  isExpanded: true,
                                  items: _services.map((service) {
                                    return DropdownMenuItem<String>(
                                      value: service,
                                      child: Text(
                                        service,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: isDesktop ? 18 : 
                                                   isTablet ? 16 : 14,
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
                                ),

                                SizedBox(height: isDesktop ? 40 : 30),
                                
                                // Bouton de soumission
                                SizedBox(
                                  width: double.infinity,
                                  height: isDesktop ? 60 : 
                                          isTablet ? 55 : 50,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _registerSuperviseur,
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Color(0xFF4285F4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      elevation: 5,
                                      shadowColor: Color(0xFF4285F4).withOpacity(0.3),
                                    ),
                                    child: _isLoading
                                        ? CircularProgressIndicator(color: Colors.white)
                                        : Text(
                                            'Créer le compte',
                                            style: TextStyle(
                                              fontSize: isDesktop ? 20 : 
                                                       isTablet ? 18 : 16,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: isDesktop ? 40 : 30),
                    
                    // Lien vers la page de connexion
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const Test(),
                            transitionsBuilder: (_, animation, __, child) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Déjà un compte ? ',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: isDesktop ? 18 : 
                                     isTablet ? 16 : 14,
                          ),
                          children: [
                            TextSpan(
                              text: 'Se connecter',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: isDesktop ? 50 : 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Construction d'une ligne de formulaire pour les écrans larges
  Widget _buildDesktopFormRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _buildTextField(
                controller: _nomController,
                label: 'Nom',
                icon: Icons.person_outline,
              ),
              SizedBox(height: 24),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        SizedBox(width: 24),
        Expanded(
          child: Column(
            children: [
              _buildTextField(
                controller: _prenomController,
                label: 'Prénom',
                icon: Icons.person_outline,
              ),
              SizedBox(height: 24),
              _buildTextField(
                controller: _passwordController,
                label: 'Mot de passe',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;
    
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade300),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: isDesktop ? 20 : 
                   MediaQuery.of(context).size.width > 600 ? 18 : 16,
          horizontal: 16,
        ),
      ),
      validator: (value) =>
          value == null || value.trim().isEmpty ? 'Veuillez remplir ce champ' : null,
    );
  }
}