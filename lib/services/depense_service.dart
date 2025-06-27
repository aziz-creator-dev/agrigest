import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agrigest/models/depense.dart';

class DepenseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Depense>> getDepenses() async {
    final response = await _supabase
        .from('depenses')
        .select()
        .order('date', ascending: false);
    return response.map<Depense>((depense) => Depense.fromJson(depense)).toList();
  }

  Future<void> addDepense(Depense depense) async {
    await _supabase.from('depenses').insert(depense.toJson());
  }

  Future<void> updateDepense(Depense depense) async {
    await _supabase
        .from('depenses')
        .update(depense.toJson())
        .eq('id', depense.id);
  }

  Future<void> deleteDepense(String id) async {
    await _supabase.from('depenses').delete().eq('id', id);
  }

  Future<String?> uploadJustificatif(String filePath) async {
  final fileName = 'justificatifs/${DateTime.now().millisecondsSinceEpoch}.jpg';
  final file = File(filePath);
  final response = await _supabase.storage
      .from('depenses')
      .upload(fileName, file);
  
  // If you're using supabase_flutter >=1.10.0 and get a StorageException:
  // if (response is StorageException) throw response;
  // If response is String path (success), continue.

  // Get public URL
  return _supabase.storage
      .from('depenses')
      .getPublicUrl(fileName);
}

}