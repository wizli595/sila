import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/connection.dart';

abstract class InboxRepository {
  Future<Either<Failure, List<Connection>>> getMyConnections();
  Stream<Connection> onNewConnection();
}
