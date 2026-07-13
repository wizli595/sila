import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/inbox_repository_impl.dart';
import '../../domain/entities/connection.dart';
import '../../domain/repositories/inbox_repository.dart';

final inboxRepositoryProvider = Provider<InboxRepository>(
  (_) => InboxRepositoryImpl(Supabase.instance.client),
);

// Live connections list — updates in realtime when a thank-you arrives
final connectionsProvider = StreamProvider<List<Connection>>(
  (ref) => ref.watch(inboxRepositoryProvider).watchMyConnections(),
);
