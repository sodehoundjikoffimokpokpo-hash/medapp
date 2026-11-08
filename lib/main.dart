import 'package:flutter/material.dart';

// ─── Point d'entrée (pour tester seul) ───────────────────────────────────────
void main() {
  runApp(const KidShieldApp());
}

class KidShieldApp extends StatelessWidget {
  const KidShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KidShield',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const ProfilesScreen(),
    );
  }
}

// ─── Thème ────────────────────────────────────────────────────────────────────
class AppTheme {
  static const Color primary = Color(0xFF534AB7);
  static const Color primaryDark = Color(0xFF3C3489);
  static const Color success = Color(0xFF1D9E75);
  static const Color danger = Color(0xFFE24B4A);
  static const Color surface = Color(0xFFF8F7FF);
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B6B8A);
  static const Color border = Color(0xFFE4E2F0);

  static ThemeData light() => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: primary,
    scaffoldBackgroundColor: surface,
    fontFamily: 'Poppins', // remplace par ta police préférée
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
  );
}

// ─── Modèle de données ────────────────────────────────────────────────────────
class ChildProfile {
  final String id;
  final String name;
  final int age;
  final String grade;
  final Color avatarColor;
  final bool isProtected;
  final int blockedToday;
  final int screenTimeMinutes;
  final int maxScreenTimeMinutes;

  const ChildProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.grade,
    required this.avatarColor,
    this.isProtected = true,
    this.blockedToday = 0,
    this.screenTimeMinutes = 0,
    this.maxScreenTimeMinutes = 120,
  });

  String get initials => name.length >= 2
      ? '${name[0]}${name[1]}'.toUpperCase()
      : name[0].toUpperCase();

  double get screenTimeRatio =>
      (screenTimeMinutes / maxScreenTimeMinutes).clamp(0.0, 1.0);
}

// ─── Données factices ─────────────────────────────────────────────────────────
final List<ChildProfile> sampleProfiles = [
  const ChildProfile(
    id: '1',
    name: 'Amara',
    age: 8,
    grade: 'CM1',
    avatarColor: Color(0xFF534AB7),
    isProtected: true,
    blockedToday: 3,
    screenTimeMinutes: 84,
    maxScreenTimeMinutes: 120,
  ),
  const ChildProfile(
    id: '2',
    name: 'Koffi',
    age: 12,
    grade: '5ème',
    avatarColor: Color(0xFF0F6E56),
    isProtected: true,
    blockedToday: 1,
    screenTimeMinutes: 105,
    maxScreenTimeMinutes: 180,
  ),
];

// ─── Écran principal : liste des profils ─────────────────────────────────────
class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({super.key});

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  List<ChildProfile> profiles = List.from(sampleProfiles);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shield_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('KidShield',
                    style:
                    TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                Text('Contrôle parental',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w400)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Bannière de statut global
          _GlobalStatusBanner(profiles: profiles),
          const SizedBox(height: 24),

          // Titre section profils
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Profils enfants',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
              Text('${profiles.length} profil(s)',
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 14),

          // Liste des profils
          ...profiles.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _ProfileCard(
              profile: p,
              onTap: () => _openProfile(p),
            ),
          )),

          // Bouton ajouter
          _AddProfileButton(onTap: _showAddProfileDialog),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _openProfile(ChildProfile profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileDetailScreen(profile: profile),
      ),
    );
  }

  void _showAddProfileDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => AddProfileSheet(
        onAdd: (newProfile) {
          setState(() => profiles.add(newProfile));
        },
      ),
    );
  }
}

// ─── Bannière statut global ───────────────────────────────────────────────────
class _GlobalStatusBanner extends StatelessWidget {
  final List<ChildProfile> profiles;
  const _GlobalStatusBanner({required this.profiles});

