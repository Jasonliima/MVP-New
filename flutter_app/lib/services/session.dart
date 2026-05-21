class Session {
  // Variáveis estáticas para manter os dados globalmente acessíveis
  static String? token;
  static String? userId;
  static String? userName;
  static String? userRole;

  static void clear() {
    token = null;
    userId = null;
    userName = null;
    userRole = null;
  }
}
