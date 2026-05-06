import 'package:flutter/material.dart';
import 'utils/storage_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage
  await StorageService.init();

  runApp(const NaddefliApp());
}
