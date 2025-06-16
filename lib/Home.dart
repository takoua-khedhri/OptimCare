import 'package:flutter/material.dart';
import 'AcceuilPage.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Fond animé avec dégradé moderne
          AnimatedContainer(
            duration: Duration(seconds: 2),
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

          // Éléments décoratifs animés
          Positioned(
            top: -50,
            right: -50,
            child: AnimatedContainer(
              duration: Duration(seconds: 3),
              curve: Curves.easeInOut,
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade100.withOpacity(0.1),
              ),
            ),
          ),

          Positioned(
            bottom: -80,
            left: -80,
            child: AnimatedContainer(
              duration: Duration(seconds: 3),
              curve: Curves.easeInOut,
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.shade100.withOpacity(0.1),
              ),
            ),
          ),

          // Contenu principal centré
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo avec animation plus sophistiquée
                    AnimatedScale(
                      scale: 1,
                      duration: Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      child: Hero(
                        tag: 'app-logo',
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                            image: DecorationImage(
                              image: AssetImage('assets/images/logoApp.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Texte de bienvenue avec animation en cascade
                    Column(
                      children: [
                        AnimatedSlide(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          offset: Offset(0, 0),
                          child: AnimatedOpacity(
                            duration: Duration(milliseconds: 700),
                            opacity: 1,
                            child: Text(
                              'Bienvenue chez',
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedSlide(
                          duration: Duration(milliseconds: 600),
                          curve: Curves.easeOut,
                          offset: Offset(0, 0),
                          child: AnimatedOpacity(
                            duration: Duration(milliseconds: 800),
                            opacity: 1,
                            child: Text(
                              'OptimCare',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                                letterSpacing: 1.2,
                                shadows: [
                                  Shadow(
                                    blurRadius: 4,
                                    color: Colors.black12,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Bouton avec animation au hover
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF4285F4).withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            // Animation de transition améliorée
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: Duration(milliseconds: 800),
                                pageBuilder: (_, __, ___) => AcceuilPage(),
                                transitionsBuilder: (_, animation, __, child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: ScaleTransition(
                                      scale: Tween<double>(
                                        begin: 0.9,
                                        end: 1.0,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.fastOutSlowIn,
                                        ),
                                      ),
                                      child: child,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Color(0xFF4285F4),
                            padding: EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedSwitcher(
                                duration: Duration(milliseconds: 300),
                                child: Text(
                                  'Commencer',
                                  key: ValueKey('text'),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              AnimatedSwitcher(
                                duration: Duration(milliseconds: 300),
                                transitionBuilder: (child, animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  );
                                },
                                child: Icon(
                                  Icons.arrow_forward,
                                  size: 20,
                                  key: ValueKey('icon'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Texte secondaire optionnel
                    const SizedBox(height: 30),
                    AnimatedOpacity(
                      duration: Duration(seconds: 2),
                      opacity: 1,
                      child: Text(
                        'Votre santé, notre priorité',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}