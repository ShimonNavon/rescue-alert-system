import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:rxdart/rxdart.dart';

class DeepLinkService {
  DeepLinkService({AppLinks? appLinks}) : _appLinks = appLinks ?? AppLinks() {
    _init();
  }

  final AppLinks _appLinks;
  final BehaviorSubject<String?> _links = BehaviorSubject<String?>.seeded(null);
  StreamSubscription<Uri>? _sub;
  String? _pendingRoute;

  Stream<String?> get linkStream => _links.stream;

  Future<void> _init() async {
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _pendingRoute = initialLink.path;
      _links.add(_pendingRoute);
    }

    _sub = _appLinks.uriLinkStream.listen((uri) {
      _pendingRoute = uri.path;
      _links.add(_pendingRoute);
    });
  }

  void setPendingRoute(String route) {
    _pendingRoute = route;
    _links.add(route);
  }

  String? consumePendingRoute() {
    final route = _pendingRoute;
    _pendingRoute = null;
    return route;
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _links.close();
  }
}
