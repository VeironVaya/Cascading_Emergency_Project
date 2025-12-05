import 'package:get/get.dart';

import 'package:project_hellping/modules/home/home_binding.dart';
import 'package:project_hellping/modules/home/home_view.dart';

import 'package:project_hellping/modules/priority/priority_binding.dart';
import 'package:project_hellping/modules/priority/priority_view.dart';

import '../modules/auth/login/login_binding.dart';
import '../modules/auth/login/login_view.dart';

import '../modules/auth/signup/signup_binding.dart';
import '../modules/auth/signup/signup_view.dart';

import '../modules/group/create_group/create_group_binding.dart';
import '../modules/group/create_group/create_group_view.dart';

// import '../modules/group/join_group/join_group_binding.dart';
// import '../modules/group/join_group/join_group_view.dart';

import 'package:project_hellping/modules/group/group_detail/group_detail_binding.dart';
import 'package:project_hellping/modules/group/group_detail/group_detail_view.dart';

import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.SIGNUP,
      page: () => const SignupView(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.CREATE_GROUP,
      page: () => const CreateGroupView(),
      binding: CreateGroupBinding(),
    ),
    // GetPage(
    //   name: AppRoutes.JOIN_GROUP,
    //   page: () => const JoinGroupView(),
    //   binding: JoinGroupBinding(),
    // ),
    GetPage(
      name: AppRoutes.GROUP_DETAIL,
      page: () => const GroupDetailView(),
      binding: GroupDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.PRIORITY,
      page: () => const PriorityView(),
      binding: PriorityBinding(),
    ),
  ];
}
