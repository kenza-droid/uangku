import 'dart:math' show max, min, pi;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import 'add_transaction_screen.dart';
import '../utils/transitions.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _fmt(double v) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
          .format(v);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final balance = provider.totalBalance;
        final income = provider.monthlyIncome;
        final expense = provider.monthlyExpense;
        final budgetRatio = provider.monthlyBudget > 0
            ? (expense / provider.monthlyBudget).clamp(0.0, 1.0)
            : 0.0;
        final budgetPct = (budgetRatio * 100).toStringAsFixed(0);
        final budgetColor = budgetRatio < 0.7
            ? cs.tertiary
            : budgetRatio < 0.9
                ? Colors.orange
                : cs.error;

        // sorted categories
        final catEntries = provider.monthlyExpenseByCategory.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Scaffold(
          backgroundColor: cs.surface,
          appBar: AppBar(
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset(
                    Theme.of(context).brightness == Brightness.dark
                        ? 'assets/gelap.png'
                        : 'assets/terang.png',
                    width: 32,
                    height: 32,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Uangku',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: cs.onSurface)),
                      Text(
                          DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now()),
                          style: TextStyle(
                              fontSize: 11, color: cs.outline)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [cs.primary, cs.primary.withOpacity(0.8)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                      borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SALDO SAAT INI',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      Text(_fmt(balance),
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: _miniStat(
                                  'Pemasukan', _fmt(income), Icons.arrow_upward, cs)),
                          const SizedBox(width: 16),
                          Expanded(
                              child: _miniStat('Pengeluaran', _fmt(expense),
                                  Icons.arrow_downward, cs)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Budget progress
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                      border: Border.all(color: cs.outlineVariant)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('BUDGET BULANAN',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: cs.outline,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1)),
                          Text('$budgetPct%',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: budgetColor,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: budgetRatio,
                          backgroundColor: cs.outlineVariant,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(budgetColor),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                          '${_fmt(expense)} dari ${_fmt(provider.monthlyBudget)}',
                          style: TextStyle(
                              fontSize: 12, color: cs.outline, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Early Warning System Card
                _buildEWS(provider, cs),

                const SizedBox(height: 32),

                // Weekly chart
                Text('Pengeluaran Mingguan',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 140,
                        child: _WeeklyBarChart(
                            data: provider.weeklyExpenses,
                            color: cs.primary,
                            bgColor: cs.primary.withOpacity(0.05)),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: ['Mg 1', 'Mg 2', 'Mg 3', 'Mg 4', 'Mg 5']
                            .map((w) => Text(w,
                                style: TextStyle(
                                    fontSize: 10, 
                                    fontWeight: FontWeight.w600,
                                    color: cs.outline)))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Income vs Expense chart
                Text('Pemasukan vs Pengeluaran (6 Bulan)',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _legend('Masuk', cs.primary, cs),
                          const SizedBox(width: 12),
                          _legend('Keluar', cs.error, cs),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 140,
                        child: _GroupedBarChart(
                          data: provider.last6MonthsData,
                          incomeColor: cs.primary,
                          expenseColor: cs.error,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _monthLabels(cs),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Category breakdown
                if (catEntries.isNotEmpty) ...[
                  Text('Analisis Kategori',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 180,
                          child: _CategoryDonutChart(
                            entries: catEntries,
                            total: expense,
                            cs: cs,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ...catEntries.take(4).map(
                              (e) => _categoryRow(e.key, e.value, expense, cs),
                            ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Recent
                Text('Transaksi Terbaru',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface)),
                const SizedBox(height: 8),
                provider.recentTransactions.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.receipt_long_outlined,
                                  size: 48, color: cs.outline),
                              const SizedBox(height: 8),
                              Text('Belum ada transaksi',
                                  style: TextStyle(color: cs.outline)),
                              Text('Tambahkan transaksi pertamamu!',
                                  style: TextStyle(
                                      color: cs.outline, fontSize: 12)),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: provider.recentTransactions
                            .map((t) => _txRow(t, cs, context))
                            .toList(),
                      ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEWS(TransactionProvider provider, ColorScheme cs) {
    final status = provider.financialStatus;
    final advice = provider.financialAdvice;
    
    Color statusColor;
    IconData statusIcon;
    Color bgColor;

    switch (status) {
      case 'BAHAYA':
        statusColor = cs.error;
        statusIcon = Icons.report_problem_rounded;
        bgColor = cs.error.withOpacity(0.1);
        break;
      case 'WASPADA':
        statusColor = Colors.orange;
        statusIcon = Icons.warning_amber_rounded;
        bgColor = Colors.orange.withOpacity(0.1);
        break;
      default:
        statusColor = cs.tertiary;
        statusIcon = Icons.check_circle_outline_rounded;
        bgColor = cs.tertiary.withOpacity(0.1);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('EARLY WARNING SYSTEM',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                            letterSpacing: 1.2)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(status,
                          style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(advice,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurface.withOpacity(0.8))),
                if (provider.remainingDailyBudget > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.savings_outlined, size: 14, color: statusColor),
                        const SizedBox(width: 8),
                        Text(
                          'Jatah harian: ',
                          style: TextStyle(fontSize: 11, color: cs.onSurface.withOpacity(0.6)),
                        ),
                        Text(
                          NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                              .format(provider.remainingDailyBudget),
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, IconData icon, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 12, color: cs.onPrimary.withOpacity(0.7)),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: cs.onPrimary.withOpacity(0.7))),
        ]),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: cs.onPrimary),
            overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _legend(String label, Color color, ColorScheme cs) {
    return Row(children: [
      Container(width: 10, height: 10, color: color),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 11, color: cs.outline)),
    ]);
  }

  Widget _monthLabels(ColorScheme cs) {
    final now = DateTime.now();
    final months = List.generate(
        6, (i) => DateFormat('MMM', 'id_ID').format(DateTime(now.year, now.month - 5 + i)));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: months
          .map((m) =>
              Text(m, style: TextStyle(fontSize: 10, color: cs.outline)))
          .toList(),
    );
  }

  Widget _categoryRow(
      String cat, double amount, double total, ColorScheme cs) {
    final pct = total > 0 ? (amount / total).clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration:
              BoxDecoration(color: cs.surfaceVariant),
          child:
              Icon(Transaction.categoryIcon(cat), size: 18, color: cs.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(cat,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: cs.onSurface)),
              Text(
                  NumberFormat.currency(
                          locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                      .format(amount),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: cs.error)),
            ]),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: cs.outlineVariant,
                valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                minHeight: 3,
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _txRow(Transaction t, ColorScheme cs, BuildContext context) {
    final fmt =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          SlideUpRoute(page: AddTransactionScreen(editTransaction: t)),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: cs.outlineVariant.withOpacity(0.5)))),
        child: Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: cs.surfaceVariant),
            child: Icon(Transaction.categoryIcon(t.category),
                size: 18, color: cs.onSurface),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: cs.onSurface)),
              Text(DateFormat('dd MMM, HH:mm', 'id_ID').format(t.date),
                  style: TextStyle(color: cs.outline, fontSize: 12)),
            ]),
          ),
          Text(
            '${t.isExpense ? '-' : '+'}${fmt.format(t.amount)}',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: t.isExpense ? cs.error : cs.tertiary,
                fontSize: 14),
          ),
        ]),
      ),
    );
  }
}

