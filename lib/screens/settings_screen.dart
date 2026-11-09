import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import 'export_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _appVersion = '1.0.0';

  Future<void> _confirmReset(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset preferensi?'),
        content: const Text(
          'Tema akan dikembalikan ke "Ikuti sistem". '
          'Transaksi dan budget Anda tidak akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await settings.resetPreferences();
    messenger.showSnackBar(
      const SnackBar(content: Text('Preferensi dikembalikan ke bawaan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          const _SectionLabel('TAMPILAN'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tema aplikasi',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: Icon(Icons.brightness_auto),
                          label: Text('Sistem'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode),
                          label: Text('Terang'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode),
                          label: Text('Gelap'),
                        ),
                      ],
                      selected: {settings.themeMode},
                      onSelectionChanged: (s) => context
                          .read<SettingsProvider>()
                          .setThemeMode(s.first),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Card(
            child: _Item(
              icon: Icons.payments_outlined,
              color: Color(0xFF14B8A6),
              title: 'Mata uang',
              subtitle: 'Rupiah (IDR), contoh: Rp 15.000',
            ),
          ),
          const SizedBox(height: 12),
          const _SectionLabel('DATA'),
          Card(
            clipBehavior: Clip.antiAlias,
            child: _Item(
              icon: Icons.ios_share,
              color: scheme.primary,
              title: 'Ekspor laporan',
              subtitle: 'Simpan atau bagikan transaksi sebagai PDF/CSV',
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExportScreen()),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _SectionLabel('LAINNYA'),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _Item(
                  icon: Icons.restart_alt,
                  color: const Color(0xFFF59E0B),
                  title: 'Reset preferensi',
                  subtitle: 'Kembalikan tema ke bawaan',
                  onTap: () => _confirmReset(context),
                ),
                const Divider(height: 1, indent: 72),
                _Item(
                  icon: Icons.info_outline,
                  color: const Color(0xFF3B82F6),
                  title: 'Tentang DompetKu',
                  subtitle: 'Versi $_appVersion',
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'DompetKu',
                    applicationVersion: _appVersion,
                    applicationIcon:
                        const Icon(Icons.account_balance_wallet, size: 40),
                    children: const [
                      Text(
                        'Aplikasi pencatat pengeluaran pribadi. Semua data '
                        'disimpan di perangkat Anda dan tidak dikirim ke mana pun.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

/// Baris pengaturan dengan ikon berlatar warna.
class _Item extends StatelessWidget {
  const _Item({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: trailing,
    );
  }
}