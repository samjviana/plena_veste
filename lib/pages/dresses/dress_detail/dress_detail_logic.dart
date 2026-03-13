import 'package:flutter/material.dart';
import 'package:plena_veste/database/bigquery_service.dart';
import 'package:plena_veste/database/models/dress.dart';
import 'package:plena_veste/di.dart';
import 'package:plena_veste/pages/dresses/dress_detail/dress_detail_state.dart';

class DressDetailLogic {
    final DressDetailState _state;
    final Function(void Function()) _setState;
    final BigQueryService _bigQueryService = getIt<BigQueryService>();

    DressDetailLogic(this._state, this._setState) {
        _state.purchasePriceController.text = formatPrice(_state.dress.purchasePrice);
        _state.rentalPriceController.text = formatPrice(_state.dress.rentalPrice);
        _state.depositValueController.text = formatPrice(_state.dress.depositValue);
        if (_state.dress.sellingPrice != null) {
            _state.sellingPriceController.text = formatPrice(_state.dress.sellingPrice!);
        }
    }

    void onPrevPhotoPressed() {
        int currentPage = _state.photosPageController.page?.round() ?? 0;
        int prevPage = currentPage > 0 ? currentPage - 1 : _state.dress.photos!.length - 1;
        _state.photosPageController.animateToPage(
            prevPage,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
        );
    }

    void onNextPhotoPressed() {
        int currentPage = _state.photosPageController.page?.round() ?? 0;
        int nextPage = currentPage < _state.dress.photos!.length - 1 ? currentPage + 1 : 0;
        _state.photosPageController.animateToPage(
            nextPage,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
        );
    }

    void onRemovePhotoPressed() {
        int currentPage = _state.photosPageController.page?.round() ?? 0;
        if (_state.dress.photos!.isEmpty) {
            return;
        }
        _setState(() {
            _state.dress.photos!.removeAt(currentPage);
        });
    }

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

    // TODO: Refactor this with a more "generic" way of formatting currency values as it currently adds the "." and "," in a very hacky way
    String formatPrice(int value) {
        String stringValue = value.toString();
        if (stringValue.length > 2) {
            stringValue = stringValue.replaceAll(',', '');
            var prefix = stringValue.substring(0, stringValue.length - 2);
            var suffix = stringValue.substring(stringValue.length - 2);
            stringValue = '$prefix,$suffix';
        }
        if (stringValue.length > 6) {
            stringValue = stringValue.replaceAll('.', '');
            var prefix = stringValue.substring(0, stringValue.length - 6);
            var suffix = stringValue.substring(stringValue.length - 6);
            stringValue = '$prefix.$suffix';
        }
        if (stringValue.length > 10) {
            stringValue = stringValue.replaceAll('.', '');
            var prefix = stringValue.substring(0, stringValue.length - 6);
            var suffix = stringValue.substring(stringValue.length - 6);
            stringValue = '$prefix.$suffix';
            prefix = stringValue.substring(0, stringValue.length - 10);
            suffix = stringValue.substring(stringValue.length - 10);
            stringValue = '$prefix.$suffix';
        }
        return 'R\$ $stringValue';
    }

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

