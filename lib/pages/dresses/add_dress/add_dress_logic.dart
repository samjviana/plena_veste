import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:plena_veste/database/bigquery_service.dart';
import 'package:plena_veste/database/models/dress.dart';
import 'package:plena_veste/di.dart';
import 'package:plena_veste/pages/dresses/add_dress/add_dress_state.dart';

class AddDressLogic {
    final AddDressState _state;
    final Function(void Function()) _setState;
    final BigQueryService _bigQueryService = getIt<BigQueryService>();

    AddDressLogic(this._state, this._setState);

    String? textValidator(String? value, String fieldName) {
        if (value == null || value.isEmpty) {
            return 'O campo $fieldName é obrigatório';
        }
        return null;
    }

    String? dropdownValidator<T>(T? value, String fieldName) {
        if (value == null) {
            return 'O campo $fieldName é obrigatório';
        }
        return null;
    }

    void onCategoryChanged(DressCategory? category) {
        _state.selectedCategory = category;
    }

    void onLengthChanged(DressLength? length) {
        _state.selectedLength = length;
    }

    void onIsAdjustableChanged(bool? isAdjustable) {
        _state.isAdjustable = isAdjustable ?? false;
        _setState(() {});
    }

    void onStatusChanged(DressStatus? status) {
        _state.selectedStatus = status;
    }

    void onAddPhotosPressed() async {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.image,
            allowMultiple: true,
        );
        if (result == null) {
            return;
        }

        List<Uint8List> photos = [];
        for (final selectedFile in result.files) {
            final File file = File(selectedFile.path!);
            final Uint8List bytes = await file.readAsBytes();
            photos.add(bytes);
        }
        _setState(() {
            _state.selectedPhotos.addAll(photos);
        });
    }

    void onPrevPhotoPressed() {
        int currentPage = _state.photosPageController.page?.round() ?? 0;
        int prevPage = currentPage > 0 ? currentPage - 1 : _state.selectedPhotos.length - 1;
        _state.photosPageController.animateToPage(
            prevPage,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
        );
    }

    void onNextPhotoPressed() {
        int currentPage = _state.photosPageController.page?.round() ?? 0;
        int nextPage = currentPage < _state.selectedPhotos.length - 1 ? currentPage + 1 : 0;
        _state.photosPageController.animateToPage(
            nextPage,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
        );
    }

    void onRemovePhotoPressed() {
        int currentPage = _state.photosPageController.page?.round() ?? 0;
        if (_state.selectedPhotos.isEmpty) {
            return;
        }
        _setState(() {
            _state.selectedPhotos.removeAt(currentPage);
        });
    }

    void onSavePressed() async {
        if (!_state.formKey.currentState!.validate()) {
            return;
        }

        DateTime? lastRentedAt;
        if (_state.lastRentedAtController.text.isNotEmpty) {
            List<String> dateParts = _state.lastRentedAtController.text.split('/');
            if (dateParts.length == 3) {
                int day = int.parse(dateParts[0]);
                int month = int.parse(dateParts[1]);
                int year = int.parse(dateParts[2]);
                lastRentedAt = DateTime(year, month, day);
            }
        }

        Dress newDress = Dress(
            code: _state.codeController.text,
            model: _state.modelController.text,
            category: _state.selectedCategory!,
            length: _state.selectedLength!,
            color: _state.colorController.text,
            size: int.parse(_state.sizeController.text),
            isAdjustable: _state.isAdjustable,
            purchasePrice: int.parse(_state.purchasePriceController.text.replaceAll('R\$ ', '').replaceAll('.', '').replaceAll(',', '')),
            rentalPrice: int.parse(_state.rentalPriceController.text.replaceAll('R\$ ', '').replaceAll('.', '').replaceAll(',', '')),
            depositValue: int.parse(_state.depositValueController.text.replaceAll('R\$ ', '').replaceAll('.', '').replaceAll(',', '')),
            sellingPrice: _state.sellingPriceController.text.isNotEmpty ? int.parse(_state.sellingPriceController.text.replaceAll('R\$ ', '').replaceAll('.', '').replaceAll(',', '')) : null,
            timesRented: int.parse(_state.rentedTimesController.text),
            lastRentedAt: lastRentedAt,
            currentStatus: _state.selectedStatus!,
            photos: _state.selectedPhotos,
            notes: _state.notesController.text.isNotEmpty ? _state.notesController.text : null,
        );

        showDialog(
            context: _state.formKey.currentContext!,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
                content: Row(
                    children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text('Salvando vestido...'),
                    ],
                ),
            ),
        );
        bool success = await _bigQueryService.insert(Dress.tableId, newDress.toMap());
        Navigator.of(_state.formKey.currentContext!).pop();
        
        if (!success) {
            showDialog(
                context: _state.formKey.currentContext!,
                builder: (context) => AlertDialog(
                    title: Text('Erro'),
                    content: Text('Ocorreu um erro ao salvar o vestido. Por favor, tente novamente.'),
                    actions: [
                        TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('OK'),
                        ),
                    ],
                ),
            );
        }

        Navigator.of(_state.formKey.currentContext!).pop(true);
    }

    // TODO: Refactor this with a more "generic" way of formatting currency values as it currently adds the "." and "," in a very hacky way
    void onPriceChanged(String value, TextEditingController controller) {
        if (value.length > 2) {
            value = value.replaceAll(',', '');
            var prefix = value.substring(0, value.length - 2);
            var suffix = value.substring(value.length - 2);
            value = '$prefix,$suffix';
        }
        if (value.length > 6) {
            value = value.replaceAll('.', '');
            var prefix = value.substring(0, value.length - 6);
            var suffix = value.substring(value.length - 6);
            value = '$prefix.$suffix';
        }
        if (value.length > 10) {
            value = value.replaceAll('.', '');
            var prefix = value.substring(0, value.length - 6);
            var suffix = value.substring(value.length - 6);
            value = '$prefix.$suffix';
            prefix = value.substring(0, value.length - 10);
            suffix = value.substring(value.length - 10);
            value = '$prefix.$suffix';
        }

        controller.text = 'R\$ $value';
        controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
    }

    Future<String> generateDressCode() async {
        List<Dress> dresses = await _bigQueryService.selectAll(Dress.tableId, Dress.fromMap);
        int maxCode = 0;
        for (var dress in dresses) {
            final code = int.tryParse(dress.code) ?? 0;
            if (code > maxCode) {
                maxCode = code;
            }
        }

        _state.codeController.text = (maxCode + 1).toString().padLeft(6, '0');
        return _state.codeController.text;
    }
}