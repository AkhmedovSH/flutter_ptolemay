import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ptolemay/helpers/animation.dart';
import 'package:flutter_ptolemay/store/counter/counter_bloc.dart';
import 'package:flutter_ptolemay/store/theme/theme_cubit.dart';

import 'pages/home/index.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (coontext) => ThemeCubit()),
        BlocProvider(create: (coontext) => CounterBloc()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // позиция начала анимации
    final circleOffset = Offset(20, size.height - 20);
    ThemeCubit theme = BlocProvider.of<ThemeCubit>(context, listen: true);

    return MaterialApp(
      locale: const Locale('ru_RU'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => DarkTransition(
              childBuilder: (context, x) => const Index(),
              offset: circleOffset,
              isDark: theme.isDark,
            ),
      },
    );
  }
}
