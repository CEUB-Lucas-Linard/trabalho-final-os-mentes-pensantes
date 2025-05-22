import 'package:flutter/material.dart';

class Transaction {
    String title;
    double amount;
    final bool isIncome;

    Transaction({
        required this.title,
        required this.amount,
        required this.isIncome,
    });
}

class FinanceHomePage extends StatefulWidget {
    const FinanceHomePage({super.key});

    @override
    State<FinanceHomePage> createState() => _FinanceHomePageState();
}

class _FinanceHomePageState extends State<FinanceHomePage> {
    final List<Transaction> _transactions = [];

    double get totalBalance {
        return _transactions.fold(0, (sum, tx) {
            return tx.isIncome ? sum + tx.amount : sum - tx.amount;
        });
    }

    void _addTransaction(String title, double amount, bool isIncome) {
        setState(() {
            _transactions.add(Transaction(
                title: title,
                amount: amount,
                isIncome: isIncome,
            ));
        });
        Navigator.of(context).pop();
    }

    void _editTransaction(int index, String title, double amount, bool isIncome) {
        setState(() {
            _transactions[index] = Transaction(
                title: title,
                amount: amount,
                isIncome: isIncome,
            );
        });
        Navigator.of(context).pop();
    }

    void _openAddTransactionModal() {
        String title = '';
        String amount = '';
        bool isIncome = true;

        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) {
                return _buildTransactionModal(
                    title: title,
                    amount: amount,
                    isIncome: isIncome,
                    onSave: (title, amount, isIncome) {
                        final amt = double.tryParse(amount) ?? 0;
                        if (title.isNotEmpty && amt > 0) {
                            _addTransaction(title, amt, isIncome);
                        }
                    },
                    isEditing: false,
                );
            },
        );
    }

    void _openEditTransactionModal(int index) {
        String title = _transactions[index].title;
        String amount = _transactions[index].amount.toString();
        bool isIncome = _transactions[index].isIncome;

        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) {
                return _buildTransactionModal(
                    title: title,
                    amount: amount,
                    isIncome: isIncome,
                    onSave: (title, amount, isIncome) {
                        final amt = double.tryParse(amount) ?? 0;
                        if (title.isNotEmpty && amt > 0) {
                            _editTransaction(index, title, amt, isIncome);
                        }
                    },
                    isEditing: true,
                );
            },
        );
    }

    Widget _buildTransactionModal({
        required String title,
        required String amount,
        required bool isIncome,
        required Function(String, String, bool) onSave,
        required bool isEditing,
    }) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
                return Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                        top: 16,
                        left: 16,
                        right: 16,
                    ),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            Text(
                                isEditing ? "Editar Transação" : "Adicionar Transação",
                                style: const TextStyle(fontSize: 18),
                            ),
                            TextField(
                                decoration: const InputDecoration(labelText: 'Título'),
                                controller: TextEditingController(text: title),
                                onChanged: (val) => title = val,
                            ),
                            TextField(
                                decoration: const InputDecoration(labelText: 'Valor'),
                                keyboardType: TextInputType.number,
                                controller: TextEditingController(text: amount),
                                onChanged: (val) => amount = val,
                            ),
                            Row(
                                children: [
                                    const Text("Tipo: "),
                                    DropdownButton<bool>(
                                        value: isIncome,
                                        items: const [
                                            DropdownMenuItem(value: true, child: Text("Entrada")),
                                            DropdownMenuItem(value: false, child: Text("Saída")),
                                        ],
                                        onChanged: (value) {
                                            if (value != null) {
                                                setModalState(() {
                                                    isIncome = value;
                                                });
                                            }
                                        },
                                    ),
                                ],
                            ),
                            ElevatedButton(
                                onPressed: () {
                                    onSave(title, amount, isIncome);
                                },
                                child: Text(isEditing ? "Atualizar" : "Salvar"),
                            ),
                            const SizedBox(height: 20),
                        ],
                    ),
                );
            },
        );
    }

    @override
    Widget build(BuildContext context) {
        final isBalanceNegative = totalBalance < 0;

        return Scaffold(
            appBar: AppBar(
                title: const Text(
                    "Minhas Finanças",
                    style: TextStyle(color: Colors.white),
                ),
                backgroundColor: const Color(0xFF255F38),
            ),
            body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    children: [
                        Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            color: isBalanceNegative ? Colors.red[50] : Colors.green[50],
                            child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Column(
                                    children: [
                                        const Text("Saldo Total", style: TextStyle(fontSize: 24)),
                                        const SizedBox(height: 8, width: 200),
                                        Text(
                                            "R\$ ${totalBalance.toStringAsFixed(2)}",
                                            style: TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                                color: isBalanceNegative ? Colors.red : Colors.green,
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                            child: _transactions.isEmpty
                                ? const Center(child: Text("Nenhuma transação ainda!"))
                                : ListView.builder(
                                itemCount: _transactions.length,
                                itemBuilder: (ctx, index) {
                                    final tx = _transactions[index];
                                    return Card(
                                        margin: const EdgeInsets.symmetric(vertical: 4),
                                        child: ListTile(
                                            leading: Icon(
                                                tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                                color: tx.isIncome ? Colors.green : Colors.red,
                                            ),
                                            title: Text(tx.title),
                                            subtitle: Text(tx.isIncome ? "Entrada" : "Saída"),
                                            trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                    Text(
                                                        "R\$ ${tx.amount.toStringAsFixed(2)}",
                                                        style: TextStyle(
                                                            color: tx.isIncome ? Colors.green : Colors.red,
                                                            fontWeight: FontWeight.bold,
                                                        ),
                                                    ),
                                                    IconButton(
                                                        icon: const Icon(Icons.edit),
                                                        onPressed: () => _openEditTransactionModal(index),
                                                    ),
                                                ],
                                            ),
                                        ),
                                    );
                                },
                            ),
                        ),
                    ],
                ),
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: _openAddTransactionModal,
                child: const Icon(Icons.add),
                backgroundColor: Colors.green,
            ),
        );
    }
}