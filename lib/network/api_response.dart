class ApiResponse<T> {
  const ApiResponse({this.data, this.message, required this.success});

  final T? data;
  final String? message;
  final bool success;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse(
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      message: json['message'] as String?,
      success: json['success'] as bool? ?? true,
    );
  }
}
