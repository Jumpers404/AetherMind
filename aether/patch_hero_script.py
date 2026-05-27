import re

with open("lib/screens/profile_screen.dart", "r") as f:
    text = f.read()

old_hero_start = text.find("  Widget _buildHeroGlassCard() {")
old_hero_end = text.find("  Widget _buildMiniSocialStat(", old_hero_start)

if old_hero_start != -1 and old_hero_end != -1:
    old_hero_full = text[old_hero_start:old_hero_end]

    with open("hero_card.dart", "r") as f:
        new_hero = f.read()
    
    new_text = text.replace(old_hero_full, new_hero)
    with open("lib/screens/profile_screen.dart", "w") as f:
        f.write(new_text)
    print("Replaced successfully")
else:
    print("Could not find bounds")
