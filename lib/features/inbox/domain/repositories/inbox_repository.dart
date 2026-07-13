import '../entities/connection.dart';

abstract class InboxRepository {
  /// Live list of the user's connections, newest first.
  /// Initial fetch + realtime updates; RLS scopes rows to the owner.
  Stream<List<Connection>> watchMyConnections();
}
