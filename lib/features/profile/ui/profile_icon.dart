import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileIcon extends StatelessWidget {
  const ProfileIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        return InkResponse(
          onTap: () {
            context.push('/profile');
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 40,
              height: 40,
              child: snapshot.data?.photoURL == null
                  ? CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      child: const Icon(Icons.person))
                  : ClipOval(
                      child: Image.network(
                        snapshot.data!.photoURL!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
