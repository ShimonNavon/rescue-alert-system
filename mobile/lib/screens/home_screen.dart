import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rescue_app/domain/services/api/rest_api_service.dart';
import 'package:rescue_app/managers/storage_manager.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:rescue_app/constants/asset_paths.dart';
import 'event_tab_screen.dart';
import 'about_screen.dart';
import 'history_tab_screen.dart';
import 'map_tab_screen.dart';
import 'ptt_tab_screen.dart';
import 'settings_screen.dart';
import 'user_details_screen.dart';
import 'users_tab_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<String> _titles = <String>[
    'משתמשים',
    'אירועים',
    'PTT',
    'היסטוריה',
    'מפה',
  ];

  static const List<CurvedNavigationBarItem> _items = <CurvedNavigationBarItem>[
    CurvedNavigationBarItem(
      child: Icon(Icons.people),
      label: 'משתמשים',
    ),
    CurvedNavigationBarItem(
      child: Icon(Icons.warning),
      label: 'אירועים',
    ),
    CurvedNavigationBarItem(
      child: Icon(Icons.mic),
      label: 'PTT',
    ),
    CurvedNavigationBarItem(
      child: Icon(Icons.history),
      label: 'היסטוריה',
    ),
    CurvedNavigationBarItem(
      child: Icon(Icons.map),
      label: 'מפה',
    ),
  ];

  static const List<Widget> _screens = <Widget>[
    UsersTabScreen(),
    EventTabScreen(),
    PttTabScreen(),
    HistoryTabScreen(),
    MapTabScreen(),
  ];

  // @override
  // void initState() {
  //   super.initState();
  //   testApi();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_selectedIndex])),
      drawer: _buildDrawer(context),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        items: _items,
        // color: Colors.purple.shade300,
        // buttonBackgroundColor: Colors.deepPurple,
        // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        animationDuration: const Duration(milliseconds: 300),
        height: 78,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  void _showLogoutAlert(BuildContext context) {
    Alert(
      context: context,
      title: 'logout',
      desc: 'are you sure you wish to logout',
      buttons: [
        DialogButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            await StorageManager.instance.logout();
            // if (context.mounted) {
            //   Navigator.pop(context);
            // }
          },
          child: const Text(
            'OK',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        DialogButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          color: Colors.grey,
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ],
    ).show();
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: Image.asset(
                      AssetPaths.appLogo,
                      height: 74,
                      width: 74,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'מלאכים בדרכים',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('הגדרות'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('פרטי משתמש'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const UserDetailsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('אודות'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AboutScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'התנתקות',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            onTap: () {
              _showLogoutAlert(context);
            },
          ),
        ],
      ),
    );
  }

  Future testApi() async {
    RestApiService api = RestApiService();
    try {
      final users = await api.listUsersWithCoordinates();
      print('users with coordinates: $users');
    } catch (e) {
      print('error fetching user details: $e');
    }
  }
}
