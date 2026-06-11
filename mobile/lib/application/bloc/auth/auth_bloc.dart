// import 'package:rxdart/rxdart.dart';

// import '../../../domain/models/app_user.dart';

// class AuthBloc {
//   final BehaviorSubject<AppUser?> _user$ = BehaviorSubject<AppUser?>.seeded(
//     null,
//   );

//   ValueStream<AppUser?> get user$ => _user$.stream.shareValueSeeded(null);

//   AppUser? get currentUser => _user$.valueOrNull;

//   void setUser(AppUser user) {
//     _user$.add(user);
//   }

//   void clearSession() {
//     _user$.add(null);
//   }

//   void dispose() {
//     _user$.close();
//   }
// }
