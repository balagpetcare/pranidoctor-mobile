import 'package:flutter/material.dart';

/// Root navigator for global redirects (e.g. Dio 401 → login).
final pdRootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
