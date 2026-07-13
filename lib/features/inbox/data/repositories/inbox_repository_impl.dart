import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/supabase_constants.dart';
import '../../domain/entities/connection.dart';
import '../../domain/repositories/inbox_repository.dart';
import '../models/connection_model.dart';

class InboxRepositoryImpl implements InboxRepository {
  final SupabaseClient _client;

  InboxRepositoryImpl(this._client);

  @override
  Stream<List<Connection>> watchMyConnections() {
    return _client
        .from(SupabaseConstants.connectionsTable)
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((rows) => rows.map(ConnectionModel.fromJson).toList());
  }
}
