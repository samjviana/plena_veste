import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:plena_veste/database/models/dress.dart';
import 'package:plena_veste/pages/dresses/dresses_logic.dart';
import 'package:plena_veste/pages/dresses/dresses_state.dart';

class DressesPage extends StatefulWidget {
    const DressesPage({super.key});

    @override
    State<DressesPage> createState() => _DressesPageState();
}

class _DressesPageState extends State<DressesPage> {
    late final DressesState _state;
    late final DressesLogic _logic;

    @override
    void initState() {
        super.initState();

        _state = DressesState();
        _logic = DressesLogic(_state, setState);
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: FutureBuilder(
                future: _state.bigQueryService.selectAll<Dress>(Dress.tableId, Dress.fromMap),
                builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                        return Center(child: Text('Erro ao carregar vestidos: ${snapshot.error}'));
                    }

                    List<Dress> dresses = snapshot.data ?? [];
                    if (dresses.isEmpty) {
                        return Center(child: Text('Nenhum vestido encontrado'));
                    }

                    return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: dresses.length,
                        itemBuilder: (context, index) {
                            Dress dress = dresses[index];

                            Uint8List? thumb;
                            if (dress.photos != null && dress.photos!.isNotEmpty) {
                                thumb = dress.photos!.first;
                            } else {
                                thumb = Uint8List(0);
                            }

                            return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Card(
                                    child: InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () => _logic.showDressDetails(context, dress),
                                        child: Container(
                                            height: 100,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8
                                            ),
                                            child: Row(
                                                children: [
                                                    Container(
                                                        clipBehavior: Clip.hardEdge,
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Image.memory(thumb),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                            Text(
                                                                '${dress.code} • ${dress.model}',
                                                                style: Theme.of(context).textTheme.titleMedium,
                                                            ),
                                                            Text(
                                                                '${DressCategory.displayNames[dress.category]} • ${DressLength.displayNames[dress.length]} • Tam ${dress.size} • ${dress.color}',
                                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                                            ),
                                                            Spacer(),
                                                            Row(
                                                                children: [
                                                                    
                                                                ]
                                                            ),
                                                        ],
                                                    ),
                                                    Spacer(),
                                                    Column(
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: [
                                                            Text(
                                                                'R\$ ${(dress.rentalPrice / 100).toStringAsFixed(2)}',
                                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                                            ),
                                                            Text(
                                                                'R\$ ${(dress.purchasePrice / 100).toStringAsFixed(2)}',
                                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                                            ),
                                                            Spacer(),
                                                            Row(
                                                                children: [
                                                                    Container(
                                                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                                        decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(999),
                                                                            color: _logic.statusBackground(dress.currentStatus),
                                                                        ),
                                                                        child: Text(
                                                                            DressStatus.displayNames[dress.currentStatus]!,
                                                                            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).textTheme.labelMedium!.color!),
                                                                        ),
                                                                    ),
                                                                    SizedBox(width: 8),
                                                                    Container(
                                                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                                        decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(999),
                                                                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                                                                        ),
                                                                        child: Text(
                                                                            'Alugado ${dress.timesRented}x',
                                                                            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).textTheme.labelMedium!.color!),
                                                                        ),
                                                                    ),
                                                                ]
                                                            )
                                                        ],
                                                    )
                                                ],
                                            ),
                                        )
                                    )
                                ),
                            );
                        },
                    );
                },
            ),
            floatingActionButton: FloatingActionButton(
                shape: const CircleBorder(),
                onPressed: () => _logic.onAddDress(context),
                child: const Icon(Icons.add_rounded),
            ),
        );
    }
}