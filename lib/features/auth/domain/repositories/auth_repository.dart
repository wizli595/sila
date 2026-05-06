import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, SilaUser>> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, SilaUser>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, SilaUser?>> currentUser();
}
