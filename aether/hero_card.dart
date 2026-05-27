  Widget _buildHeroGlassCard() {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? "Explorer";
    final username = "@${(user?.email ?? 'user').split('@').first.toLowerCase()}";
    
    final savedSeed = _profileData?['avatar_seed'] ?? username;
    final seed = Uri.encodeComponent(savedSeed);
    final gender = _profileData?['gender'];
    
    String genderParams = "";
    if (gender == 'Male') {
      genderParams = "&hair=variant02,variant03,variant05,variant07,variant08,variant23,variant24,variant26";
    } else if (gender == 'Female') {
      genderParams = "&hair=variant01,variant04,variant09,variant10,variant11,variant12,variant13,variant14,variant15,variant16";
    }

    final avatarUrl = "https://api.dicebear.com/7.x/lorelei/svg?seed=$seed&backgroundColor=eaf7f2&baseColor=f3fbf8&hairColor=3b7f75&eyesColor=3b7f75&eyebrowsColor=3b7f75&mouthColor=3b7f75&accessoriesColor=3b7f75&skinColor=faf4ee&clothingColor=3b7f75&eyes=variant01,variant02&mouth=happy01,happy02$genderParams";

    return _buildGlassSection(
      title: "", // Hides the main title since we use a custom top
      isHero: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF7F2), // Light faint greenish base
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: SvgPicture.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        placeholderBuilder: (context) => Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF6EC6B3), Color(0xFF2D726B)],
                            ),
                          ),
                          child: const Icon(Icons.person_rounded, color: Colors.white, size: 50),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        // Toggle bio editing, or show avatar editor?
                        // Depending on state, either we show avatar choice or text edit.
                        // I'll leave the avatar editor tap as-is or combine. Wait, if it edits the bio...
                        // Let's make it toggle _isEditingBio
                        setState(() => _isEditingBio = !_isEditingBio);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D726B),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Doto',
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF244A44),
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      username,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF38887A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildSocialStatCol("${_profileData?['followers'] ?? 0}", "Followers"),
                        Container(
                          height: 24,
                          width: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          color: const Color(0xFFB8D3CC).withValues(alpha: 0.5),
                        ),
                        _buildSocialStatCol("${_profileData?['following'] ?? 0}", "Following"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _isEditingBio
              ? _buildEditFields()
              : _buildBioBox(),
        ],
      ),
    );
  }

  Widget _buildBioBox() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.format_quote_rounded,
            color: Color(0xFF8BBDA8),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _bioController.text.isEmpty ? "Click to add a bio about your journey..." : _bioController.text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF4A6862),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialStatCol(String count, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          count,
          style: GoogleFonts.poppins(
            color: const Color(0xFF1E3C44),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFF5F7380),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
