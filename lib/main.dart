import 'package:flutter/material.dart';
import 'package:agrigest/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://oonizclzxmtfxitektwy.supabase.co',
  );

  runApp(const AgriGestApp());
}