    void onSavePressed() async {
        bool shouldUpdate = false;
        if (_state.codeController.text != _state.dress.code) {
            _state.dress.code = _state.codeController.text;
            shouldUpdate = true;
        }
        if (_state.modelController.text != _state.dress.model) {
            _state.dress.model = _state.modelController.text;
            shouldUpdate = true;
        }
        if (_state.selectedCategory != _state.dress.category) {
            _state.dress.category = _state.selectedCategory!;
            shouldUpdate = true;
        }
        if (_state.selectedLength != _state.dress.length) {
            _state.dress.length = _state.selectedLength!;
            shouldUpdate = true;
        }
        if (_state.colorController.text != _state.dress.color) {
            _state.dress.color = _state.colorController.text;
            shouldUpdate = true;
        }
        if (int.tryParse(_state.sizeController.text) != _state.dress.size) {
            _state.dress.size = int.tryParse(_state.sizeController.text) ?? _state.dress.size;
            shouldUpdate = true;
        }
        if (_state.isAdjustable != _state.dress.isAdjustable) {
            _state.dress.isAdjustable = _state.isAdjustable;
            shouldUpdate = true;
        }

        int purchasePrice = int.tryParse(_state.purchasePriceController.text.replaceAll('R\$ ', '').replaceAll('.', '').replaceAll(',', '')) ?? _state.dress.purchasePrice;
        int rentalPrice = int.tryParse(_state.rentalPriceController.text.replaceAll('R\$ ', '').replaceAll('.', '').replaceAll(',', '')) ?? _state.dress.rentalPrice;
        int depositValue = int.tryParse(_state.depositValueController.text.replaceAll('R\$ ', '').replaceAll('.', '').replaceAll(',', '')) ?? _state.dress.depositValue;
        int? sellingPrice;
        if (_state.sellingPriceController.text.isNotEmpty && _state.sellingPriceController.text.replaceAll('R\$ ', '').replaceAll('.', '').isNotEmpty) {
            sellingPrice = int.tryParse(_state.sellingPriceController.text.replaceAll('R\$ ', '').replaceAll('.', '').replaceAll(',', '')) ?? _state.dress.sellingPrice;
        } else {
            sellingPrice = null;
        }

        if (purchasePrice != _state.dress.purchasePrice) {
            _state.dress.purchasePrice = purchasePrice;
            shouldUpdate = true;
        }
        if (rentalPrice != _state.dress.rentalPrice) {
            _state.dress.rentalPrice = rentalPrice;
            shouldUpdate = true;
        }
        if (depositValue != _state.dress.depositValue) {
            _state.dress.depositValue = depositValue;
            shouldUpdate = true;
        }
        if (sellingPrice != _state.dress.sellingPrice) {
            _state.dress.sellingPrice = sellingPrice;
            shouldUpdate = true;
        }

        if (int.tryParse(_state.rentedTimesController.text) != _state.dress.timesRented) {
            _state.dress.timesRented = int.tryParse(_state.rentedTimesController.text) ?? _state.dress.timesRented;
            shouldUpdate = true;
        }
        if (_state.lastRentedAtController.text.isNotEmpty) {
            DateTime? lastRentedAt;
            List<String> dateParts = _state.lastRentedAtController.text.split('/');
            if (dateParts.length == 3) {
                int day = int.parse(dateParts[0]);
                int month = int.parse(dateParts[1]);
                int year = int.parse(dateParts[2]);
                lastRentedAt = DateTime(year, month, day);
            }

            if (lastRentedAt != null && lastRentedAt != _state.dress.lastRentedAt) {
                _state.dress.lastRentedAt = lastRentedAt;
                shouldUpdate = true;
            }
        } else if (_state.dress.lastRentedAt != null) {
            _state.dress.lastRentedAt = null;
            shouldUpdate = true;
        }
        if (_state.selectedStatus != _state.dress.currentStatus) {
            _state.dress.currentStatus = _state.selectedStatus!;
            shouldUpdate = true;
        }
        if (_state.originalDress.photos != _state.dress.photos) {
            _state.originalDress.photos = _state.dress.photos;
            shouldUpdate = true;
        }
        if (_state.notesController.text != (_state.dress.notes ?? '')) {
            _state.dress.notes = _state.notesController.text.isNotEmpty ? _state.notesController.text : null;
            shouldUpdate = true;
        }

        if (shouldUpdate) {
            showDialog(
                context: _state.formKey.currentContext!,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                    content: Row(
                        children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 16),
                            Text('Salvando edições...'),
                        ],
                    ),
                ),
            );

            bool success = await _bigQueryService.update(Dress.tableId, _state.dress);
            Navigator.of(_state.formKey.currentContext!).pop();

            if (!success) {
                showDialog(
                    context: _state.formKey.currentContext!,
                    builder: (context) => AlertDialog(
                        title: Text('Erro'),
                        content: Text('Ocorreu um erro ao salvar as edições. Por favor, tente novamente.'),
                        actions: [
                            TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('OK'),
                            ),
                        ],
                    ),
                );
            }

            Navigator.of(_state.formKey.currentContext!).pop(success);
        }
    }
}