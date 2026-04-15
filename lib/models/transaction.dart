import 'package:flutter/material.dart';

class Transaction {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final bool isExpense;
  final String notes;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.isExpense,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'category': category,
        'date': date.toIso8601String(),
        'isExpense': isExpense,
        'notes': notes,
      };

  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    bool? isExpense,
    String? notes,
  }) =>
      Transaction(
        id: id ?? this.id,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        date: date ?? this.date,
        isExpense: isExpense ?? this.isExpense,
        notes: notes ?? this.notes,
      );

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'],
        title: json['title'],
        amount: (json['amount'] as num).toDouble(),
        category: json['category'],
        date: DateTime.parse(json['date']),
        isExpense: json['isExpense'],
        notes: json['notes'] ?? '',
      );

  static IconData categoryIcon(String category) {
    switch (category) {
      case 'Makanan & Minuman':
        return Icons.restaurant;
      case 'Transportasi':
        return Icons.directions_car;
      case 'Belanja':
        return Icons.shopping_bag;
      case 'Tagihan':
        return Icons.receipt_long;
      case 'Hiburan':
        return Icons.movie;
      case 'Kesehatan':
        return Icons.medical_services;
      case 'Pendidikan':
        return Icons.school;
      case 'Gaji':
        return Icons.payments;
      case 'Investasi':
        return Icons.trending_up;
      case 'Hadiah':
        return Icons.card_giftcard;
      default:
        return Icons.category;
    }
  }

  static const List<String> expenseCategories = [
    'Makanan & Minuman',
    'Transportasi',
    'Belanja',
    'Tagihan',
    'Hiburan',
    'Kesehatan',
    'Pendidikan',
    'Lainnya',
  ];

  static const List<String> incomeCategories = [
    'Gaji',
    'Investasi',
    'Hadiah',
    'Lainnya',
  ];
}
