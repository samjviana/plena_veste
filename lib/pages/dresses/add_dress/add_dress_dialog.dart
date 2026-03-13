import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plena_veste/database/models/dress.dart';
import 'package:plena_veste/pages/dresses/add_dress/add_dress_logic.dart';
import 'package:plena_veste/pages/dresses/add_dress/add_dress_state.dart';

class AddDressDialog extends StatefulWidget {
    const AddDressDialog({super.key});

    @override
    State<AddDressDialog> createState() => _AddDressDialogState();
}

class _AddDressDialogState extends State<AddDressDialog> {
    late final AddDressState _state;
    late final AddDressLogic _logic;

    @override
    void initState() {
        super.initState();

        _state = AddDressState();
        _logic = AddDressLogic(_state, setState);
    }

    @override
    Widget build(BuildContext context) {

        return AlertDialog(
            title: Text('Adicionar Vestido'),
            actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancelar'),
                ),
                ElevatedButton(
                    onPressed: _logic.onSavePressed,
                    child: Text('Salvar'),
                ),
            ],
            content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Form(
                    key: _state.formKey,
                    child: Flex(
                        direction: Axis.horizontal,
                        children: [
                            Flexible(
                                flex: 45,
                                child: Column(
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
                                                                    child: FutureBuilder<String>(
                                                                        future: _logic.generateDressCode(),
                                                                        builder: (context, snapshot) {
                                                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                                                                return CircularProgressIndicator();
                                                                            }
                                                                            if (snapshot.hasError) {
                                                                                return Text('Erro ao gerar código');
                                                                            }
                                                                            _state.codeController.text = snapshot.data!;
                                                                            return TextFormField(
                                                                                decoration: InputDecoration(
                                                                                    labelText: 'Código',
                                                                                ),
                                                                                controller: _state.codeController,
                                                                                readOnly: true,
                                                                            );
                                                                        },
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
                                        )
                                    ],
                                )
                            ),
                            SizedBox(width: 16),
                            Flexible(
                                flex: 55,
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
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
                                                        SizedBox(height: 8),
                                                        Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                                Text('Fotos:'),
                                                                SizedBox(width: 8),
                                                                ElevatedButton(
                                                                    onPressed: _logic.onAddPhotosPressed,
                                                                    child: Text('Adicionar Fotos'),
                                                                ),
                                                            ]
                                                        ),
                                                        SizedBox(height: 8),
                                                        SizedBox(
                                                            height: _state.selectedPhotos.isEmpty ? 0 : 180,
                                                            child: _state.selectedPhotos.isEmpty
                                                                ? null
                                                                : Stack(
                                                                    children: [
                                                                        PageView.builder(
                                                                            controller: _state.photosPageController,
                                                                            itemCount: _state.selectedPhotos.length,
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
                                                                                                    child: Image.memory(_state.selectedPhotos[index], fit: BoxFit.contain)
                                                                                                ),
                                                                                                Container(
                                                                                                    margin: const EdgeInsets.all(4),
                                                                                                    child: ElevatedButton(
                                                                                                        onPressed: _logic.onRemovePhotoPressed,
                                                                                                        style: ElevatedButton.styleFrom(
                                                                                                            shape: CircleBorder(),
                                                                                                            padding: EdgeInsets.all(0),
                                                                                                            minimumSize: Size(32, 32),
                                                                                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                                                                            visualDensity: VisualDensity.compact,
                                                                                                            backgroundColor: Theme.of(context).colorScheme.errorContainer,
                                                                                                        ),
                                                                                                        child: Padding(
                                                                                                            padding: const EdgeInsets.all(4.0),
                                                                                                            child: const Icon(Icons.delete_outline_rounded),
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
                                                                                onPressed: _state.selectedPhotos.length <= 1 ? null : _logic.onPrevPhotoPressed,
                                                                                icon: const Icon(Icons.chevron_left_rounded),
                                                                            )
                                                                        ),
                                                                        Align(
                                                                            alignment: Alignment.centerRight,
                                                                            child: IconButton(
                                                                                onPressed: _state.selectedPhotos.length <= 1 ? null : _logic.onNextPhotoPressed,
                                                                                icon: const Icon(Icons.chevron_right_rounded),
                                                                            )
                                                                        ),
                                                                    ],
                                                                )
                                                        )
                                                    ],
                                                )
                                            )
                                        )
                                    ],
                                )
                            ),
                        ],
                    )
                )
            )
        );
    }
}