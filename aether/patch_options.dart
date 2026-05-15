class _OptionsMenuButton extends StatefulWidget {
  const _OptionsMenuButton({required this.onSignOut});
  final VoidCallback onSignOut;

  @override
  State<_OptionsMenuButton> createState() => _OptionsMenuButtonState();
}

class _OptionsMenuButtonState extends State<_OptionsMenuButton> {
  final _onboardingService = OnboardingService();
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    try {
      final data = await _onboardingService.getOnboardingProfile();
      if (data != null && mounted) {
        final user = FirebaseAuth.instance.currentUser;
        final username = "@${(user?.email ?? 'user').split('@').first.toLowerCase()}";
        final savedSeed = data['avatar_seed'] ?? username;
        final seed = Uri.encodeComponent(savedSeed);
        final gender = data['gender'];
        
        String genderParams = "";
        if (gender == 'Male') {
          genderParams = "&hair=variant02,variant03,variant05,variant07,variant08,variant23,variant24,variant26";
        } else if (gender == 'Female') {
          genderParams = "&hair=variant01,variant04,variant09,variant10,variant11,variant12,variant13,variant14,variant15,variant16";
        }

        final url = "https://api.dicebear.com/7.x/lorelei/svg?seed=$seed&backgroundColor=eaf7f2&baseColor=f3fbf8&hairColor=3b7f75&eyesColor=3b7f75&eyebrowsColor=3b7f75&mouthColor=3b7f75&accessoriesColor=3b7f75&skinColor=faf4ee&clothingColor=3b7f75&eyes=variant01,variant02&mouth=happy01,happy02$genderParams";
        setState(() {
          _avatarUrl = url;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.82),
                    Colors.white.withValues(alpha: 0.46),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.68),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _HomePalette.textPrimary.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: _HomePalette.accent.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  pushWithSnakeLoader(
                    context,
                    ProfileScreen(onSignOut: widget.onSignOut),
                  ).then((_) {
                    if (mounted) _loadAvatar();
                  });
                },
                child: Center(
                  child: _avatarUrl != null
                    ? SvgPicture.network(
                        _avatarUrl!,
                        width: 46,
                        height: 46,
                        fit: BoxFit.cover,
                        placeholderBuilder: (BuildContext context) => const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2FB07E)),
                      )
                    : const Icon(
                        Icons.person_rounded,
                        color: Color(0xFF2FB07E),
                        size: 22,
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
