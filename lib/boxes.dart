import 'package:daily_expanse/model/expenses.dart';
import 'package:hive/hive.dart';

class Boxes {
  static Box<Expense> getExpense() =>
      Hive.box<Expense>('expenses');
}