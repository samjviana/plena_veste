import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:plena_veste/database/models/dress.dart';

class AddDressState extends ChangeNotifier {
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

    DressCategory? selectedCategory;
    DressLength? selectedLength;
    bool isAdjustable = false;
    DressStatus? selectedStatus;
    List<Uint8List> selectedPhotos = [];

    final MaskTextInputFormatter lastRentedAtFormatter = MaskTextInputFormatter(
        mask: '##/##/####',
        filter: {
            '#': RegExp(r'[0-9]'),
        },
        type: MaskAutoCompletionType.lazy,
    );
}