// Login and onboarding UI. Contains the multi-state authentication
// flow (signup, login, professional) used on first run. Exposes
// optional callbacks for navigation and external links.
import 'dart:ui' show ImageFilter, clampDouble, lerpDouble;
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

import '../services/auth_service.dart';
import '../services/onboarding_service.dart';
import '../widgets/auth_flow_loader.dart';
import '../widgets/animated_mosaic_background.dart';
import 'home_screen.dart';
import 'onboarding_flow_screen.dart';
import 'psychiatrist_screen.dart';
import 'admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.onStartJourney,
    this.onExistingAccount,
    this.onPrivacyPolicy,
    this.onTermsOfService,
    this.onPsychiatristLogin,
  });

  final VoidCallback? onStartJourney;
  final VoidCallback? onExistingAccount;
  final VoidCallback? onPrivacyPolicy;
  final VoidCallback? onTermsOfService;
  final VoidCallback? onPsychiatristLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
  with TickerProviderStateMixin {
  static const _backgroundTop = Color(0xFFB8D3CC);
  static const _backgroundMid = Color(0xFF87AAA2);
  static const _backgroundBottom = Color(0xFF4F6E69);
  static const _buttonStart = Color(0xFF2D726B);
  static const _buttonEnd = Color(0xFF184F4B);
  static const _softWhite = Color(0xFFF7FFFB);

  late final AnimationController _screenTransitionController;
  late final TapGestureRecognizer _privacyRecognizer;
  late final TapGestureRecognizer _termsRecognizer;
  TapGestureRecognizer? _psychiatristRecognizer;

  String _currentScreen = 'main'; // 'main', 'signup', 'login', 'professional'

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _screenTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 980),
      value: 1,
    );
    _privacyRecognizer = TapGestureRecognizer()..onTap = _handlePrivacyPolicy;
    _termsRecognizer = TapGestureRecognizer()..onTap = _handleTermsOfService;
    _psychiatristRecognizer =
        TapGestureRecognizer()..onTap = _handlePsychiatristLogin;
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _screenTransitionController.dispose();
    _privacyRecognizer.dispose();
    _termsRecognizer.dispose();
    _psychiatristRecognizer?.dispose();
    super.dispose();
  }

  Future<void> _switchToScreen(String screen) async {
    if (_currentScreen == screen) {
      return;
    }

    // Back navigation should reverse the form sheet animation first,
    // then swap to main to avoid an abrupt disappearance.
    if (screen == 'main' && _currentScreen != 'main') {
      await _screenTransitionController.animateTo(
        0,
        duration: const Duration(milliseconds: 760),
        curve: Curves.easeInOut,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _currentScreen = screen;
      });
      return;
    }

    setState(() {
      _currentScreen = screen;
    });

    _screenTransitionController.forward(from: 0);
  }

  void _handleStartJourney() {
    _switchToScreen('signup');
  }

  void _handleExistingAccount() {
    _switchToScreen('login');
  }

  void _handlePsychiatristLogin() {
    _switchToScreen('professional');
  }

  void _backToMainScreen() {
    _switchToScreen('main');
  }

  void _handlePrivacyPolicy() {
    if (widget.onPrivacyPolicy != null) {
      widget.onPrivacyPolicy!.call();
    } else {
      _showPlaceholderDialog(
        'Privacy Policy',
        'This is our Privacy Policy placeholder text.\n\nYour privacy is important to us. We collect and process personal data in accordance with applicable regulations.',
      );
    }
  }

  void _handleTermsOfService() {
    if (widget.onTermsOfService != null) {
      widget.onTermsOfService!.call();
    } else {
      _showPlaceholderDialog(
        'Terms of Service',
        'This is our Terms of Service placeholder text.\n\nBy using our service, you agree to comply with these terms and conditions.',
      );
    }
  }

  void _showPlaceholderDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(content, style: GoogleFonts.inter()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  TextStyle _buildBrandTitleStyle(double titleSize) {
    return TextStyle(
      fontFamily: 'Doto',
      fontSize: titleSize,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      color: const Color(0xFF244A44),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenTransition = CurvedAnimation(
      parent: _screenTransitionController,
      curve: Curves.easeOutCubic,
    );

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: AnimatedMosaicBackground(animationSpeed: 3.4),
          ),
          Stack(
          children: [
            // Ambient decorations
            const Positioned.fill(child: _AmbientBackdrop()),

            if (_currentScreen == 'main')
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final bodySize = clampDouble(width * 0.033, 12.5, 13.2);
                    final buttonHeight = clampDouble(
                      constraints.maxHeight * 0.075,
                      52,
                      56,
                    );
                    final horizontalPadding = clampDouble(width * 0.06, 20, 24);
                    final safeBottom = mediaQuery.padding.bottom;

                    return Stack(
                      children: [
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFE4EEE9),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: const [
                                    Color(0xFFF2F7F4),
                                    Color(0xFFE4EEE9),
                                  ],
                                  stops: [0.0, 0.32],
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPadding,
                                  22,
                                  horizontalPadding,
                                  22 + safeBottom,
                                ),
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 450),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        _PrimaryActionButton(
                                          height: buttonHeight,
                                          onTap: _handleStartJourney,
                                        ),
                                        const SizedBox(height: 14),
                                        _SecondaryActionButton(
                                          height: buttonHeight,
                                          onTap: _handleExistingAccount,
                                        ),
                                        const SizedBox(height: 20),
                                        Text.rich(
                                          TextSpan(
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: bodySize,
                                              height: 1.55,
                                              color: const Color(0xFF365A54).withValues(alpha: 0.72),
                                              fontWeight: FontWeight.w400,
                                            ),
                                            children: [
                                              const TextSpan(
                                                text: 'By continuing, you agree to our ',
                                              ),
                                              TextSpan(
                                                text: 'Privacy Policy',
                                                recognizer: _privacyRecognizer,
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: bodySize,
                                                  height: 1.55,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF274A45).withValues(alpha: 0.92),
                                                ),
                                              ),
                                              const TextSpan(text: ' and '),
                                              TextSpan(
                                                text: 'Terms of Service',
                                                recognizer: _termsRecognizer,
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: bodySize,
                                                  height: 1.55,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF274A45).withValues(alpha: 0.92),
                                                ),
                                              ),
                                              const TextSpan(text: '. Are you a '),
                                              TextSpan(
                                                text: 'professional?',
                                                recognizer: _psychiatristRecognizer,
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: bodySize,
                                                  height: 1.55,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF274A45).withValues(alpha: 0.92),
                                                ),
                                              ),
                                            ],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              )
            ,

            AnimatedBuilder(
              animation: screenTransition,
              builder: (context, child) {
                final transitionFactor = _currentScreen == 'main'
                    ? 0.0
                    : screenTransition.value;
                final easedT = Curves.easeInOut.transform(transitionFactor);

                final brandSize = clampDouble(mediaQuery.size.width * 0.09, 28, 32);
                final subtitleSize = clampDouble(mediaQuery.size.width * 0.042, 14, 16);
                final mainBrandTop = clampDouble(screenHeight * 0.055, 34, 54);
              final formBrandTop = (mediaQuery.padding.top +
                  clampDouble(screenHeight * 0.035, 18, 30))
                .clamp(mediaQuery.padding.top + 8, screenHeight * 0.42);

                final animatedTop =
                    lerpDouble(mainBrandTop, formBrandTop, transitionFactor) ?? mainBrandTop;
                final subtitleOpacity = (1.0 - easedT).clamp(0.0, 1.0);
                final subtitleLift = lerpDouble(0, -22, easedT) ?? 0.0;

                return Positioned(
                  top: animatedTop,
                  left: 20,
                  right: 20,
                  child: IgnorePointer(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'AETHER',
                          textAlign: TextAlign.center,
                          style: _buildBrandTitleStyle(brandSize),
                        ),
                        Transform.translate(
                          offset: Offset(0, subtitleLift),
                          child: Opacity(
                            opacity: subtitleOpacity,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 18),
                              child: Text(
                                'Aether grows with you\nthrough every small step',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: subtitleSize,
                                  fontWeight: FontWeight.w400,
                                  height: 1.38,
                                  color: const Color.fromARGB(255, 69, 123, 113),
                                  shadows: const [
                                    Shadow(
                                      color: Color(0x66121816),
                                      offset: Offset(0, 1),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            AnimatedBuilder(
              animation: screenTransition,
              builder: (context, child) {
                final transitionFactor = _currentScreen == 'main'
                    ? 0.0
                    : screenTransition.value;

                final mainHeight = clampDouble(screenHeight * 0.4, 280, 380);
                final formHeight = clampDouble(mediaQuery.size.width * 0.95, 230, 320);
                final height = lerpDouble(mainHeight, formHeight, transitionFactor) ?? mainHeight;

                final mainSize = clampDouble(mediaQuery.size.width * 1.22, 410, 600);
                final formSize = clampDouble(mediaQuery.size.width * 1.2, 390, 560);
                final petSize = lerpDouble(mainSize, formSize, transitionFactor) ?? mainSize;

                final opacity = lerpDouble(1.0, 0.96, transitionFactor) ?? 1.0;
                final petScale = 1.38;
                final basePetContainerHeight = height * 0.75;
                final rawPetSize = petSize * petScale;
                final maxVisiblePetSize = basePetContainerHeight * 1.5;
                final resolvedPetSize = math.min(rawPetSize, maxVisiblePetSize);
                final petContainerHeight = math.max(basePetContainerHeight, resolvedPetSize);

                final brandSize = clampDouble(mediaQuery.size.width * 0.09, 28, 32);
                final subtitleSize = clampDouble(mediaQuery.size.width * 0.042, 14, 16);
                final mainBrandTop = clampDouble(screenHeight * 0.055, 34, 54);
                final formBrandTop = (mediaQuery.padding.top +
                    clampDouble(screenHeight * 0.035, 18, 30))
                  .clamp(mediaQuery.padding.top + 8, screenHeight * 0.42);
                final titleTop =
                  lerpDouble(mainBrandTop, formBrandTop, transitionFactor) ?? mainBrandTop;
                final titleCenterY = titleTop + (brandSize * 0.5);

                final mainTitleSectionBottom = mainBrandTop +
                    brandSize +
                    18 +
                    (subtitleSize * 1.38 * 2);
                final mainButtonsTop = screenHeight * 0.72;
                final mainTargetCenterY =
                    (mainTitleSectionBottom + mainButtonsTop) * 0.5;
                final mainTop = mainTargetCenterY - (petContainerHeight * 0.5);

                final formPanelTop =
                  (screenHeight * 0.72) - ((screenHeight * 0.22) * transitionFactor);
                final formTargetCenterY = (titleCenterY + formPanelTop) * 0.5;
                final formTargetTop = formTargetCenterY - (petContainerHeight * 0.5);

                final top =
                  lerpDouble(mainTop, formTargetTop, transitionFactor) ?? mainTop;

                return Positioned(
                  top: top,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: opacity,
                    child: Center(
                      child: SizedBox(
                        height: petContainerHeight,
                        child: Center(
                          child: AnimatedPet(
                            petSize: resolvedPetSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            if (_currentScreen != 'main')
              AnimatedBuilder(
                animation: screenTransition,
                builder: (context, child) {
                  final t = screenTransition.value;
                  final top = (screenHeight * 0.72) - ((screenHeight * 0.22) * t);

                  return Positioned(
                    top: top,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Opacity(
                      opacity: 0.84 + (t * 0.16),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        child: _BottomAttachedAuthForm(
                          currentScreen: _currentScreen,
                          onBack: _backToMainScreen,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
          ),
        ],
      ),
    );
  }
}

class _MidScreenReadabilityGradient extends StatelessWidget {
  const _MidScreenReadabilityGradient();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.transparent,
              Colors.black.withValues(alpha: 0.05),
              Colors.black.withValues(alpha: 0.14),
            ],
            stops: const [0.0, 0.47, 0.62, 1.0],
          ),
        ),
      ),
    );
  }
}

class _BottomAttachedAuthForm extends StatelessWidget {
  const _BottomAttachedAuthForm({
    required this.currentScreen,
    required this.onBack,
  });

  final String currentScreen;
  final VoidCallback onBack;

  double _estimatedContentHeight() {
    switch (currentScreen) {
      case 'signup':
        return 420;
      case 'professional':
        return 420;
      case 'login':
      default:
        return 300;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final horizontalPadding = clampDouble(width * 0.06, 20, 24);
    final titleSize = clampDouble(width * 0.075, 29, 37);
    final bodySize = clampDouble(width * 0.035, 13.5, 15);
    const buttonHeight = 52.0;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final safeBottom = mediaQuery.padding.bottom;
          final availableHeight = constraints.maxHeight - safeBottom;
          final estimatedContentHeight = _estimatedContentHeight();
          final balancedInset = ((availableHeight - estimatedContentHeight) / 2)
              .clamp(20.0, 36.0)
              .toDouble();

          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFFDDE7E1),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.24),
                  const Color(0xFFDDE7E1),
                ],
                stops: const [0.0, 0.24],
              ),
            ),
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        balancedInset,
                        horizontalPadding,
                        balancedInset + safeBottom,
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 450),
                          child: currentScreen == 'signup'
                              ? _SignUpForm(
                                  titleSize: titleSize,
                                  bodySize: bodySize,
                                  buttonHeight: buttonHeight,
                                  onBack: onBack,
                                )
                              : currentScreen == 'login'
                              ? _LoginForm(
                                  titleSize: titleSize,
                                  bodySize: bodySize,
                                  buttonHeight: buttonHeight,
                                  onBack: onBack,
                                )
                              : _ProfessionalForm(
                                  titleSize: titleSize,
                                  bodySize: bodySize,
                                  buttonHeight: buttonHeight,
                                  onBack: onBack,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.11),
                            Colors.white.withValues(alpha: 0.03),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BottomAttachedMainPanel extends StatelessWidget {
  const _BottomAttachedMainPanel({
    required this.buttonHeight,
    required this.bodySize,
    required this.onStartJourney,
    required this.onExistingAccount,
    required this.privacyRecognizer,
    required this.termsRecognizer,
    required this.psychiatristRecognizer,
  });

  final double buttonHeight;
  final double bodySize;
  final VoidCallback onStartJourney;
  final VoidCallback onExistingAccount;
  final TapGestureRecognizer privacyRecognizer;
  final TapGestureRecognizer termsRecognizer;
  final TapGestureRecognizer? psychiatristRecognizer;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final horizontalPadding = clampDouble(width * 0.06, 20, 24);
    final safeBottom = mediaQuery.padding.bottom;
    const verticalInset = 22.0;

    return Stack(
      children: [
        SizedBox.expand(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              verticalInset,
              horizontalPadding,
              verticalInset + safeBottom,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PrimaryActionButton(
                      height: buttonHeight,
                      onTap: onStartJourney,
                    ),
                    const SizedBox(height: 14),
                    _SecondaryActionButton(
                      height: buttonHeight,
                      onTap: onExistingAccount,
                    ),
                    const SizedBox(height: 22),
                    Text.rich(
                      TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: bodySize,
                          height: 1.55,
                          color: _LoginScreenState._softWhite.withValues(alpha: 0.7),
                        ),
                        children: [
                          const TextSpan(
                            text: 'By continuing, you agree to our ',
                          ),
                          TextSpan(
                            text: 'Privacy Policy',
                            recognizer: privacyRecognizer,
                            style: GoogleFonts.inter(
                              fontSize: bodySize,
                              height: 1.55,
                              fontWeight: FontWeight.w600,
                              color: _LoginScreenState._softWhite.withValues(alpha: 0.9),
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Terms of Service',
                            recognizer: termsRecognizer,
                            style: GoogleFonts.inter(
                              fontSize: bodySize,
                              height: 1.55,
                              fontWeight: FontWeight.w600,
                              color: _LoginScreenState._softWhite.withValues(alpha: 0.9),
                            ),
                          ),
                          const TextSpan(text: '. Are you a '),
                          TextSpan(
                            text: 'professional?',
                            recognizer: psychiatristRecognizer,
                            style: GoogleFonts.inter(
                              fontSize: bodySize,
                              height: 1.55,
                              fontWeight: FontWeight.w600,
                              color: _LoginScreenState._softWhite.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.11),
                    Colors.white.withValues(alpha: 0.03),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthFormHeader extends StatelessWidget {
  const _AuthFormHeader({
    required this.title,
    required this.titleSize,
    required this.onBack,
  });

  final String title;
  final double titleSize;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    const headerColor = Color(0xFF315A53);

    return SizedBox(
      height: 30,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onBack,
              child: Icon(
                Icons.arrow_back,
                color: headerColor.withValues(alpha: 0.82),
                size: 22,
              ),
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Doto',
              fontSize: titleSize * 0.76,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.15,
              color: headerColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthInputField extends StatefulWidget {
  const _AuthInputField({
    required this.controller,
    required this.label,
    required this.bodySize,
    this.obscureText = false,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final double bodySize;
  final bool obscureText;
  final String? Function(String?)? validator;

  @override
  State<_AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<_AuthInputField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    const fieldText = Color(0xFF3D6760);
    const fieldLabel = Color(0xFF6D8D87);
    const fieldFill = Color(0xFFEFF6F3);
    const fieldBorder = Color(0xFFC5D7D1);
    const fieldFocus = Color(0xFF8EB2AB);
    final shouldObscure = widget.obscureText && !_isPasswordVisible;

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: TextFormField(
        controller: widget.controller,
        obscureText: shouldObscure,
        validator: widget.validator,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: widget.bodySize * 0.93,
          color: fieldText,
          fontWeight: FontWeight.w400,
          height: 1.2,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: widget.bodySize * 0.88,
            color: fieldLabel,
            fontWeight: FontWeight.w400,
            height: 1.2,
          ),
          floatingLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF729891),
            fontWeight: FontWeight.w500,
          ),
          suffixIcon: widget.obscureText
              ? IconButton(
                  splashRadius: 20,
                  tooltip: _isPasswordVisible ? 'Hide password' : 'Show password',
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: const Color(0xFF4E7E76).withValues(alpha: 0.88),
                    size: 21,
                  ),
                )
              : null,
          filled: true,
          fillColor: fieldFill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: fieldBorder, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: fieldBorder, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: fieldFocus, width: 1.3),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFE74C3C),
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFE74C3C),
              width: 1.2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
          isDense: true,
        ),
      ),
    );
  }
}

class _AuthSubmitButton extends StatelessWidget {
  const _AuthSubmitButton({
    required this.text,
    required this.bodySize,
    required this.height,
    required this.onTap,
    this.isLoading = false,
  });

  final String text;
  final double bodySize;
  final double height;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    const submitTextColor = Color(0xFFE8F4F1);

    return SizedBox(
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4D9489), Color(0xFF3B7F75)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x243B7F75),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: const SnakeLoadingIndicator(),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      fontFamily: 'Doto',
                      fontSize: bodySize * 1.05,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      color: submitTextColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

void _showAuthErrorSnackbar(
  BuildContext context, {
  required String title,
  required String message,
}) {
  final messenger = ScaffoldMessenger.of(context);
  final media = MediaQuery.of(context);
  final maxWidth = math.min(media.size.width * 0.9, 600.0);
  final horizontalMargin = math.max(16.0, (media.size.width - maxWidth) * 0.5);
  final bottomMargin = 20.0 + media.viewPadding.bottom;

  messenger.hideCurrentSnackBar(reason: SnackBarClosedReason.hide);

  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    elevation: 0,
    duration: const Duration(milliseconds: 2800),
    dismissDirection: DismissDirection.down,
    margin: EdgeInsets.fromLTRB(horizontalMargin, 0, horizontalMargin, bottomMargin),
    padding: EdgeInsets.zero,
    content: ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFE4EEE9).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFFC5D7D1).withValues(alpha: 0.65),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2D726B).withValues(alpha: 0.18),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.error_outline,
                  size: 21,
                  color: Color(0xFF2D726B),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF244A44),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: Color(0xDD365A54),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  messenger.showSnackBar(
    snackBar,
    snackBarAnimationStyle: const AnimationStyle(
      duration: Duration(milliseconds: 250),
      reverseDuration: Duration(milliseconds: 220),
    ),
  );
}

class _StaggerReveal extends StatefulWidget {
  const _StaggerReveal({
    required this.child,
    required this.order,
  });

  final Widget child;
  final int order;

  @override
  State<_StaggerReveal> createState() => _StaggerRevealState();
}

class _StaggerRevealState extends State<_StaggerReveal> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(milliseconds: 70 + (widget.order * 65)), () {
      if (mounted) {
        setState(() {
          _visible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      opacity: _visible ? 1 : 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        offset: _visible ? Offset.zero : const Offset(0, 0.12),
        child: widget.child,
      ),
    );
  }
}

class _SignUpForm extends StatefulWidget {
  final double titleSize;
  final double bodySize;
  final double buttonHeight;
  final VoidCallback onBack;

  const _SignUpForm({
    required this.titleSize,
    required this.bodySize,
    required this.buttonHeight,
    required this.onBack,
  });

  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  final AuthService _authService = AuthService();
  final OnboardingService _onboardingService = OnboardingService();
  bool _isLoading = false;

  Future<void> _routeAfterSignup() async {
    final completed = await _onboardingService.isOnboardingCompleted();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            completed ? const HomeScreen() : const OnboardingFlowScreen(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StaggerReveal(
          order: 0,
          child: _AuthFormHeader(
            title: 'Create Account',
            titleSize: widget.titleSize,
            onBack: widget.onBack,
          ),
        ),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StaggerReveal(
                order: 1,
                child: _AuthInputField(
                  controller: _nameController,
                  label: 'Full Name',
                  bodySize: widget.bodySize,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Name required' : null,
                ),
              ),
              const SizedBox(height: 15),
              _StaggerReveal(
                order: 2,
                child: _AuthInputField(
                  controller: _emailController,
                  label: 'Email',
                  bodySize: widget.bodySize,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Email required';
                    if (!value!.contains('@')) return 'Valid email required';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 15),
              _StaggerReveal(
                order: 3,
                child: _AuthInputField(
                  controller: _passwordController,
                  label: 'Password',
                  bodySize: widget.bodySize,
                  obscureText: true,
                  validator: (value) => (value?.length ?? 0) < 6
                      ? 'Password must be 6+ characters'
                      : null,
                ),
              ),
              const SizedBox(height: 15),
              _StaggerReveal(
                order: 4,
                child: _AuthInputField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  bodySize: widget.bodySize,
                  obscureText: true,
                  validator: (value) => value != _passwordController.text
                      ? 'Passwords do not match'
                      : null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _StaggerReveal(
          order: 5,
          child: _AuthSubmitButton(
            text: 'Sign Up',
            bodySize: widget.bodySize,
            height: widget.buttonHeight,
            isLoading: _isLoading,
            onTap: () async {
              if (!_formKey.currentState!.validate()) {
                return;
              }
              setState(() {
                _isLoading = true;
              });

              final error = await runWithAuthFlowLoader<String?>(
                context: context,
                message: 'Creating your account...',
                action: () => _authService.registerGeneralUser(
                  name: _nameController.text.trim(),
                  email: _emailController.text.trim(),
                  password: _passwordController.text,
                ),
              );

              if (!mounted) {
                return;
              }

              setState(() {
                _isLoading = false;
              });

              if (error == null) {
                await _routeAfterSignup();
              } else {
                _showAuthErrorSnackbar(
                  context,
                  title: 'Sign up failed',
                  message: error,
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class _LoginForm extends StatefulWidget {
  final double titleSize;
  final double bodySize;
  final double buttonHeight;
  final VoidCallback onBack;

  const _LoginForm({
    required this.titleSize,
    required this.bodySize,
    required this.buttonHeight,
    required this.onBack,
  });

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final AuthService _authService = AuthService();
  final OnboardingService _onboardingService = OnboardingService();
  bool _isLoading = false;

  Future<void> _routeAfterLogin(String? role) async {
    if (role == 'psychiatrist') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PsychiatristScreen()),
      );
      return;
    }

    // Login for any other role (including 'user' and potentially 'admin')
    // should skip onboarding as per user request.
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StaggerReveal(
          order: 0,
          child: _AuthFormHeader(
            title: 'Welcome Back',
            titleSize: widget.titleSize,
            onBack: widget.onBack,
          ),
        ),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StaggerReveal(
                order: 1,
                child: _AuthInputField(
                  controller: _emailController,
                  label: 'Email or Username',
                  bodySize: widget.bodySize,
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Email/username required'
                      : null,
                ),
              ),
              const SizedBox(height: 15),
              _StaggerReveal(
                order: 2,
                child: _AuthInputField(
                  controller: _passwordController,
                  label: 'Password',
                  bodySize: widget.bodySize,
                  obscureText: true,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Password required' : null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _StaggerReveal(
          order: 3,
          child: _AuthSubmitButton(
            text: 'Login',
            bodySize: widget.bodySize,
            height: widget.buttonHeight,
            isLoading: _isLoading,
            onTap: () async {
              if (!_formKey.currentState!.validate()) {
                return;
              }
              setState(() {
                _isLoading = true;
              });

              final result = await runWithAuthFlowLoader<AuthResult>(
                context: context,
                message: 'Signing you in...',
                action: () => _authService.loginUser(
                  email: _emailController.text.trim(),
                  password: _passwordController.text,
                ),
              );

              if (!mounted) {
                return;
              }

              setState(() {
                _isLoading = false;
              });

              if (!result.success) {
                _showAuthErrorSnackbar(
                  context,
                  title: 'Login failed',
                  message: 'Invalid credentials. Please try again.',
                );
                return;
              }

              if (result.role == 'admin') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                );
              } else if (result.role == 'psychiatrist') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const PsychiatristScreen()),
                );
              } else {
                await _routeAfterLogin(result.role);
              }
            },
          ),
        ),
      ],
    );
  }
}

class _ProfessionalForm extends StatefulWidget {
  final double titleSize;
  final double bodySize;
  final double buttonHeight;
  final VoidCallback onBack;

  const _ProfessionalForm({
    required this.titleSize,
    required this.bodySize,
    required this.buttonHeight,
    required this.onBack,
  });

  @override
  State<_ProfessionalForm> createState() => _ProfessionalFormState();
}

class _ProfessionalFormState extends State<_ProfessionalForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _licenseController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _licenseController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _licenseController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StaggerReveal(
          order: 0,
          child: _AuthFormHeader(
            title: 'Professional Login',
            titleSize: widget.titleSize,
            onBack: widget.onBack,
          ),
        ),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StaggerReveal(
                order: 1,
                child: _AuthInputField(
                  controller: _nameController,
                  label: 'Full Name',
                  bodySize: widget.bodySize,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Name required' : null,
                ),
              ),
              const SizedBox(height: 15),
              _StaggerReveal(
                order: 2,
                child: _AuthInputField(
                  controller: _licenseController,
                  label: 'License Number',
                  bodySize: widget.bodySize,
                  validator: (value) => value?.isEmpty ?? true
                      ? 'License number required'
                      : null,
                ),
              ),
              const SizedBox(height: 15),
              _StaggerReveal(
                order: 3,
                child: _AuthInputField(
                  controller: _emailController,
                  label: 'Professional Email',
                  bodySize: widget.bodySize,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Email required';
                    if (!value!.contains('@')) return 'Valid email required';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 15),
              _StaggerReveal(
                order: 4,
                child: _AuthInputField(
                  controller: _passwordController,
                  label: 'Password',
                  bodySize: widget.bodySize,
                  obscureText: true,
                  validator: (value) => (value?.length ?? 0) < 6
                      ? 'Password must be 6+ characters'
                      : null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _StaggerReveal(
          order: 5,
          child: _AuthSubmitButton(
            text: 'Verify & Login',
            bodySize: widget.bodySize,
            height: widget.buttonHeight,
            isLoading: _isLoading,
            onTap: () async {
              if (!_formKey.currentState!.validate()) {
                return;
              }
              setState(() {
                _isLoading = true;
              });

              final error = await runWithAuthFlowLoader<String?>(
                context: context,
                message: 'Verifying professional profile...',
                action: () => _authService.registerProfessionalUser(
                  name: _nameController.text.trim(),
                  email: _emailController.text.trim(),
                  password: _passwordController.text,
                  licenseNumber: _licenseController.text.trim(),
                ),
              );

              if (!mounted) {
                return;
              }

              setState(() {
                _isLoading = false;
              });

              if (error == null) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const PsychiatristScreen()),
                );
              } else {
                _showAuthErrorSnackbar(
                  context,
                  title: 'Verification failed',
                  message: error,
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class _AmbientBackdrop extends StatelessWidget {
  const _AmbientBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -120,
          left: -60,
          child: _GlowOrb(
            size: 280,
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
        Positioned(
          top: 120,
          right: -80,
          child: _GlowOrb(
            size: 260,
            color: const Color(0xFFDFF9F1).withValues(alpha: 0.12),
          ),
        ),
        Positioned(
          bottom: -140,
          left: -50,
          child: _GlowOrb(
            size: 340,
            color: const Color(0xFF2A5A55).withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

class _FullScreenBackgroundImage extends StatelessWidget {
  const _FullScreenBackgroundImage();

  @override
  Widget build(BuildContext context) {
    final imageHeight = MediaQuery.of(context).size.height * 0.5;

    return Stack(
      children: [
        Image.asset(
          'assets/imgs/intro-bg.png',
          width: double.infinity,
          height: imageHeight,
          fit: BoxFit.cover,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 120,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xFF87AAA2).withValues(alpha: 0.22),
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AnimatedPet extends StatefulWidget {
  const AnimatedPet({
    super.key,
    required this.petSize,
    this.glow = false,
  });

  final double petSize;
  final bool glow;

  @override
  State<AnimatedPet> createState() => _AnimatedPetState();
}

class _AnimatedPetState extends State<AnimatedPet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final wave = math.sin(_floatController.value * 2 * math.pi);
        final yOffset = wave * 6.0;
        return Transform.translate(
          offset: Offset(0, yOffset),
          child: child,
        );
      },
      child: Container(
        decoration: widget.glow
            ? BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5CB6A5).withValues(alpha: 0.22),
                    blurRadius: 20,
                    spreadRadius: 1.5,
                  ),
                  BoxShadow(
                    color: const Color(0xFF2D726B).withValues(alpha: 0.16),
                    blurRadius: 30,
                    spreadRadius: 2.0,
                  ),
                ],
              )
            : null,
        child: Image.asset(
          'assets/imgs/new-cov.png',
          height: widget.petSize,
          width: widget.petSize,
          fit: BoxFit.contain,
          alignment: Alignment.center,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({required this.height, required this.onTap});

  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromRGBO(45, 114, 107, 1).withValues(alpha: 0.85),
                const Color.fromRGBO(24, 79, 75, 1).withValues(alpha: 0.85),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: const Color(0xFFB4FFF1).withValues(alpha: 0.25),
                blurRadius: 18,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: height,
                child: Center(
                  child: Text(
                    'Start Journey',
                    style: const TextStyle(
                      fontFamily: 'Doto',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({required this.height, required this.onTap});

  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Material(
          color: Colors.white.withValues(alpha: 0.12),
          child: InkWell(
            onTap: onTap,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 142, 192, 183).withValues(alpha: 0.1),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Already have an account?',
                  style: const TextStyle(
                    fontFamily: 'Doto',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2B7A63),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
