import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:plena_veste/database/models/dress.dart';

class DressDetailState extends ChangeNotifier {
    final Dress originalDress;
    final Dress dress;

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController codeController = TextEditingController();
    final TextEditingController modelController = TextEditingController();
    final TextEditingController colorController = TextEditingController();
    final TextEditingController sizeController = TextEditingController();
    final TextEditingController purchasePriceController = TextEditingController();
    final TextEditingController rentalPriceController = TextEditingController();
    final TextEditingController depositValueController = TextEditingController();
    final TextEditingController sellingPriceController = TextEditingController();
    final TextEditingController rentedTimesController = TextEditingController();
    final TextEditingController lastRentedAtController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    final PageController photosPageController = PageController();

    DressDetailState({required this.dress}) : originalDress = dress {
        codeController.text = dress.code;
        modelController.text = dress.model;
        colorController.text = dress.color;
        sizeController.text = dress.size.toString();
        purchasePriceController.text = dress.purchasePrice.toString();
        rentalPriceController.text = dress.rentalPrice.toString();
        depositValueController.text = dress.depositValue.toString();
        sellingPriceController.text = dress.sellingPrice?.toString() ?? '';
        rentedTimesController.text = dress.timesRented.toString();
        lastRentedAtController.text = dress.lastRentedAt != null ? '${dress.lastRentedAt!.day.toString().padLeft(2, '0')}/${dress.lastRentedAt!.month.toString().padLeft(2, '0')}/${dress.lastRentedAt!.year}' : '';
        notesController.text = dress.notes ?? '';
        selectedCategory = dress.category;
        selectedLength = dress.length;
        isAdjustable = dress.isAdjustable;
        selectedStatus = dress.currentStatus;
    }

    final MaskTextInputFormatter lastRentedAtFormatter = MaskTextInputFormatter(
        mask: '##/##/####',
        filter: {
            '#': RegExp(r'[0-9]'),
        },
        type: MaskAutoCompletionType.lazy,
    );

    DressCategory? selectedCategory;
    DressLength? selectedLength;
    bool isAdjustable = false;
    DressStatus? selectedStatus;
}