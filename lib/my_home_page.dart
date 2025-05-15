import 'package:flutter/material.dart';

class Transaction {
    final String title;
    final double amount;
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
        Navigator.of(context).pop(); // fecha o modal
    }

    void _openAddTransactionModal() {
        String title = '';
        String amount = '';
        bool isIncome = true;

        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) {
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
                            const Text("Adicionar Transação", style: TextStyle(fontSize: 18)),
                            TextField(
                                decoration: const InputDecoration(labelText: 'Título'),
                                onChanged: (val) => title = val,
                            ),
                            TextField(
                                decoration: const InputDecoration(labelText: 'Valor'),
                                keyboardType: TextInputType.number,
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
                                                setState(() => isIncome = value);
                                            }
                                        },
                                    ),
                                ],
                            ),
                            ElevatedButton(
                                onPressed: () {
                                    final amt = double.tryParse(amount) ?? 0;
                                    if (title.isNotEmpty && amt > 0) {
                                        _addTransaction(title, amt, isIncome);
                                    }
                                },
                                child: const Text("Salvar"),
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
        return Scaffold(
            appBar: AppBar(
                title: const Text("Minhas Finanças"),
                backgroundColor: Colors.green[700],
            ),
            body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    children: [
                        // Saldo total
                        Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            color: Colors.green[50],
                            child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                    children: [
                                        const Text("Saldo Total", style: TextStyle(fontSize: 18)),
                                        const SizedBox(height: 8),
                                        Text(
                                            "R\$ ${totalBalance.toStringAsFixed(2)}",
                                            style: const TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                        const SizedBox(height: 20),

                        // Lista de transações
                        Expanded(
                            child: _transactions.isEmpty
                                ? const Center(child: Text("Nenhuma transação ainda!"))
                                : ListView.builder(
                                itemCount: _transactions.length,
                                itemBuilder: (ctx, index) {
                                    final tx = _transactions[index];
                                    return ListTile(
                                        leading: Icon(
                                            tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                            color: tx.isIncome ? Colors.green : Colors.red,
                                        ),
                                        title: Text(tx.title),
                                        subtitle: Text(tx.isIncome ? "Entrada" : "Saída"),
                                        trailing: Text(
                                            "R\$ ${tx.amount.toStringAsFixed(2)}",
                                            style: TextStyle(
                                                color: tx.isIncome ? Colors.green : Colors.red,
                                                fontWeight: FontWeight.bold,
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
