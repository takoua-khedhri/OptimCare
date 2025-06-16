import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard_inf.dart';

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _loginInfermier() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('Infermier')
            .where('email', isEqualTo: _emailController.text.trim())
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Aucun compte infirmier trouvé avec cet email'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.red.shade400,
            ),
          );
          setState(() => _isLoading = false);
          return;
        }

        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        String userId = userCredential.user!.uid;

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => DashboardInf(userId: userId),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Identifiants incorrects';
        if (e.code == 'user-not-found') {
          errorMessage = 'Aucun utilisateur trouvé pour cet email';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Mot de passe incorrect';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.red.shade400,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Une erreur s\'est produite: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }



 Future<void> _envoyerDemandeReset() async {
  final email = _emailController.text.trim().toLowerCase();
  print("Email saisi : $email");

  if (email.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Veuillez entrer votre email.")),
    );
    return;
  }

  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Infermier')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email non reconnu comme infirmier.")),
      );
      return;
    }

    // Enregistrer seulement la demande (NE PAS envoyer d'email ici)
    await FirebaseFirestore.instance.collection('demandes_mdp').add({
      'email': email,
      'date': Timestamp.now(),
      'etat': 'en attente',
      'userId': querySnapshot.docs.first.id,
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Demande envoyée"),
        content: Text("Votre demande a été envoyée au superviseur. Vous recevrez un email lorsque votre mot de passe sera réinitialisé."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  } catch (e) {
    print("Erreur : $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erreur lors de l'envoi de la demande.")),
    );
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
                color: Colors.blue.shade800,
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
                      'Connexion Infirmier',
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
                                _buildTextField(
                                  controller: _emailController,
                                  label: 'Email',
                                  icon: Icons.email_outlined,
                                ),
                                SizedBox(height: isDesktop ? 30 : 20),
                                _buildTextField(
                                  controller: _passwordController,
                                  label: 'Mot de passe',
                                  icon: Icons.lock_outlined,
                                  obscureText: true,
                                ),
                                SizedBox(height: isDesktop ? 40 : 30),
                                
                                // Bouton de connexion
                                SizedBox(
                                  width: double.infinity,
                                  height: isDesktop ? 60 : 
                                          isTablet ? 55 : 50,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _loginInfermier,
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
                                            'Se connecter',
                                            style: TextStyle(
                                              fontSize: isDesktop ? 20 : 
                                                       isTablet ? 18 : 16,
                                            ),
                                          ),
                                  ),
                                ),
                                SizedBox(height: isDesktop ? 30 : 20),
                                
                                // Lien mot de passe oublié
                                TextButton(
                                  onPressed: _envoyerDemandeReset,
                                  child: Text(
                                    'Mot de passe oublié ?',
                                    style: TextStyle(
                                      color: Colors.blue.shade600,
                                      fontWeight: FontWeight.w500,
                                      fontSize: isDesktop ? 18 : 
                                               isTablet ? 16 : 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;
    
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade300),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          vertical: isDesktop ? 20 : 
                   MediaQuery.of(context).size.width > 600 ? 18 : 16,
          horizontal: 16,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Veuillez remplir ce champ';
        }
        return null;
      },
    );
  }
}