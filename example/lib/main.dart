import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_openvpn/flutter_openvpn.dart';
import 'package:flutter_openvpn_example/newPage.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static Future<void> initPlatformState() async {
    await FlutterOpenvpn.lunchVpn(
      "client\n" +
          "proto udp\n" +
          "explicit-exit-notify\n" +
          "remote Spinexhost.ddns.net 1194\n" +
          "dev tun\n" +
          "resolv-retry infinite\n" +
          "nobind\n" +
          "persist-key\n" +
          "persist-tun\n" +
          "comp-lzo\n" +
          "remote-cert-tls server\n" +
          "verify-x509-name server_tdmgjzrSXXPjqfJ6 name\n" +
          "auth SHA256\n" +
          "auth-nocache\n" +
          "cipher AES-128-GCM\n" +
          "tls-client\n" +
          "tls-version-min 1.2\n" +
          "tls-cipher TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256\n" +
          "ignore-unknown-option block-outside-dns\n" +
          "setenv opt block-outside-dns # Prevent Windows 10 DNS leak\n" +
          "verb 3\n" +
          "<ca>\n" +
          "-----BEGIN CERTIFICATE-----\n" +
          "MIIB1zCCAX2gAwIBAgIUGxc0ZVNNzuxMmvwR/ouRuUJJsQcwCgYIKoZIzj0EAwIw\n" +
          "HjEcMBoGA1UEAwwTY25fbEE2NUVoVXNKa2lPQUhLSTAeFw0yMDA2MDQwODMzNDRa\n" +
          "Fw0zMDA2MDIwODMzNDRaMB4xHDAaBgNVBAMME2NuX2xBNjVFaFVzSmtpT0FIS0kw\n" +
          "WTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAASYO9+hZW6IZf+Go4QVDhF33i9PWocl\n" +
          "n1B1AoDSXJ6tCIdFiyU6CdKx0VsW7uXrRrF6KOsVWMtMugS9iCeu4/bso4GYMIGV\n" +
          "MB0GA1UdDgQWBBQXN7xsxOM6p1my43z90jLSC+KJ+DBZBgNVHSMEUjBQgBQXN7xs\n" +
          "xOM6p1my43z90jLSC+KJ+KEipCAwHjEcMBoGA1UEAwwTY25fbEE2NUVoVXNKa2lP\n" +
          "QUhLSYIUGxc0ZVNNzuxMmvwR/ouRuUJJsQcwDAYDVR0TBAUwAwEB/zALBgNVHQ8E\n" +
          "BAMCAQYwCgYIKoZIzj0EAwIDSAAwRQIhAIiOuvkTYETgi/s5vbYPHo1HAcA+JYII\n" +
          "OrS02Ji0lnAoAiBYQ7IhPSjemMXrF/IbOHtCtM2L82bugabUTL2VRWcfIQ==\n" +
          "-----END CERTIFICATE-----\n" +
          "</ca>\n" +
          "<cert>\n" +
          "-----BEGIN CERTIFICATE-----\n" +
          "MIIB1TCCAXygAwIBAgIRAMluJes+y++7DECAYkf81ZgwCgYIKoZIzj0EAwIwHjEc\n" +
          "MBoGA1UEAwwTY25fbEE2NUVoVXNKa2lPQUhLSTAeFw0yMDA2MTgxNzEzMjhaFw0y\n" +
          "MjA5MjExNzEzMjhaMA4xDDAKBgNVBAMMA09UMzBZMBMGByqGSM49AgEGCCqGSM49\n" +
          "AwEHA0IABJSeuwW1JduX3OhcVzmJK63XTZa1mO18h3DoRVryuzE+WKJrjSTWYG9u\n" +
          "FrxoASfUVWpuBR/nlbvLV6KnAn8KbSmjgaowgacwCQYDVR0TBAIwADAdBgNVHQ4E\n" +
          "FgQUrVtLZ9E/VgY8a6uIaNlBl1d0Z9kwWQYDVR0jBFIwUIAUFze8bMTjOqdZsuN8\n" +
          "/dIy0gviifihIqQgMB4xHDAaBgNVBAMME2NuX2xBNjVFaFVzSmtpT0FIS0mCFBsX\n" +
          "NGVTTc7sTJr8Ef6LkblCSbEHMBMGA1UdJQQMMAoGCCsGAQUFBwMCMAsGA1UdDwQE\n" +
          "AwIHgDAKBggqhkjOPQQDAgNHADBEAiBzGXi0jnyzysWmGe0HYJoJB9mTqcKMN9ht\n" +
          "zJwK+qIXXgIgGKxXR4jhJ9YYeuCLJ/Z1camGwZLxxC+rPuOD/Jn8Yvc=\n" +
          "-----END CERTIFICATE-----\n" +
          "</cert>\n" +
          "<key>\n" +
          "-----BEGIN PRIVATE KEY-----\n" +
          "MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgIacaVJxPiDjJrpYp\n" +
          "p700ipTprqjWdZGnPklztu6A17ShRANCAASUnrsFtSXbl9zoXFc5iSut102WtZjt\n" +
          "fIdw6EVa8rsxPliia40k1mBvbha8aAEn1FVqbgUf55W7y1eipwJ/Cm0p\n" +
          "-----END PRIVATE KEY-----\n" +
          "</key>\n" +
          "<tls-crypt>\n" +
          "#\n" +
          "# 2048 bit OpenVPN static key\n" +
          "#\n" +
          "-----BEGIN OpenVPN Static key V1-----\n" +
          "4982f6965050647352a88185ba450805\n" +
          "0083706c8712cef410e1d52653839d6b\n" +
          "ff7e40a40fbf637302b2270e0476f525\n" +
          "53cb97cb96bae5737c5de6e50f4e1cfb\n" +
          "f205ff89b31db732b8d6ebf22fa4e132\n" +
          "c2f393920ecd9d94dd40aafb8d5c6e9e\n" +
          "871c1eab53f6d43c9672b965824b8364\n" +
          "f9b8d23c668a51a8d89c0b5d70f3dabd\n" +
          "4e22a2d4080f65dbde3b1c1036728624\n" +
          "c3a059e545a3e6616ed402356ef35560\n" +
          "5f177fdac00c74f2f7a355ab0b7932d5\n" +
          "f6e5d56870b0bdbc6d715c4ea676d94d\n" +
          "acc171386792946cb3d1a33527456b1d\n" +
          "7b19342e1cb01a74a26bc4e1fc8557cb\n" +
          "e2a16417cf4ad210ce635dac80e661b4\n" +
          "aa4c70840c3a757919480a566d6fe504\n" +
          "-----END OpenVPN Static key V1-----\n" +
          "</tls-crypt>\n",
      (isProfileLoaded) {
        print('isProfileLoaded : $isProfileLoaded');
      },
      (vpnActivated) {
        print('vpnActivated : $vpnActivated');
      },
      expireAt: DateTime.now().add(
        Duration(
          seconds: 180,
        ),
      ),
    );
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (context) => NewPAge(
              settings.name.contains(NewPAge.subPath)
                  ? settings.name.split(NewPAge.subPath)[1]
                  : '0',
              settings.name.split(NewPAge.subPath)[1].compareTo('2') < 0),
          settings: settings),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: NewPAge('0', true),
      ),
    );
  }
}
