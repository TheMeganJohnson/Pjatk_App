import 'package:flutter/material.dart';
import 'package:dartdap/dartdap.dart';
import 'globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

class TestingPage extends StatelessWidget {
  Future<void> testLdapConnection() async {
    const String ldapHost = 'pjwstk.edu.pl';
    const int ldapPort = 389;
    const int ldapsPort = 636;
    const String bindDN = 'cn=s23576,ou=usrs,dc=pjwstk,dc=edu,dc=pl';
    const String password = '5123Noodle3215';
    const String baseDN = 'dc=pjwstk,dc=edu,dc=pl';

    Future<bool> tryLdap({required bool ssl, required int port}) async {
      try {
        final ldap = LdapConnection(
          host: ldapHost,
          port: port,
          ssl: ssl,
          bindDN: DN(bindDN),
          password: password,
        );
        await ldap.bind(dn: DN(bindDN), password: password);
        print('LDAP bind successful! (SSL: $ssl, Port: $port)');

        final searchResult = await ldap.search(
          DN(baseDN),
          Filter.present('objectClass'),
          ['dn'],
        );

        await for (final entry in searchResult.stream) {
          print('Found entry: ${entry.dn}');
        }

        await ldap.close();
        print('LDAP connection closed.');
        return true;
      } catch (e) {
        print('LDAP connection failed (SSL: $ssl, Port: $port): $e');
        return false;
      }
    }

    bool connected = await tryLdap(ssl: false, port: ldapPort);
    if (!connected) {
      connected = await tryLdap(ssl: true, port: ldapsPort);
      if (!connected) {
        print('LDAP connection failed: Could not connect with or without SSL.');
      }
    }
  }

  Future<void> resetFirstLoginFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_logged_in', false);
    await prefs.remove('user_pin');
    print('First login flag and PIN have been reset.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Testing Page'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () async {
                await testLdapConnection();
              },
              child: Text('Test LDAP Connection'),
            ),
            SizedBox(height: 16), // Space between buttons
            ElevatedButton(
              onPressed: () {
                print('lastScannedQrContent: ${globals.lastScannedQrContent}');
              },
              child: Text('Print lastScannedQrContent'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await resetFirstLoginFlag();
              },
              child: Text('Reset First Login & PIN'),
            ),
          ],
        ),
      ),
    );
  }
}