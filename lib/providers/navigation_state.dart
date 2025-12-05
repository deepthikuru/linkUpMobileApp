import 'package:flutter/foundation.dart';

enum FooterTab {
  home,
  plans,
  chat,
  profile,
}

enum Destination {
  splash,
  login,
  startNewOrder,
  orderFlow,
  orderDetails,
  home;

  @override
  String toString() {
    switch (this) {
      case Destination.splash:
        return 'splash';
      case Destination.login:
        return 'login';
      case Destination.startNewOrder:
        return 'startNewOrder';
      case Destination.orderFlow:
        return 'orderFlow';
      case Destination.orderDetails:
        return 'orderDetails';
      case Destination.home:
        return 'home';
    }
  }
}

class NavigationState extends ChangeNotifier {
  bool showSplash = false;
  bool showPreviousOrders = false;
  bool showContactInfoDetail = false;
  bool showInternationalLongDistance = false;
  bool showPrivacyPolicy = false;
  bool showTermsAndConditions = false;
  String? currentOrderId;
  int? orderStartStep;
  String? lastAppliedResumeForOrderId;
  Destination currentDestination = Destination.startNewOrder;
  FooterTab currentFooterTab = FooterTab.home;
  
  // Callback for programmatic tab navigation
  Function(FooterTab)? onNavigateToTab;

  void navigateTo(Destination destination) {
    currentDestination = destination;
    notifyListeners();
  }

  void resumeOrder(String orderId, int step) {
    currentOrderId = orderId;
    orderStartStep = step;
    navigateTo(Destination.orderFlow);
  }

  void showSplashScreen() {
    currentDestination = Destination.splash;
    showSplash = true;
    resetNavigation();
  }

  void setFooterTab(FooterTab tab) {
    currentFooterTab = tab;
    notifyListeners();
  }
  
  void navigateToTab(FooterTab tab) {
    setFooterTab(tab);
    if (onNavigateToTab != null) {
      onNavigateToTab!(tab);
    }
  }

  void resetNavigation() {
    currentDestination = Destination.splash;
    showSplash = false;
    showPreviousOrders = false;
    showContactInfoDetail = false;
    showInternationalLongDistance = false;
    showPrivacyPolicy = false;
    showTermsAndConditions = false;
    currentOrderId = null;
    orderStartStep = null;
    lastAppliedResumeForOrderId = null;
    currentFooterTab = FooterTab.home;
    notifyListeners();
  }
}

