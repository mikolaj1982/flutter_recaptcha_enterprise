import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_recaptcha_enterprise/flutter_recaptcha_enterprise.dart';
import 'package:flutter_recaptcha_enterprise/recaptcha_action.dart';

import 'package:http/http.dart' as http;

import 'dart:developer' as devtools show log;

extension Log on Object {
  void log() => devtools.log(toString());
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final flutterRecaptchaEnterprise = FlutterRecaptchaEnterprise();

  String result = "action";
  String score = "unknown";

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String envRaw = await rootBundle.loadString('assets/env.json');
    var env = json.decode(envRaw) as Map<String, dynamic>;

    String siteKeyAndroid = env["siteKeyAndroid"];
    String siteKeyIOS = env["siteKeyIOS"];

    if (Platform.isAndroid) {
      await flutterRecaptchaEnterprise.setupAndroid(siteKeyAndroid);
    } else {
      await flutterRecaptchaEnterprise.setupIOS(siteKeyIOS);
    }

    String token = await getToken();
    setState(() {
      // log(token);
      result = token;
    });
  }

  Future<String> getToken() async{
    String customAction = "test";
    String result = await flutterRecaptchaEnterprise.execute(RecaptchaAction.custom(customAction));
    return result;
  }

  Future<double?> getRecaptchaScore(String token) async {
    String envRaw = await rootBundle.loadString('assets/env.json');
    var env = json.decode(envRaw) as Map<String, dynamic>;

    String siteKeyIOS = env["siteKeyIOS"];
    String projectId = env["PROJECT_ID"];
    String apiKey = env["API_KEY"];
    String siteKeyAndroid = env["siteKeyAndroid"];

    var siteKey = "";
    if (Platform.isAndroid) {
      siteKey = siteKeyAndroid;
    } else {
      siteKey = siteKeyIOS;
    }

    final recaptchaApiUrl = 'https://recaptchaenterprise.googleapis.com/v1/projects/$projectId/assessments?key=$apiKey';
    final requestBody = json.encode({
      "event": {
        "token": token,
        "siteKey": siteKey,
        "expectedAction": "login",
      },
    });
    final response = await http.post(
      Uri.parse(recaptchaApiUrl),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    final result = json.decode(response.body);
    result.toString().log();
    double score = result['riskAnalysis']['score'] as double;
    return score;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // TextButton(
                //   onPressed: () async {
                //     await initPlatformState();
                //
                //     setState(() {
                //       result = "ok";
                //     });
                //   },
                //   child: const Text("setup"),
                // ),
                // TextButton(
                //   onPressed: () async {
                //     // String customAction = "test";
                //     //
                //     // String result = await flutterRecaptchaEnterprise.execute(RecaptchaAction.custom(customAction));
                //
                //     String token = await getToken();
                //
                //     setState(() {
                //       log(token);
                //       this.result = token;
                //     });
                //   },
                //   child: Text(result),
                // ),
                Text(result),
                TextButton(
                  onPressed: () async {
                    final token = result;
                    final tempScore = await getRecaptchaScore(token);
                    setState(() {
                      score = tempScore.toString();
                    });
                    print('reCAPTCHA score: $score');
                  },
                  child: Text("get the score: $score"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
