import 'package:flutter/material.dart';
import 'package:plena_veste/database/models/dress.dart';
import 'package:plena_veste/pages/dresses/add_dress/add_dress_dialog.dart';
import 'package:plena_veste/pages/dresses/dress_detail/dress_detail_dialog.dart';
import 'package:plena_veste/pages/dresses/dresses_state.dart';

class DressesLogic {
    final DressesState _state;
    final void Function(void Function()) _setState;

    DressesLogic(this._state, this._setState);

    void onAddDress(BuildContext context) async {
        bool? result = await showDialog(
            context: context,
            builder: (context) => AddDressDialog(),
        );
        if (result == null || !result) {
            return;
        }

        _setState(() {});
    }

    void onDeleteDress(BuildContext context, Dress dress) async {
        bool? result = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                title: const Text('Confirmar exclusão'),
                content: const Text('Tem certeza que deseja excluir este vestido? Esta ação não pode ser desfeita.'),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Excluir'),
                    ),
                ],
            ),
        );
        if (result == null || !result) {
            return;
        }

        await _state.bigQueryService.delete(Dress.tableId, dress.uuid);
        _setState(() {});
    }

    void showDressDetails(BuildContext context, Dress dress) async {
        bool? result = await showDialog(
            context: context,
            builder: (context) => DressDetailDialog(dress: dress),
        );
        if (result == null || !result) {
            return;
        }

        if (result) {
            _setState(() {});
        }
    }

    Color statusBackground(DressStatus status) {
        if (status == DressStatus.available) {
            return Colors.green.withValues(alpha: 0.5);
        } else if (status == DressStatus.reserved) {
            return Colors.orange.withValues(alpha: 0.5);
        } else if (status == DressStatus.fitting) {
            return Colors.blue.withValues(alpha: 0.5);
        } else if (status == DressStatus.rented) {
            return Colors.red.withValues(alpha: 0.5);
        } else if (status == DressStatus.washing) {
            return Colors.purple.withValues(alpha: 0.5);
        } else if (status == DressStatus.adjusting) {
            return Colors.yellow.withValues(alpha: 0.5);
        } else if (status == DressStatus.unavailable) {
            return Colors.grey.withValues(alpha: 0.5);
        } 

        return Colors.grey.withValues(alpha: 0.5);
    }
}