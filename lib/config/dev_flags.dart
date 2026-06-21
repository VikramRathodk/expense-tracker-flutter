/// Development-only flags. Set kBypassAuth = true to skip login during dev.
/// NEVER ship with kBypassAuth = true.
const bool kBypassAuth = false;

const _devUser = {
  'id': 1,
  'name': 'Dev User',
  'email': 'dev@localhost',
  'roles': ['USER'],
  'isActive': true,
  'createdAt': '2024-01-01T00:00:00Z',
  'baseCurrency': 'INR',
};

// Exported so AuthBloc can emit it without importing the whole map.
Map<String, dynamic> get devUserJson => _devUser;
