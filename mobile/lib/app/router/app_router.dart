import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_user_detail_page.dart';
import '../../features/admin/presentation/pages/admin_user_edit_page.dart';
import '../../features/admin/presentation/pages/admin_user_register_page.dart';
import '../../features/admin/presentation/pages/admin_users_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/documents/presentation/pages/document_detail_page.dart';
import '../../features/documents/presentation/pages/document_edit_page.dart';
import '../../features/documents/presentation/pages/document_register_page.dart';
import '../../features/documents/presentation/pages/documents_page.dart';
import '../../features/expenses/presentation/pages/expense_detail_page.dart';
import '../../features/expenses/presentation/pages/expense_edit_page.dart';
import '../../features/expenses/presentation/pages/expense_register_page.dart';
import '../../features/expenses/presentation/pages/expenses_page.dart';
import '../../features/maintenance/presentation/pages/maintenance_detail_page.dart';
import '../../features/maintenance/presentation/pages/maintenance_page.dart';
import '../../features/maintenance/presentation/pages/maintenance_register_page.dart';
import '../../features/mileage/presentation/pages/mileage_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/vehicles/presentation/pages/vehicle_detail_page.dart';
import '../../features/vehicles/presentation/pages/vehicle_edit_page.dart';
import '../../features/vehicles/presentation/pages/vehicle_register_page.dart';
import '../../features/vehicles/presentation/pages/vehicles_page.dart';
import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: AppRoutes.adminDashboard,
      builder: (context, state) => const AdminDashboardPage(),
    ),
    GoRoute(
      path: AppRoutes.adminUsers,
      builder: (context, state) => const AdminUsersPage(),
    ),
    GoRoute(
      path: AppRoutes.adminUserRegister,
      builder: (context, state) => const AdminUserRegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.adminUserDetail,
      builder: (context, state) => const AdminUserDetailPage(),
    ),
    GoRoute(
      path: AppRoutes.adminUserEdit,
      builder: (context, state) => const AdminUserEditPage(),
    ),
    GoRoute(
      path: AppRoutes.vehicles,
      builder: (context, state) => const VehiclesPage(),
    ),
    GoRoute(
      path: AppRoutes.vehicleRegister,
      builder: (context, state) => const VehicleRegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.vehicleDetail,
      builder: (context, state) => const VehicleDetailPage(),
    ),
    GoRoute(
      path: AppRoutes.vehicleEdit,
      builder: (context, state) => const VehicleEditPage(),
    ),
    GoRoute(
      path: AppRoutes.maintenance,
      builder: (context, state) => const MaintenancePage(),
    ),
    GoRoute(
      path: AppRoutes.maintenanceRegister,
      builder: (context, state) => const MaintenanceRegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.maintenanceDetail,
      builder: (context, state) => const MaintenanceDetailPage(),
    ),
    GoRoute(
      path: AppRoutes.mileage,
      builder: (context, state) => const MileagePage(),
    ),
    GoRoute(
      path: AppRoutes.documents,
      builder: (context, state) => const DocumentsPage(),
    ),
    GoRoute(
      path: AppRoutes.documentRegister,
      builder: (context, state) => const DocumentRegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.documentDetail,
      builder: (context, state) => const DocumentDetailPage(),
    ),
    GoRoute(
      path: AppRoutes.documentEdit,
      builder: (context, state) => const DocumentEditPage(),
    ),
    GoRoute(
      path: AppRoutes.expenses,
      builder: (context, state) => const ExpensesPage(),
    ),
    GoRoute(
      path: AppRoutes.expenseRegister,
      builder: (context, state) => const ExpenseRegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.expenseDetail,
      builder: (context, state) => const ExpenseDetailPage(),
    ),
    GoRoute(
      path: AppRoutes.expenseEdit,
      builder: (context, state) => const ExpenseEditPage(),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfilePage(),
    ),
  ],
);
