import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_crossword/core/state/user_state.dart';
import 'package:sliding_crossword/features/login/ui/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoginPage();
        }
        return const _ProfilePagePresenter();
      },
    );
  }
}

class _ProfilePagePresenter extends StatelessWidget {
  const _ProfilePagePresenter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _userState = Provider.of<UserState>(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: _userState.signOut,
                icon: const Icon(Icons.exit_to_app)),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Puzzles'),
              Tab(text: 'Under Review'),
            ],
          ),
        ),
        body: const TabBarView(
          physics: BouncingScrollPhysics(),
          children: [
            Center(child: Text('My Puzzles')),
            Center(child: Text('Under Review')),
          ],
        ),
      ),
    );
  }
}
