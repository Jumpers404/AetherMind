import 'dart:io';

void main() {
  final file = File('lib/screens/profile_screen.dart');
  var code = file.readAsStringSync();

  final startStr = '  Widget _buildHeroGlassCard() {';
  final endStr = '  Widget _buildSocialStatCol(String count, String label) {';
  
  final startIndex = code.indexOf(startStr);
  final endIndex = code.indexOf(endStr);
  
  if (startIndex == -1 || endIndex == -1) {
    print('Failed to locate _buildHeroGlassCard');
    return;
  }
  
  final originalBlock = code.substring(startIndex, endIndex);

  // We are going to replace this block. We'll build a completely new _buildHeroGlassCard.
  final newBlock = '''
  Widget _buildHeroGlassCard() {
    final user = FirebaseAuth.instance.currentUser;
    final fallbackName = user?.displayName ?? "Explorer";
    final fallbackUsername = "@\${(user?.email ?? 'user').split('@').first.toLowerCase()}";
    
    // Ensure controllers have initial values if empty
    if (_nameController.text.isEmpty && fallbackName.isNotEmpty) {
      _nameController.text = fallbackName;
    }
    
    final savedSeed = _profileData?['avatar_seed'] ?? fallbackUsername;
    final seed = Uri.encodeComponent(savedSeed);
    final gender = _profileData?['gender'];
    
    String genderParams = "";
    if (gender == 'Male') {
      genderParams = "&hair=variant02,variant03,variant05,variant07,variant08,variant23,variant24,variant26";
    } else if (gender == 'Female') {
      genderParams = "&hair=variant01,variant04,variant09,variant10,variant11,variant12,variant13,variant14,variant15,variant16";
    }

    final avatarUrl = "https://api.dicebear.com/7.x/lorelei/svg?seed=\$seed&backgroundColor=eaf7f2&baseColor=f3fbf8&hairColor=3b7f75&eyesColor=3b7f75&eyebrowsColor=3b7f75&mouthColor=3b7f75&accessoriesColor=3b7f75&skinColor=faf4ee&clothingColor=3b7f75&eyes=variant01,variant02&mouth=happy01,happy02\$genderParams";

    return _buildGlassSection(
      title: "",
      isHero: true,
      child: Stack(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAF7F2),
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(80),
                      child: GestureDetector(
                        onTap: () => _isEditingBio ? _showAvatarGenderSelector() : null,
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
                            child: const Icon(Icons.person_rounded, color: Colors.white, size: 40),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_isEditingBio)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D726B),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _isEditingBio 
                      ? TextField(
                          controller: _nameController,
                          style: const TextStyle(
                            fontFamily: 'Doto',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF244A44),
                            letterSpacing: -0.5,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 4),
                            border: InputBorder.none,
                            hintText: "Your Name",
                          ),
                        )
                      : Text(
                          _nameController.text.isNotEmpty ? _nameController.text : fallbackName,
                          style: const TextStyle(
                            fontFamily: 'Doto',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF244A44),
                            letterSpacing: -0.5,
                          ),
                        ),
                    const SizedBox(height: 2),
                    Text(
                      fallbackUsername,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF38887A).withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildSocialStatCol("\${_profileData?['followers'] ?? 0}", "Followers"),
                        Container(
                          height: 20,
                          width: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          color: const Color(0xFF38887A).withValues(alpha: 0.3),
                        ),
                        _buildSocialStatCol("\${_profileData?['following'] ?? 0}", "Following"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                setState(() => _isEditingBio = !_isEditingBio);
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _isEditingBio ? const Color(0xFF4DA692) : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isEditingBio ? Colors.transparent : const Color(0xFF4DA692).withValues(alpha: 0.5),
                  ),
                ),
                child: Icon(
                  _isEditingBio ? Icons.check_rounded : Icons.edit_rounded,
                  color: _isEditingBio ? Colors.white : const Color(0xFF4DA692),
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

''';

  code = code.substring(0, startIndex) + newBlock + code.substring(endIndex);
  file.writeAsStringSync(code);
  print('Replaced hero card');
}
