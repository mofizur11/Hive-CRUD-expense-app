import 'package:daily_expanse/model/expenses.dart';
import 'package:flutter/material.dart';

class ExpenseDialog extends StatefulWidget {
  final Expense? expense;
  final Function(String name, double amount, bool isExpense) onClickedDone;

  const ExpenseDialog({
    Key? key,
    this.expense,
    required this.onClickedDone,
  }) : super(key: key);

  @override
  _ExpenseDialogState createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends State<ExpenseDialog> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final amountController = TextEditingController();

  bool isExpense = true;

  @override
  void initState() {
    super.initState();

    if (widget.expense != null) {
      final transaction = widget.expense!;

      nameController.text = transaction.name;
      amountController.text = transaction.amount.toString();
      isExpense = transaction.isExpense;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expense != null;
    final title = isEditing ? 'Edit Transaction' : 'Add Transaction';

    return AlertDialog(
      title: Text(title),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 8),
              buildName(),
              const SizedBox(height: 8),
              buildAmount(),
              const SizedBox(height: 8),
              buildRadioButtons(),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        buildCancelButton(context),
        buildAddButton(context, isEditing: isEditing),
      ],
    );
  }

  Widget buildName() => TextFormField(
    controller: nameController,
    decoration: const InputDecoration(
      border: OutlineInputBorder(),
      hintText: 'Enter Name',
    ),
    validator: (name) =>
    name != null && name.isEmpty ? 'Enter a name' : null,
  );

  Widget buildAmount() => TextFormField(
    decoration: const InputDecoration(
      border: OutlineInputBorder(),
      hintText: 'Enter Amount',
    ),
    keyboardType: TextInputType.number,
    validator: (amount) => amount != null && double.tryParse(amount) == null
        ? 'Enter a valid number'
        : null,
    controller: amountController,
  );

  Widget buildRadioButtons() => Column(
    children: [
      RadioListTile<bool>(
        title: const Text('Expense'),
        value: true,
        groupValue: isExpense,
        onChanged: (value) => setState(() => isExpense = value!),
      ),
      RadioListTile<bool>(
        title: const Text('Income'),
        value: false,
        groupValue: isExpense,
        onChanged: (value) => setState(() => isExpense = value!),
      ),
    ],
  );

  Widget buildCancelButton(BuildContext context) => TextButton(
    child: const Text('Cancel'),
    onPressed: () => Navigator.of(context).pop(),
  );

  Widget buildAddButton(BuildContext context, {required bool isEditing}) {
    final text = isEditing ? 'Save' : 'Add';

    return TextButton(
      child: Text(text),
      onPressed: () async {
        final isValid = formKey.currentState!.validate();

        if (isValid) {
          final name = nameController.text;
          final amount = double.tryParse(amountController.text) ?? 0;

          widget.onClickedDone(name, amount, isExpense);

          Navigator.of(context).pop();
        }
      },
    );
  }
}