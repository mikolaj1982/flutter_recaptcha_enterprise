import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_recaptcha_enterprise/recaptcha_action.dart';

import 'flutter_recaptcha_enterprise_platform_interface.dart';

class MethodChannelFlutterRecaptchaEnterprise
    extends FlutterRecaptchaEnterprisePlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_recaptcha_enterprise');

  @override
  Future<String> setupAndroid(String siteKeyAndroid) async {
    return await methodChannel
        .invokeMethod<void>('setup', {"siteKey": siteKeyAndroid}) as String;
  }

  @override
  Future<String> setupIOS(String siteKeyIOS) async {
    final result = await methodChannel
        .invokeMethod<void>('setup', {"siteKey": siteKeyIOS}) as String;
    print("setupIOS result: $result");
    return result;
  }

  @override
  Future<String> execute(RecaptchaAction action) async {
    final result = await methodChannel
        .invokeMethod<void>('execute', {"action": action.key}) as String;
    print("execute result: $result");
    return result;
  }
}
