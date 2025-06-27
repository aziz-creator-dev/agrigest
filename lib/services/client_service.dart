import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agrigest/models/client.dart';

class ClientService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Client>> getClients() async {
    final response = await _supabase
        .from('clients')
        .select()
        .order('date_creation', ascending: false);

    return response.map<Client>((client) => Client.fromJson(client)).toList();
  }

  Future<Client> getClient(String id) async {
    final response = await _supabase
        .from('clients')
        .select()
        .eq('id', id)
        .single();

    return Client.fromJson(response);
  }

  Future<void> addClient(Client client) async {
    await _supabase.from('clients').insert(client.toJson());
  }

  Future<void> updateClient(Client client) async {
    await _supabase
        .from('clients')
        .update(client.toJson())
        .eq('id', client.id);
  }

  Future<void> deleteClient(String id) async {
    await _supabase.from('clients').delete().eq('id', id);
  }
}