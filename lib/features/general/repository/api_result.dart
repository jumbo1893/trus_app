sealed class ApiResult<T> {}

class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  ApiSuccess(this.data);
}

class ApiError<T> extends ApiResult<T> {
  final String message;
  ApiError(this.message);
}

class ApiFieldError<T> extends ApiResult<T> {
  final Map<String, String> fieldErrors;
  ApiFieldError(this.fieldErrors);
}

class LoginExpired<T> extends ApiResult<T> {
  final String message;
  LoginExpired(this.message);
}