  @override
  Widget build(BuildContext context) {
    final totalBlocked = profiles.fold(0, (s, p) => s + p.blockedToday);
    final allProtected = profiles.every((p) => p.isProtected);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              allProtected
                  ? Icons.verified_user_rounded
                  : Icons.warning_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allProtected
                      ? 'Tous les enfants protégés'
                      : 'Attention requise',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15),
                ),
                const SizedBox(height: 3),
                Text(
                  '$totalBlocked site(s) bloqué(s) aujourd\'hui',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8), fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              allProtected ? 'Actif' : 'Vérifier',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Carte profil ─────────────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final ChildProfile profile;
  final VoidCallback onTap;
  const _ProfileCard({required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: profile.avatarColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      profile.initials,
                      style: TextStyle(
                          color: profile.avatarColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Infos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.name,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary)),
                      Text('${profile.age} ans · ${profile.grade}',
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                // Statut
                _StatusBadge(isProtected: profile.isProtected),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right,
                    color: AppTheme.textSecondary, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            // Temps d'écran
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Temps d\'écran',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                    Text(
                      '${profile.screenTimeMinutes ~/ 60}h${profile.screenTimeMinutes % 60}min / ${profile.maxScreenTimeMinutes ~/ 60}h',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: profile.screenTimeRatio > 0.85
                              ? AppTheme.danger
                              : AppTheme.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: profile.screenTimeRatio,
                    minHeight: 6,
                    backgroundColor: AppTheme.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      profile.screenTimeRatio > 0.85
                          ? AppTheme.danger
                          : AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Stats du bas
            Row(
              children: [
                _StatChip(
                  icon: Icons.block_rounded,
                  label: '${profile.blockedToday} bloqué(s)',
                  color: AppTheme.danger,
                ),
                const SizedBox(width: 10),
                _StatChip(
                  icon: Icons.shield_rounded,
                  label: 'Protection active',
                  color: AppTheme.success,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isProtected;
  const _StatusBadge({required this.isProtected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isProtected
            ? AppTheme.success.withOpacity(0.1)
            : AppTheme.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isProtected ? AppTheme.success : AppTheme.danger,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isProtected ? 'Protégé' : 'Inactif',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isProtected ? AppTheme.success : AppTheme.danger),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── Bouton ajouter profil ────────────────────────────────────────────────────
class _AddProfileButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddProfileButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppTheme.primary.withOpacity(0.3),
              width: 1.5,
              style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add_rounded,
                  color: AppTheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Ajouter un profil enfant',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary)),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom sheet : Ajouter un profil ────────────────────────────────────────
class AddProfileSheet extends StatefulWidget {
  final Function(ChildProfile) onAdd;
  const AddProfileSheet({super.key, required this.onAdd});

  @override
  State<AddProfileSheet> createState() => _AddProfileSheetState();
}

class _AddProfileSheetState extends State<AddProfileSheet> {
  final _nameController = TextEditingController();
  int _age = 8;
  final _gradeController = TextEditingController();
  Color _selectedColor = AppTheme.primary;

  final List<Color> _colors = [
    const Color(0xFF534AB7),
    const Color(0xFF0F6E56),
    const Color(0xFFD85A30),
    const Color(0xFF185FA5),
    const Color(0xFF993556),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poignée
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Nouveau profil',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),

          // Choix couleur avatar
          const Text('Couleur avatar',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 10),
          Row(
            children: _colors.map((c) {
              final selected = c == _selectedColor;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = c),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: selected
                        ? [BoxShadow(color: c.withOpacity(0.5), blurRadius: 8)]
                        : null,
                  ),
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // Prénom
          _InputField(
            label: 'Prénom',
            controller: _nameController,
            hint: 'ex: Amara',
          ),
          const SizedBox(height: 14),

          // Âge
          Row(
            children: [
              const Expanded(
                  child: Text('Âge',
                      style: TextStyle(
                          fontSize: 13, color: AppTheme.textSecondary))),
              IconButton(
                onPressed: () =>
                    setState(() => _age = (_age - 1).clamp(3, 17)),
                icon: const Icon(Icons.remove_circle_outline),
                color: AppTheme.primary,
              ),
              Text('$_age ans',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              IconButton(
                onPressed: () =>
                    setState(() => _age = (_age + 1).clamp(3, 17)),
                icon: const Icon(Icons.add_circle_outline),
                color: AppTheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Classe
          _InputField(
            label: 'Classe',
            controller: _gradeController,
            hint: 'ex: CM1, 5ème',
          ),
          const SizedBox(height: 24),

          // Bouton créer
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _createProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Créer le profil',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _createProfile() {
    if (_nameController.text.trim().isEmpty) return;
    final profile = ChildProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      age: _age,
      grade: _gradeController.text.trim().isEmpty
          ? 'Non renseigné'
          : _gradeController.text.trim(),
      avatarColor: _selectedColor,
    );
    widget.onAdd(profile);
    Navigator.pop(context);
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  const _InputField(
      {required this.label,
        required this.controller,
        required this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: AppTheme.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.textSecondary),
            filled: true,
            fillColor: AppTheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}

// ─── Écran détail d'un profil ─────────────────────────────────────────────────
class ProfileDetailScreen extends StatelessWidget {
  final ChildProfile profile;
  const ProfileDetailScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text(profile.name),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // En-tête profil
          _ProfileHeader(profile: profile),
          const SizedBox(height: 24),

          // Raccourcis rapides
          const Text('Gestion rapide',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          _QuickActionsGrid(profile: profile),
          const SizedBox(height: 24),

          // Activité récente
          const Text('Activité récente',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          _RecentActivity(),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final ChildProfile profile;
  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 0.8),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: profile.avatarColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                profile.initials,
                style: TextStyle(
                    color: profile.avatarColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(profile.name,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          Text('${profile.age} ans · ${profile.grade}',
              style: const TextStyle(
                  fontSize: 14, color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _HeaderStat('Sites bloqués', '${profile.blockedToday}',
                  AppTheme.danger),
              Container(width: 1, height: 40, color: AppTheme.border),
              _HeaderStat(
                  'Temps d\'écran',
                  '${profile.screenTimeMinutes ~/ 60}h${profile.screenTimeMinutes % 60}m',
                  AppTheme.primary),
              Container(width: 1, height: 40, color: AppTheme.border),
              _HeaderStat('Statut', 'Protégé', AppTheme.success),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _HeaderStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final ChildProfile profile;
  const _QuickActionsGrid({required this.profile});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {'icon': Icons.shield_outlined, 'label': 'Filtres', 'color': AppTheme.primary},
      {'icon': Icons.access_time_rounded, 'label': 'Temps', 'color': AppTheme.success},
      {'icon': Icons.bar_chart_rounded, 'label': 'Rapports', 'color': const Color(0xFF185FA5)},
      {'icon': Icons.lock_outline_rounded, 'label': 'Verrouiller', 'color': AppTheme.danger},
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      children: actions
          .map((a) => _QuickAction(
        icon: a['icon'] as IconData,
        label: a['label'] as String,
        color: a['color'] as Color,
        onTap: () {},
      ))
          .toList(),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon,
        required this.label,
        required this.color,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  final List<Map<String, dynamic>> _events = const [
    {
      'site': 'youtube.com',
      'time': 'Il y a 12 min',
      'blocked': false,
      'duration': '18 min'
    },
    {
      'site': 'site-adulte.com',
      'time': 'Il y a 34 min',
      'blocked': true,
      'duration': null
    },
    {
      'site': 'khanacademy.org',
      'time': 'Il y a 1h',
      'blocked': false,
      'duration': '42 min'
    },
    {
      'site': 'tiktok.com',
      'time': 'Il y a 2h',
      'blocked': true,
      'duration': null
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 0.8),
      ),
      child: Column(
        children: _events.asMap().entries.map((entry) {
          final i = entry.key;
          final e = entry.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: (e['blocked'] as bool)
                            ? AppTheme.danger.withOpacity(0.1)
                            : AppTheme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        (e['blocked'] as bool)
                            ? Icons.block_rounded
                            : Icons.check_circle_outline_rounded,
                        color: (e['blocked'] as bool)
                            ? AppTheme.danger
                            : AppTheme.success,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e['site'] as String,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary)),
                          Text(e['time'] as String,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                    Text(
                      (e['blocked'] as bool)
                          ? 'Bloqué'
                          : e['duration'] as String,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: (e['blocked'] as bool)
                              ? AppTheme.danger
                              : AppTheme.success),
                    ),
                  ],
                ),
              ),
              if (i < _events.length - 1)
                Divider(height: 1, color: AppTheme.border),
            ],
          );
        }).toList(),
      ),
    );
  }
}