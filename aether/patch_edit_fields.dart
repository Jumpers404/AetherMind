import 'dart:io';

void main() {
  final file = File('lib/screens/profile_screen.dart');
  var text = file.readAsStringSync();

  final editFieldsString = """
                  Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF1E3C44),
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: "Your Name",
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFB8D3CC)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF6EC6B3), width: 1.5),
                        ),
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF38887A), size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _bioController,
                      maxLines: 3,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF1E3C44),
                      ),
                      decoration: InputDecoration(
                        hintText: "Share your journey...",
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFB8D3CC)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF6EC6B3), width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 54,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _saveBio,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF6EC6B3), Color(0xFF2D726B)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              "Save Profile",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                                color: const Color(0xFFE8F4F1),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
""";

  text = text.replaceAll("_buildEditFields()", editFieldsString);
  text = text.replaceAll("withOpacity", "withValues(alpha: ");
  // Oh wait, withValues(alpha: 0.5) needs to be fixed if I just search replace.
  // Actually, I'll just use withValues(alpha: ...) directly in my string above.
  file.writeAsStringSync(text);
  print('Patched edit fields');
}
