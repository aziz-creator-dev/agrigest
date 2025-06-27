import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agrigest/models/tache.dart';

class TacheService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Tache>> getTachesByClient(String clientId) async {
    final response = await _supabase
        .from('taches')
        .select()
        .eq('client_id', clientId)
        .order('date', ascending: false);
    return response.map<Tache>((tache) => Tache.fromJson(tache)).toList();
  }

  Future<List<Tache>> getAllTaches() async {
    final response = await _supabase
        .from('taches')
        .select()
        .order('date', ascending: false);
    return response.map<Tache>((tache) => Tache.fromJson(tache)).toList();
  }

  Future<Tache> getTache(String id) async {
    final response = await _supabase
        .from('taches')
        .select()
        .eq('id', id)
        .single();
    return Tache.fromJson(response);
  }

  Future<void> addTache(Tache tache) async {
    await _supabase.from('taches').insert(tache.toJson());
  }

  Future<void> updateTache(Tache tache) async {
    await _supabase
        .from('taches')
        .update(tache.toJson())
        .eq('id', tache.id);
  }

  Future<void> deleteTache(String id) async {
    await _supabase.from('taches').delete().eq('id', id);
  }

  Future<void> markAsPaid(String id, bool isPaid) async {
    await _supabase
        .from('taches')
        .update({'est_paye': isPaid})
        .eq('id', id);
  }
}