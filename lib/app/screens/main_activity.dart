import 'dart:async';

import 'package:eClassify/app/widgets/bottom_navigation_bar/custom_bottom_navigation_bar.dart';
import 'package:eClassify/app/widgets/session_end_listener.dart';
import 'package:eClassify/app/widgets/version_update_dialog.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/cubits/app_update_cubit.dart';
import 'package:eClassify/core/cubits/bottom_nav_cubit.dart';
import 'package:eClassify/core/deep_link/deep_link_listener.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/features/chat/screens/inbox/chat_list_screen.dart';
import 'package:eClassify/features/home/screens/home_screen.dart';
import 'package:eClassify/features/item/screens/my_items/my_items_tab_screen.dart';
import 'package:eClassify/features/notification/listeners/notification_provider.dart';
import 'package:eClassify/features/profile/screens/profile_tab_screen.dart';
import 'package:eClassify/features/reels/screens/video_ads_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainActivity extends StatefulWidget {
  MainActivity({super.key});

  @override
  State<MainActivity> createState() => MainActivityState();

  static Route route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) =>
          NotificationProvider(child: DeepLinkListener(child: MainActivity())),
    );
  }
}

class MainActivityState extends State<MainActivity> {
  final PageController _pageController = PageController();

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    /// Check for updates
    versionCheck();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void versionCheck() async {
    final remoteVersion = Constant.systemSettings.version;
    final forceUpdate = Constant.systemSettings.forceUpdate;

    context.read<AppUpdateCubit>().checkForUpdates(
      required: remoteVersion,
      forceUpdate: forceUpdate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (context.read<BottomNavCubit>().state != BottomTab.home) {
          context.read<BottomNavCubit>().changeTab(BottomTab.home);
        } else {
          if (_timer == null) {
            _timer = Timer(const Duration(seconds: 2), () {
              _timer?.cancel();
              _timer = null;
            });
            HelperUtils.showSnackBarMessage(
              context,
              "pressAgainToExit".translate(context),
            );
          } else {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: CustomBottomNavigationBar(),
        body: SessionEndListener(
          child: MultiBlocListener(
            listeners: [
              BlocListener<AppUpdateCubit, AppUpdateState>(
                listener: (context, state) {
                  if (state is AppUpdateAvailable) {
                    VersionUpdateDialog.show(
                      context,
                      availableVersion: state.required,
                      isForceUpdate: state.isMandatory,
                    );
                  }
                },
              ),
              BlocListener<BottomNavCubit, BottomTab>(
                listener: (context, state) {
                  _pageController.jumpToPage(state.index);
                },
              ),
            ],
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const HomeScreen(),
                const ChatListScreen(),
                const VideoAdsScreen(),
                const MyItemsScreen(),
                const ProfileTabScreen(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