// ── Custom Charts ─────────────────────────────────────────────────────────────

class _CategoryDonutChart extends StatelessWidget {
  final List<MapEntry<String, double>> entries;
  final double total;
  final ColorScheme cs;

  const _CategoryDonutChart({
    required this.entries,
    required this.total,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DonutPainter(entries: entries, total: total, cs: cs),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Total',
              style: TextStyle(fontSize: 10, color: cs.outline, fontWeight: FontWeight.bold),
            ),
            Text(
              NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp').format(total),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cs.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<MapEntry<String, double>> entries;
  final double total;
  final ColorScheme cs;

  _DonutPainter({required this.entries, required this.total, required this.cs});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    const strokeWidth = 12.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Background circle
    canvas.drawCircle(center, radius - strokeWidth / 2, paint..color = cs.outlineVariant.withOpacity(0.5));

    if (total <= 0) return;

    double startAngle = -pi / 2;
    final colors = [
      cs.primary,
      cs.tertiary,
      Colors.orange,
      cs.error,
      Colors.purple,
      Colors.teal,
    ];

    for (int i = 0; i < min(entries.length, 6); i++) {
      final sweepAngle = (entries[i].value / total) * 2 * pi;
      paint.color = colors[i % colors.length];
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle + 0.05, // Small gap
        sweepAngle - 0.1,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => true;
}

class _WeeklyBarChart extends StatelessWidget {
  final List<double> data;
  final Color color;
  final Color bgColor;
  const _WeeklyBarChart({required this.data, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BarPainter(data: data, color: color, bgColor: bgColor),
      child: const SizedBox.expand(),
    );
  }
}

class _BarPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final Color bgColor;
  _BarPainter({required this.data, required this.color, required this.bgColor});

  @override
  void paint(Canvas canvas, Size size) {
    final maxVal = data.fold<double>(0, (m, v) => max(m, v));
    final barW = (size.width / data.length) * 0.45;
    final gap = (size.width / data.length) * 0.55;
    final chartH = size.height;

    for (int i = 0; i < data.length; i++) {
      final x = i * (barW + gap) + gap / 2;
      
      // bg bar (full height)
      final bgRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 0, barW, chartH),
        const Radius.circular(10),
      );
      canvas.drawRRect(bgRRect, Paint()..color = bgColor);

      // actual data bar
      if (maxVal > 0 && data[i] > 0) {
        final h = (data[i] / maxVal) * chartH;
        final barRRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, chartH - h, barW, h),
          const Radius.circular(10),
        );
        
        // Gradient fill
        final gradient = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [color, color.withOpacity(0.7)],
        );
        
