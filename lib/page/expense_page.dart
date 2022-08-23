import 'package:daily_expanse/model/expenses.dart';
import 'package:daily_expanse/widget/expenses_dilog.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';

import '../boxes.dart';


class ExpensePage extends StatefulWidget {
  const ExpensePage({Key? key}) : super(key: key);

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {

  @override
  void dispose() {
    Hive.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Hive Expense Tracker'),
      centerTitle: true,
    ),
    body: ValueListenableBuilder<Box<Expense>>(
      valueListenable: Boxes.getExpense().listenable(),
      builder: (context, box, _) {
        final transactions = box.values.toList().cast<Expense>();

        return buildContent(transactions);
      },
    ),
    floatingActionButton: FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () => showDialog(
        context: context,
        builder: (context) => ExpenseDialog(
          onClickedDone: addExpense,
        ),
      ),
    ),
  );

  Widget buildContent(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return const Center(
        child: Text(
          'No expenses yet!',
          style: TextStyle(fontSize: 24),
        ),
      );
    } else {
      final netExpense = expenses.fold<double>(
        0,
            (previousValue, expense) => expense.isExpense
            ? previousValue - expense.amount
            : previousValue + expense.amount,
      );
      final newExpenseString = '\$${netExpense.toStringAsFixed(2)}';
      final color = netExpense > 0 ? Colors.green : Colors.red;

      return Column(
        children: [
          const SizedBox(height: 24),
          Text(
            'Net Expense: $newExpenseString',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: expenses.length,
              itemBuilder: (BuildContext context, int index) {
                final transaction = expenses[index];

                return buildExpense(context, transaction);
              },
            ),
          ),
        ],
      );
    }
  }

  Widget buildExpense(
      BuildContext context,
      Expense expense,
      ) {
    final color = expense.isExpense ? Colors.red : Colors.green;
    final date = DateFormat.yMMMd().format(expense.createdDate);
    final amount = '\$${expense.amount.toStringAsFixed(2)}';

    return Card(
      color: Colors.white,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        title: Text(
          expense.name,
          maxLines: 2,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(date),
        trailing: Text(
          amount,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        children: [
          buildButtons(context, expense),
        ],
      ),
    );
  }

  Widget buildButtons(BuildContext context, Expense expense) => Row(
    children: [
      Expanded(
        child: TextButton.icon(
          label: const Text('Edit'),
          icon: const Icon(Icons.edit),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ExpenseDialog(
                expense: expense,
                onClickedDone: (name, amount, isExpense) =>
                    editExpense(expense, name, amount, isExpense),
              ),
            ),
          ),
        ),
      ),
      Expanded(
        child: TextButton.icon(
          label: const Text('Delete'),
          icon: const Icon(Icons.delete),
          onPressed: () => deleteExpense(expense),
        ),
      )
    ],
  );

  Future addExpense(String name, double amount, bool isExpense) async {
    final expense = Expense()
      ..name = name
      ..createdDate = DateTime.now()
      ..amount = amount
      ..isExpense = isExpense;

    final box = Boxes.getExpense();
    box.add(expense);
    //box.put('mykey', expense);

    // final mybox = Boxes.getTransactions();
    // final myTransaction = mybox.get('key');
    // mybox.values;
    // mybox.keys;
  }

  void editExpense(
      Expense expense,
      String name,
      double amount,
      bool isExpense,
      ) {
    expense.name = name;
    expense.amount = amount;
    expense.isExpense = isExpense;

    // final box = Boxes.getTransactions();
    // box.put(transaction.key, transaction);

    expense.save();
  }

  void deleteExpense(Expense expense) {
    // final box = Boxes.getTransactions();
    // box.delete(expense.key);

    expense.delete();
    //setState(() => transactions.remove(transaction));
  }
}
