// ignore_for_file: public_member_api_docs

class AuthValidator {
  static bool isValidPhone(String? phone) => (phone ?? '').length >= 6;
}
