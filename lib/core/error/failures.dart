sealed class Failure {
  final String message;
  final String? code;
  const Failure(this.message, {this.code});

  @override
  String toString() => 'Failure($code): $message';
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

class PaymentFailure extends Failure {
  final String method;
  const PaymentFailure(super.message, {required this.method, super.code});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred']);
}