        canvas.drawRRect(
          barRRect,
          Paint()..shader = gradient.createShader(Rect.fromLTWH(x, chartH - h, barW, h)),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarPainter old) =>
      old.data != data || old.color != color;
}

class _GroupedBarChart extends StatelessWidget {
  final List<Map<String, double>> data;
  final Color incomeColor;
  final Color expenseColor;
  const _GroupedBarChart(
      {required this.data,
      required this.incomeColor,
      required this.expenseColor});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GroupedPainter(
          data: data, incomeColor: incomeColor, expenseColor: expenseColor),
      child: const SizedBox.expand(),
    );
  }
}

class _GroupedPainter extends CustomPainter {
  final List<Map<String, double>> data;
  final Color incomeColor;
  final Color expenseColor;
  _GroupedPainter(
      {required this.data,
      required this.incomeColor,
      required this.expenseColor});

  @override
  void paint(Canvas canvas, Size size) {
    double maxVal = 1;
    for (final d in data) {
      maxVal = max(maxVal, max(d['income']!, d['expense']!));
    }
    final groupW = size.width / data.length;
    final barW = groupW * 0.25;
    final chartH = size.height;

    for (int i = 0; i < data.length; i++) {
      final gx = i * groupW;
      final incH = (data[i]['income']! / maxVal) * chartH;
      final expH = (data[i]['expense']! / maxVal) * chartH;

      // Income bar (rounded top)
      final incRRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(gx + groupW * 0.1, chartH - incH, barW, incH),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );
      canvas.drawRRect(incRRect, Paint()..color = incomeColor);

      // Expense bar (rounded top)
      final expRRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(gx + groupW * 0.1 + barW + 4, chartH - expH, barW, expH),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );
      canvas.drawRRect(expRRect, Paint()..color = expenseColor);
    }
  }

  @override
  bool shouldRepaint(covariant _GroupedPainter old) => true;
}
