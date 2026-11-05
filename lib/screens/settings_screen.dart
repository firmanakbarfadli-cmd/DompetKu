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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tema', style: textTheme.titleMedium),
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
                    onSelectionChanged: (s) =>
                        context.read<SettingsProvider>().setThemeMode(s.first),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.payments_outlined),
            title: Text('Mata uang'),
            subtitle: Text('Rupiah (IDR), contoh: Rp 15.000'),
          ),
          ListTile(
            leading: const Icon(Icons.ios_share),
            title: const Text('Ekspor laporan'),
            subtitle:
                const Text('Simpan atau bagikan transaksi sebagai PDF/CSV'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ExportScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.restart_alt),
            title: const Text('Reset preferensi'),
            subtitle: const Text('Kembalikan tema ke bawaan'),
            onTap: () => _confirmReset(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Tentang DompetKu'),
            subtitle: const Text('Versi $_appVersion'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'DompetKu',
              applicationVersion: _appVersion,
              applicationIcon: const Icon(Icons.account_balance_wallet, size: 40),
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
    );
  }
}