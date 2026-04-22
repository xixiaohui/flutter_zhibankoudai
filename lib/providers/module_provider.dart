import 'package:flutter/material.dart';
import '../models/module_config.dart';
import '../services/data_service.dart';
import '../config/constants.dart';

/// Module state management
class ModuleProvider extends ChangeNotifier {
  final DataService _dataService = DataService();

  List<ModuleConfig> _modules = [];
  List<ModuleConfig> get modules => _modules;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Load module configs
  Future<void> loadModules() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _modules = await _dataService.getModuleConfigs();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _modules = AppConstants.defaultModules
          .map((e) => ModuleConfig.fromJson(e))
          .toList();
      notifyListeners();
    }
  }

  ModuleConfig? getModuleById(String moduleId) {
    try {
      return _modules.firstWhere((m) => m.id == moduleId);
    } catch (_) {
      return null;
    }
  }
}