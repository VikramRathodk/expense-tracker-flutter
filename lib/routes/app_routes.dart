class AppRoutes {
  const AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';

  // Shell routes (bottom nav)
  static const String dashboard = '/dashboard';
  static const String expenses = '/expenses';
  static const String expenseNew = '/expenses/new';
  static const String expenseDetail = '/expenses/:id';
  static const String expenseEdit = '/expenses/:id/edit';
  static const String budgets = '/budgets';
  static const String budgetDetail = '/budgets/:id';
  static const String recurring = '/recurring';
  static const String categories = '/categories';
  static const String tags = '/tags';
  static const String notifications = '/notifications';
  static const String profile = '/profile';

  // Role-gated
  static const String reports = '/reports';
  static const String auditLogs = '/audit-logs';
}
