import 'package:flutter/material.dart';
import 'package:frontend/screens/explore_screen.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/utils/encrypted_storage.dart';

void main() async {
	WidgetsFlutterBinding.ensureInitialized();
	String initialRoute = "/home";
	var (jwt, e) =await EncryptedStorage().get(key: "jwt");
	if (jwt == null){
		initialRoute = "/login";
	}

  runApp(DiscourseDen(initialRoute,));
}

class DiscourseDen extends StatelessWidget {
  const DiscourseDen(this.initialRoute, {super.key});
  	final String initialRoute;


  @override
  Widget build(BuildContext context){
	return MaterialApp(
	routes: {
		"/home": (context) => const HomeScreen(),
		"/login": (context) => const LoginScreen(),
		"/explore": (context) => const ExploreScreen(),
	},
	initialRoute: initialRoute,
	theme: ThemeData(primaryColor: Colors.black, brightness: Brightness.dark, fontFamily: "RobotoMono"),
	);
  }
}
