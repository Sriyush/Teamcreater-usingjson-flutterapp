import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PaginationController extends GetxController {
  final itemsPerPage = 10.obs; // Number of items to load per page
  final currentPage = 0.obs; // Current page index
  final userDataList = <Map<String, dynamic>>[].obs; // List of user data

  @override
  void onInit() {
    super.onInit();
    // Load initial data when the controller is initialized
    loadPage(currentPage.value);
  }

  Future<void> loadPage(int page) async {
    // You can load data from an API or any other source here
    // For example, load data from your JSON asset file
    try {
      final String jsonStr = await rootBundle.loadString('assets/heliverse_mock_data.json');
      final List<dynamic> data = json.decode(jsonStr);
      final startIndex = page * itemsPerPage.value;
      final endIndex = (page + 1) * itemsPerPage.value;

      if (startIndex < data.length) {
        final pageData = data.sublist(startIndex, endIndex.clamp(0, data.length));
        userDataList.addAll(List<Map<String, dynamic>>.from(pageData));
      }
    } catch (e) {
      print("Error loading JSON data: $e");
    }
  }
}
