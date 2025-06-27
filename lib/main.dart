import 'package:flutter/material.dart';
import 'package:agrigest/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://oonizclzxmtfxitektwy.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9vbml6Y2x6eG10ZnhpdGVrdHd5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk4NTA4NjcsImV4cCI6MjA2NTQyNjg2N30.97y30jbU1SsV7-hXgnXVRNUVq6-rOXpe_bbeUd2Gow0',
  );

  runApp(const AgriGestApp());
}