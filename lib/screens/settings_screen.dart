import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF4F4F4),
          appBar: AppBar(
            title: const Text('Pengaturan',
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
          ),
          body: ListView(
            children: [
              // Profile
              Container(
                color: Colors.white,
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
                        style: const TextStyle(
                            color: Colors.white,
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
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const Text('Pengguna Uangku',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 14)),
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

              _sectionHeader('KEUANGAN'),
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

              _sectionHeader('AKUN'),
              _tile(
                icon: Icons.payments_outlined,
                title: 'Mata Uang',
                value: 'IDR - Rupiah',
                cs: colorScheme,
              ),

              _sectionHeader('DATA'),
              _tile(
                icon: Icons.delete_outline,
                title: 'Hapus Semua Data',
                value: '',
                isDestructive: true,
                onTap: () => _confirmClearAll(context, provider),
                cs: colorScheme,
              ),

              _sectionHeader('TENTANG'),
              _tile(
                  icon: Icons.info_outline,
                  title: 'Versi Aplikasi',
                  value: 'v1.0.0',
                  cs: colorScheme),

              const SizedBox(height: 48),
              const Center(
                child: Text(
                  'UANGKU V1.0.0',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
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

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(title,
          style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.5)),
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
    final textColor = isDestructive ? cs.error : const Color(0xFF161616);
    final iconColor = isDestructive ? cs.error : Colors.grey;
    return Container(
      color: Colors.white,
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
              const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            ]
          ],
        ),
        onTap: onTap,
        shape: const Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
      ),
    );
  }

  Future<void> _editName(
      BuildContext context, TransactionProvider provider) async {
    final ctrl = TextEditingController(text: provider.userName);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah Nama'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nama kamu'),
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
    final ctrl = TextEditingController(
        text: provider.monthlyBudget.toStringAsFixed(0));
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Budget Bulanan (Rp)'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              prefixText: 'Rp ', hintText: '5000000'),
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
        title: const Text('Hapus Semua Data?'),
        content: const Text(
            'Semua transaksi akan dihapus permanen. Tindakan ini tidak bisa dibatalkan.'),
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
