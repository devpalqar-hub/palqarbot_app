class ApiResponse<T> {
  final bool success;
  final int statusCode;
  final T? data;
  final String? message;

  const ApiResponse({
    required this.success,
    required this.statusCode,
    this.data,
    this.message,
  });
}