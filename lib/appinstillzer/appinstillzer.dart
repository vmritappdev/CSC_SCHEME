import 'package:csc/app.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:csc/localization/localizationpro.dart';


class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      final localizationProvider = Provider.of<LocalizationProvider>(context, listen: false);
      await localizationProvider.loadSavedLanguage();

      // Add more initializations here if needed
      // await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Initialization error: $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
   
      return const MyApp();
    }
  
}
