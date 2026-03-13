import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plena_veste/database/models/dress.dart';
import 'package:plena_veste/pages/dresses/dress_detail/dress_detail_logic.dart';
import 'package:plena_veste/pages/dresses/dress_detail/dress_detail_state.dart';

class DressDetailDialog extends StatefulWidget {
    final Dress dress;

    const DressDetailDialog({super.key, required this.dress});

    @override
    State<DressDetailDialog> createState() => _DressDetailDialogState();
}

class _DressDetailDialogState extends State<DressDetailDialog> {
    late final DressDetailState _state;
    late final DressDetailLogic _logic;

    @override
    void initState() {
        super.initState();
        
        _state = DressDetailState(dress: widget.dress);
        _logic = DressDetailLogic(_state, setState);
    }

    @override
    Widget build(BuildContext context) {
        return AlertDialog(
            title: Text(_state.dress.model),
            content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: SingleChildScrollView(
                    child: Form(
                        key: _state.formKey,
                        child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                SizedBox(
                                    height: _state.dress.photos!.isEmpty ? 0 : 300,
                                    child: _state.dress.photos!.isEmpty
                                        ? null
                                        : Stack(
                                            children: [
                                                PageView.builder(
                                                    controller: _state.photosPageController,
                                                    itemCount: _state.dress.photos!.length,
                                                    itemBuilder: (BuildContext context, int index) {
                                                        return Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                                Spacer(),
                                                                Stack(
                                                                    alignment: Alignment.topRight,
                                                                    children: [
                                                                        Container(
                                                                            alignment: Alignment.center,
                                                                            clipBehavior: Clip.antiAlias,
                                                                            decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(8),
                                                                            ),
                                                                            child: Image.memory(_state.dress.photos![index], fit: BoxFit.contain)
                                                                        ),
                                                                        Container(
                                                                            margin: const EdgeInsets.all(4),
                                                                            child: ElevatedButton(
                                                                                onPressed: _logic.onRemovePhotoPressed,
                                                                                style: ElevatedButton.styleFrom(
                                                                                    shape: CircleBorder(),
                                                                                    padding: EdgeInsets.all(0),
                                                                                    minimumSize: Size(40, 40),
                                                                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                                                    visualDensity: VisualDensity.compact,
                                                                                    backgroundColor: Theme.of(context).colorScheme.errorContainer,
                                                                                ),
                                                                                child: Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: const Icon(
                                                                                        Icons.delete_outline_rounded,
                                                                                        size: 20
                                                                                    ),
                                                                                )
                                                                            ),
                                                                        )
                                                                    ]
                                                                ),
                                                                Spacer()
                                                            ],
                                                        );
                                                    },
                                                ),
                                                Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: IconButton(
                                                        onPressed: _state.dress.photos!.length <= 1 ? null : _logic.onPrevPhotoPressed,
                                                        icon: const Icon(Icons.chevron_left_rounded),
                                                    )
                                                ),
                                                Align(
                                                    alignment: Alignment.centerRight,
                                                    child: IconButton(
                                                        onPressed: _state.dress.photos!.length <= 1 ? null : _logic.onNextPhotoPressed,
                                                        icon: const Icon(Icons.chevron_right_rounded),
                                                    )
                                                ),
                                            ],
                                        )
                                ),
                                SizedBox(height: 12),
                                Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        Card(
                                            child: Padding(
                                                padding: const EdgeInsets.all(12.0),
                                                child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                        Text(
                                                            'Identificação',
                                                            style: TextStyle(
                                                                fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                                                                fontWeight: FontWeight.bold,
                                                            ),
                                                        ),
                                                        const SizedBox(height: 8),
                                                        Row(
                                                            children: [
                                                                Flexible(
                                                                    flex: 30,
                                                                    child: TextFormField(
                                                                        decoration: InputDecoration(
                                                                            prefix: Text(
                                                                                'PV-',
                                                                                style: TextStyle(
                                                                                    color: Theme.of(context).textTheme.bodyMedium!.color,
                                                                                ),
                                                                            ),
                                                                            labelText: 'Código',
                                                                        ),
                                                                        keyboardType: TextInputType.number,
                                                                        readOnly: true,
                                                                        controller: _state.codeController,
                                                                        canRequestFocus: false,
                                                                    ),
                                                                ),
                                                                SizedBox(width: 8),
                                                                Flexible(
                                                                    flex: 70,
                                                                    child: TextFormField(
                                                                        decoration: InputDecoration(
                                                                            labelText: 'Modelo',
                                                                        ),
                                                                        validator: (value) => _logic.textValidator(value, 'Modelo'),
                                                                        controller: _state.modelController,
                                                                    ),
                                                                ),
                                                            ],
                                                        ),
                                                        SizedBox(height: 8),
                                                        Row(
                                                            children: [
                                                                Flexible(
                                                                    flex: 50,
                                                                    child: DropdownButtonFormField<DressCategory>(
                                                                        initialValue: _state.selectedCategory,
                                                                        decoration: InputDecoration(
                                                                            labelText: 'Categoria',
                                                                        ),
                                                                        items: DressCategory.values.map((category) => DropdownMenuItem(
                                                                            value: category,
                                                                            child: Text(DressCategory.displayNames[category]!),
                                                                        )).toList(),
                                                                        onChanged: _logic.onCategoryChanged,
                                                                        validator: (value) => _logic.dropdownValidator(value, 'Categoria'),
                                                                    ),
                                                                ),
                                                                SizedBox(width: 8),
                                                                Flexible(
                                                                    flex: 50,
                                                                    child: DropdownButtonFormField<DressLength>(
                                                                        initialValue: _state.selectedLength,
                                                                        decoration: InputDecoration(
                                                                            labelText: 'Comprimento',
                                                                        ),
                                                                        items: DressLength.values.map((length) => DropdownMenuItem(
                                                                            value: length,
                                                                            child: Text(DressLength.displayNames[length]!),
                                                                        )).toList(),
                                                                        onChanged: _logic.onLengthChanged,
                                                                        validator: (value) => _logic.dropdownValidator(value, 'Comprimento'),
                                                                    ),
                                                                ),
                                                            ],
                                                        ),
                                                        SizedBox(height: 8),
                                                        Row(
                                                            children: [
                                                                Flexible(
                                                                    flex: 70,
                                                                    child: TextFormField(
                                                                        decoration: InputDecoration(
                                                                            labelText: 'Cor',
                                                                        ),
                                                                        controller: _state.colorController,
                                                                        validator: (value) => _logic.textValidator(value, 'Cor'),
                                                                    ),
                                                                ),
                                                                SizedBox(width: 8),
                                                                Flexible(
                                                                    flex: 30,
                                                                    child: TextFormField(
                                                                        decoration: InputDecoration(
                                                                            labelText: 'Tamanho',
                                                                        ),
                                                                        keyboardType: TextInputType.number,
                                                                        inputFormatters: [
                                                                            FilteringTextInputFormatter.digitsOnly,
                                                                        ],
                                                                        controller: _state.sizeController,
                                                                        validator: (value) => _logic.textValidator(value, 'Tamanho'),
                                                                    ),
                                                                ),
                                                            ],
                                                        ),
                                                    ],
                                                )
                                            )
                                        ),
                                        Card(
                                            child: Padding(
                                                padding: const EdgeInsets.all(12.0),
                                                child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                        Text(
                                                            'Financeiro',
                                                            style: TextStyle(
                                                                fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                                                                fontWeight: FontWeight.bold,
                                                            ),
                                                        ),
                                                        const SizedBox(height: 8),
                                                        Row(
                                                            children: [
                                                                Flexible(
                                                                    flex: 50,
                                                                    child: TextFormField(
                                                                        decoration: InputDecoration(
                                                                            labelText: 'Preço de Compra',
                                                                        ),
                                                                        keyboardType: TextInputType.number,
                                                                        inputFormatters: [
                                                                            FilteringTextInputFormatter.digitsOnly
                                                                        ],
                                                                        controller: _state.purchasePriceController,
                                                                        validator: (value) => _logic.textValidator(value, 'Preço de Compra'),
                                                                        onChanged: (value) => _logic.onPriceChanged(value, _state.purchasePriceController)
                                                                    ),
                                                                ),
                                                                SizedBox(width: 8),
                                                                Flexible(
                                                                    flex: 50,
                                                                    child: TextFormField(
                                                                        decoration: InputDecoration(
                                                                            labelText: 'Preço de Aluguel',
                                                                        ),
                                                                        keyboardType: TextInputType.number,
                                                                        inputFormatters: [
                                                                            FilteringTextInputFormatter.digitsOnly
                                                                        ],
                                                                        controller: _state.rentalPriceController,
                                                                        validator: (value) => _logic.textValidator(value, 'Preço de Aluguel'),
                                                                        onChanged: (value) => _logic.onPriceChanged(value, _state.rentalPriceController)
                                                                    ),
                                                                ),
                                                            ],
                                                        ),
                                                        SizedBox(height: 8),
                                                        Row(
                                                            children: [
                                                                Flexible(
                                                                    flex: 50,
                                                                    child: TextFormField(
                                                                        decoration: InputDecoration(
                                                                            labelText: 'Valor de Depósito',
                                                                        ),
                                                                        keyboardType: TextInputType.number,
                                                                        inputFormatters: [
                                                                            FilteringTextInputFormatter.digitsOnly
                                                                        ],
                                                                        controller: _state.depositValueController,
                                                                        validator: (value) => _logic.textValidator(value, 'Valor de Depósito'),
                                                                        onChanged: (value) => _logic.onPriceChanged(value, _state.depositValueController)
                                                                    ),
                                                                ),
                                                                SizedBox(width: 8),
                                                                Flexible(
                                                                    flex: 50,
                                                                    child: TextFormField(
                                                                        decoration: InputDecoration(
                                                                            labelText: 'Preço de Venda',
                                                                        ),
                                                                        keyboardType: TextInputType.number,
                                                                        inputFormatters: [
                                                                            FilteringTextInputFormatter.digitsOnly
                                                                        ],
                                                                        controller: _state.sellingPriceController,
                                                                        onChanged: (value) => _logic.onPriceChanged(value, _state.sellingPriceController)
                                                                    ),
                                                                ),
                                                            ],
                                                        ),
                                                    ],
                                                )
                                            )
                                        ),
                                        Card(
                                            child: Padding(
                                                padding: const EdgeInsets.all(12.0),
                                                child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                        Text(
                                                            'Detalhes',
                                                            style: TextStyle(
                                                                fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                                                                fontWeight: FontWeight.bold,
                                                            ),
                                                        ),
                                                        const SizedBox(height: 8),
                                                        Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                                Text('Ajustável:'),
                                                                Checkbox(
                                                                    value: _state.isAdjustable,
                                                                    onChanged: _logic.onIsAdjustableChanged,
                                                                ),
                                                                Expanded(
                                                                    child: TextFormField(
                                                                        decoration: InputDecoration(
                                                                            labelText: 'Vezes Alugado',
                                                                        ),
                                                                        keyboardType: TextInputType.number,
                                                                        inputFormatters: [
                                                                            FilteringTextInputFormatter.digitsOnly,
                                                                        ],
                                                                        controller: _state.rentedTimesController,
                                                                        validator: (value) => _logic.textValidator(value, 'Vezes Alugado'),
                                                                    ),
                                                                ),
                                                                SizedBox(width: 8),
                                                                Expanded(
                                                                    child: TextFormField(
                                                                        decoration: InputDecoration(
                                                                            labelText: 'Último Aluguel',
                                                                        ),
                                                                        keyboardType: TextInputType.datetime,
                                                                        inputFormatters: [
                                                                            FilteringTextInputFormatter.digitsOnly,
                                                                            _state.lastRentedAtFormatter,
                                                                        ],
                                                                        controller: _state.lastRentedAtController,
                                                                        validator: (value) => _logic.textValidator(value, 'Último Aluguel'),
                                                                    ),
                                                                ),
                                                                SizedBox(width: 8),
                                                                Expanded(
                                                                    child: DropdownButtonFormField<DressStatus>(
                                                                        initialValue: _state.selectedStatus,
                                                                        decoration: InputDecoration(
                                                                            labelText: 'Status',
                                                                        ),
                                                                        items: DressStatus.values.map((status) => DropdownMenuItem(
                                                                            value: status,
                                                                            child: Text(DressStatus.displayNames[status]!),
                                                                        )).toList(),
                                                                        onChanged: _logic.onStatusChanged,
                                                                        validator: (value) => _logic.dropdownValidator(value, 'Status'),
                                                                    ),
                                                                ),
                                                            ],
                                                        ),
                                                        SizedBox(height: 8),
                                                        TextFormField(
                                                            decoration: InputDecoration(
                                                                labelText: 'Notas',
                                                            ),
                                                            maxLines: 4,
                                                            controller: _state.notesController,
                                                        ),
                                                    ],
                                                )
                                            )
                                        )
                                    ],
                                )
                            ],
                        ),
                    )
                )
            ),
            actions: [
                TextButton(
                    onPressed: _logic.onSavePressed,
                    child: const Text('Salvar'),
                ),
            ],
        );
    }
}