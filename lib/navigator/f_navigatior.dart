import 'package:flutter/material.dart';
import 'package:flutter_project/page/home_page.dart';
import 'package:flutter_project/page/login_page.dart';
import 'package:flutter_project/page/register_page.dart';
import 'package:flutter_project/page/video_detail_page.dart';

///路由状态变化listener
///通过堆栈信息发送变化来判断
typedef RouteChangeListener(RouteStatusInfo curInfo, RouteStatusInfo preInfo);

///创建页面
pageWrap(Widget child) {
  return MaterialPage(key: ValueKey(child.hashCode), child: child);
}

///page在堆栈中的位置
int getPageIndex(List<MaterialPage> pages, RouteStatus status) {
  for (int i = 0; i < pages.length; i++) {
    MaterialPage page = pages[i];
    if (getStatus(page) == status) {
      return i;
    }
  }

  return -1;
}

///枚举，代表页面
enum RouteStatus { login, register, home, detail, unknown }

RouteStatus getStatus(MaterialPage page) {
  if (page.child is LoginPage) {
    return RouteStatus.login;
  } else if (page.child is RegisterPage) {
    return RouteStatus.register;
  } else if (page.child is HomePage) {
    return RouteStatus.home;
  } else if (page.child is VideoDetailPage) {
    return RouteStatus.detail;
  } else {
    return RouteStatus.unknown;
  }
}

class RouteStatusInfo {
  final RouteStatus routeStatus;
  final Widget page;

  RouteStatusInfo(this.routeStatus, this.page);
}

///页面跳转
class FNavigator extends _RouteJumpListener {
  static FNavigator? _instance;
  RouteJumpListener? routeJumpListener;
  List<RouteChangeListener> _listener = [];

  RouteStatusInfo? _cur;

  static FNavigator? getInstance() {
    if (_instance == null) {
      _instance = FNavigator();
    }
    return _instance;
  }

  void addRouteListener(RouteChangeListener listener) {
    if (!_listener.contains(listener)) {
      _listener.add(listener);
    }
  }

  void removeRouteListener(RouteChangeListener listener) {
    if (_listener.contains(listener)) {
      _listener.remove(listener);
    }
  }

  void notify(List<MaterialPage> curPages, List<MaterialPage> prePages) {
    if (curPages == prePages) return;

    //取最顶部
    var cur = RouteStatusInfo(getStatus(curPages.last), curPages.last.child);
    _notify(cur);
  }

  //注册跳转listener
  void registerRouteJumpListener(RouteJumpListener listener) {
    this.routeJumpListener = listener;
  }

  @override
  void onJumpTo(RouteStatus status, {Map? args}) {
    routeJumpListener!.onJumpTo!(status, args: args);
  }

  void _notify(RouteStatusInfo cur) {
    _listener.forEach((element) {
      element(cur,_cur!);
    });
    _cur = cur;
  }
}

abstract class _RouteJumpListener {
  void onJumpTo(RouteStatus status, {Map args});
}

typedef OnJumpTo = void Function(RouteStatus routeStatus, {Map? args});

class RouteJumpListener {
  final OnJumpTo? onJumpTo;

  RouteJumpListener({this.onJumpTo});
}
