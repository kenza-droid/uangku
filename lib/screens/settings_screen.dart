import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../utils/notification_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: colorScheme.surfaceVariant,
          appBar: AppBar(
            title: const Text('Pengaturan',
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
          ),
          body: ListView(
            children: [
              // Profile
              Container(
                color: colorScheme.surface,
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: colorScheme.primary,
                      child: Text(
                        provider.userName.isNotEmpty
                            ? provider.userName[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(provider.userName,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface)),
                          Text('Pengguna Uangku',
                              style: TextStyle(
                                  color: colorScheme.outline, fontSize: 14)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: colorScheme.primary),
                      onPressed: () => _editName(context, provider),
                    ),
                  ],
                ),
              ),

              _sectionHeader('TAMPILAN', colorScheme),
              _themeTile(context, provider, colorScheme),

              _sectionHeader('NOTIFIKASI', colorScheme),
              _reminderTile(context, provider, colorScheme),

              _sectionHeader('KEUANGAN', colorScheme),
              _tile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Budget Bulanan',
                value: NumberFormat.currency(
                        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                    .format(provider.monthlyBudget),
                onTap: () => _editBudget(context, provider),
                cs: colorScheme,
              ),
              _tile(
                icon: Icons.bar_chart,
                title: 'Total Transaksi',
                value:
                    '${provider.transactions.length} transaksi',
                cs: colorScheme,
              ),

              _sectionHeader('AKUN', colorScheme),
              _tile(
                icon: Icons.payments_outlined,
                title: 'Mata Uang',
                value: 'IDR - Rupiah',
                cs: colorScheme,
              ),

              _sectionHeader('DATA', colorScheme),
              _tile(
                icon: Icons.delete_outline,
                title: 'Hapus Semua Data',
                value: '',
                isDestructive: true,
                onTap: () => _confirmClearAll(context, provider),
                cs: colorScheme,
              ),

              _sectionHeader('TENTANG', colorScheme),
              _tile(
                  icon: Icons.info_outline,
                  title: 'Versi Aplikasi',
                  value: 'v1.2.6',
                  cs: colorScheme),

              const SizedBox(height: 48),
              Center(
                child: Text(
                  'UANGKU V1.2.6',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.outline,
                      letterSpacing: 2),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String title, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(title,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: cs.outline,
              letterSpacing: 1.5)),
    );
  }

  Widget _themeTile(
      BuildContext context, TransactionProvider provider, ColorScheme cs) {
    String themeName;
    IconData themeIcon;
    switch (provider.themeMode) {
      case ThemeMode.light:
        themeName = 'Terang';
        themeIcon = Icons.light_mode;
        break;
      case ThemeMode.dark:
        themeName = 'Gelap';
        themeIcon = Icons.dark_mode;
        break;
      default:
        themeName = 'Sistem';
        themeIcon = Icons.brightness_auto;
    }

    return Container(
      color: cs.surface,
      child: ListTile(
        leading: Icon(themeIcon, color: cs.outline, size: 22),
        title: Text('Tema Aplikasi',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: cs.onSurface)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(themeName,
                style: TextStyle(
                    fontSize: 14,
                    color: cs.primary,
                    fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 16, color: cs.outline),
          ],
        ),
        onTap: () => _showThemePicker(context, provider, cs),
        shape: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
    );
  }

  Future<void> _showThemePicker(
      BuildContext context, TransactionProvider provider, ColorScheme cs) async {
    final picked = await showModalBottomSheet<ThemeMode>(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Pilih Tema',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: cs.onSurface)),
            ),
            Divider(height: 1, color: cs.outlineVariant),
            _themeOption(ctx, Icons.brightness_auto, 'Ikuti Sistem',
                'Otomatis menyesuaikan tema perangkat',
                ThemeMode.system, provider.themeMode, cs),
            _themeOption(ctx, Icons.light_mode, 'Mode Terang',
                'Tampilan terang untuk penggunaan siang hari',
                ThemeMode.light, provider.themeMode, cs),
            _themeOption(ctx, Icons.dark_mode, 'Mode Gelap',
                'Tampilan gelap yang nyaman untuk mata',
                ThemeMode.dark, provider.themeMode, cs),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked != null) {
      provider.setThemeMode(picked);
    }
  }

  Widget _themeOption(BuildContext ctx, IconData icon, String title,
      String subtitle, ThemeMode mode, ThemeMode current, ColorScheme cs) {
    final isSelected = mode == current;
    return ListTile(
      leading: Icon(icon,
          color: isSelected ? cs.primary : cs.outline),
      title: Text(title,
          style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: cs.onSurface)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12, color: cs.outline)),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: cs.primary)
          : null,
      onTap: () => Navigator.pop(ctx, mode),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String value,
    required ColorScheme cs,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final textColor = isDestructive ? cs.error : cs.onSurface;
    final iconColor = isDestructive ? cs.error : cs.outline;
    return Container(
      color: cs.surface,
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 22),
        title: Text(title,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value.isNotEmpty)
              Text(value,
                  style: TextStyle(
                      fontSize: 14,
                      color: cs.primary,
                      fontWeight: FontWeight.w500)),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 16, color: cs.outline),
            ]
          ],
        ),
        onTap: onTap,
        shape: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
    );
  }


  Widget _reminderTile(
      BuildContext context, TransactionProvider provider, ColorScheme cs) {
    final timeStr = '${provider.reminderHour.toString().padLeft(2, '0')}:${provider.reminderMinute.toString().padLeft(2, '0')}';
    
    return Container(
      color: cs.surface,
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.notifications_active_outlined, color: cs.outline, size: 22),
            title: Text('Pengingat Harian',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface)),
            subtitle: Text('Ingatkan saya untuk mencatat transaksi',
                style: TextStyle(fontSize: 12, color: cs.outline)),
            trailing: Switch(
              value: provider.reminderEnabled,
              onChanged: (val) {
                // Update UI first
                provider.setReminder(val, provider.reminderHour, provider.reminderMinute);
                
                // Then handle notification in background
                if (val) {
                  NotificationService().scheduleDailyReminder(
                      provider.reminderHour, provider.reminderMinute);
                } else {
                  NotificationService().cancelReminder();
                }
              },
              activeColor: cs.primary,
            ),
            shape: Border(bottom: BorderSide(color: cs.outlineVariant)),
          ),
          if (provider.reminderEnabled)
            ListTile(
              leading: const SizedBox(width: 22), // indent
              title: Text('Waktu Pengingat',
                  style: TextStyle(
                      fontSize: 14,
                      color: cs.onSurface)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(timeStr,
                      style: TextStyle(
                          fontSize: 14,
                          color: cs.primary,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(width: 4),
                  Icon(Icons.access_time, size: 16, color: cs.outline),
                ],
              ),
              onTap: () => _selectTime(context, provider, cs),
              shape: Border(bottom: BorderSide(color: cs.outlineVariant)),
            ),
          ListTile(
            leading: const SizedBox(width: 22), // indent
            title: Text('Tes Kirim Notifikasi',
                style: TextStyle(
                    fontSize: 14,
                    color: cs.onSurface)),
            trailing: Icon(Icons.send_outlined, size: 16, color: cs.primary),
            onTap: () async {
              await NotificationService().showTestNotification();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mencoba mengirim notifikasi tes...')),
                );
              }
            },
            shape: Border(bottom: BorderSide(color: cs.outlineVariant)),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(
      BuildContext context, TransactionProvider provider, ColorScheme cs) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: provider.reminderHour, minute: provider.reminderMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: cs.copyWith(primary: cs.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Update UI first
      provider.setReminder(true, picked.hour, picked.minute);
      // Then schedule in background
      NotificationService().scheduleDailyReminder(picked.hour, picked.minute);
    }
  }

  Future<void> _editName(
      BuildContext context, TransactionProvider provider) async {
    final cs = Theme.of(context).colorScheme;
    final ctrl = TextEditingController(text: provider.userName);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text('Ubah Nama', style: TextStyle(color: cs.onSurface)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: TextStyle(color: cs.onSurface),
          decoration: InputDecoration(
              hintText: 'Nama kamu',
              hintStyle: TextStyle(color: cs.outline)),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('Simpan')),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      provider.setUserName(result.trim());
    }
  }

  Future<void> _editBudget(
      BuildContext context, TransactionProvider provider) async {
    final cs = Theme.of(context).colorScheme;
    final ctrl = TextEditingController(
        text: provider.monthlyBudget.toStringAsFixed(0));
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text('Budget Bulanan (Rp)',
            style: TextStyle(color: cs.onSurface)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          style: TextStyle(color: cs.onSurface),
          decoration: InputDecoration(
              prefixText: 'Rp ',
              hintText: '5000000',
              hintStyle: TextStyle(color: cs.outline)),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('Simpan')),
        ],
      ),
    );
    if (result != null) {
      final val = double.tryParse(result.replaceAll(',', '').replaceAll('.', ''));
      if (val != null && val > 0) {
        provider.setMonthlyBudget(val);
      }
    }
  }

  Future<void> _confirmClearAll(
      BuildContext context, TransactionProvider provider) async {
    final cs = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text('Hapus Semua Data?',
            style: TextStyle(color: cs.onSurface)),
        content: Text(
            'Semua transaksi akan dihapus permanen. Tindakan ini tidak bisa dibatalkan.',
            style: TextStyle(color: cs.onSurface)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Hapus Semua',
                  style: TextStyle(color: cs.error))),
        ],
      ),
    );
    if (confirmed == true) {
      final ids = provider.transactions.map((t) => t.id).toList();
      for (final id in ids) {
        await provider.deleteTransaction(id);
      }
    }
  }
}
