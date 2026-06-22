class ApiConstants {
  const ApiConstants._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String mePassword = '/auth/me/password';
  static const String meCurrency = '/auth/me/currency';
  static const String assignRoles = '/auth/assign-roles';

  // Categories
  static const String categories = '/categories';
  static const String adminCategories = '/admin/categories';

  // Expenses
  static const String expenses = '/expenses';
  static const String expensesWithReceipt = '/expenses/with-receipt';
  static const String expensesFilter = '/expenses/filter';
  static const String expensesSearch = '/expenses/search';

  // Budgets
  static const String budgets = '/budgets';

  // Recurring
  static const String recurring = '/recurring-expenses';

  // Tags
  static const String tags = '/tags';

  // Exchange rates
  static const String exchangeRates = '/exchange-rates';
  static const String exchangeRatesConvert = '/exchange-rates/convert';

  // Dashboard
  static const String dashboard = '/dashboard';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread/count';
  static const String notificationsReadAll = '/notifications/read-all';

  // Reports
  static const String reportsSummary = '/reports/summary';
  static const String reportsTrends = '/reports/trends';
  static const String reportsCategoryWise = '/reports/category-wise';
  static const String reportsInsights = '/reports/insights';
  static const String reportsCustom = '/reports/custom';
  static const String reportsExport = '/reports/export';

  // Audit logs
  static const String auditLogs = '/audit-logs';
  static const String auditLogsMe = '/audit-logs/me';
}
