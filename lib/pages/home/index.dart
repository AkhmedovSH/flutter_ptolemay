import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ptolemay/store/theme/theme_cubit.dart';
import 'package:flutter_ptolemay/store/counter/counter_bloc.dart';

class Index extends StatefulWidget {
  const Index({super.key});

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  bool loading = false;
  Map weather = {
    'current': {},
  };

  getLocation() async {
    setState(() {
      loading = true;
    });
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.deniedForever && permission != LocationPermission.denied) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      BaseOptions options = BaseOptions(
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      );
      var dio = Dio(options);
      try {
        final response = await dio.get(
          'https://api.openweathermap.org/data/2.5/onecall',
          queryParameters: {
            'lat': position.latitude.toString(),
            'lon': position.longitude.toString(),
            'exclude': 'daily',
            'appid': '38a82cf8e8b658afc7939ed657756f6c',
            'lang': 'ru',
            'units': 'metric'
          },
        );
        weather = response.data;
      } catch (e) {
        print(e);
      }
    }
    loading = false;
    setState(() {});
  }

  counterIncrement(state, theme, counterBloc) {
    int value = state.counter;
    if (theme.isDark) {
      value = value + (value == 9 ? 1 : 2);
    } else {
      value = value + 1;
    }
    if (value < 11) {
      counterBloc.add(IncrementEvent(value));
    }
  }

  counterDecrement(state, theme, counterBloc) {
    int value = state.counter;
    if (theme.isDark) {
      value = value - (value == 1 ? 1 : 2);
    } else {
      value = value - 1;
    }
    if (value > -1) {
      counterBloc.add(DecrementEvent(value));
    }
  }

  changeTheme(theme) {
    theme.changeTheme();
    Timer(const Duration(milliseconds: 500), () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final CounterBloc counterBloc = BlocProvider.of<CounterBloc>(context);
    ThemeCubit theme = BlocProvider.of<ThemeCubit>(context, listen: false);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Weather & Counter'),
            centerTitle: true,
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              weather['timezone'] != null
                  ? Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'Погода в ${weather['timezone']}',
                        style: const TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
                      child: const Text(
                        'Нажмите на правую нижнию иконку чтобы узнать погоду',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
              if (weather['timezone'] != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    '${weather['current']['temp']} °C',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
              BlocBuilder<CounterBloc, CounterState>(
                //cubit: counterBloc,
                builder: (context, state) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          state.counter.toString(),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          floatingActionButton: Container(
            margin: const EdgeInsets.only(left: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        FloatingActionButton(
                          onPressed: () {
                            getLocation();
                          },
                          tooltip: 'Узнать погоду',
                          child: const Icon(Icons.cloud),
                        ),
                        const SizedBox(height: 15),
                        FloatingActionButton(
                          onPressed: () {
                            changeTheme(theme);
                          },
                          tooltip: 'Поменять тему',
                          child: BlocBuilder<ThemeCubit, ThemeState>(
                            builder: (context, state) {
                              if (state is ThemeChanged) {
                                return Icon(state.isDark ? Icons.dark_mode : Icons.light_mode);
                              }
                              return const Icon(Icons.light_mode);
                            },
                          ),
                        ),
                      ],
                    ),
                    BlocBuilder<CounterBloc, CounterState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: state.counter == 10 ? 0 : 1,
                              child: FloatingActionButton(
                                onPressed: () {
                                  counterIncrement(state, theme, counterBloc);
                                },
                                tooltip: 'Изменить тему',
                                child: const Icon(Icons.add),
                              ),
                            ),
                            const SizedBox(height: 15),
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: state.counter == 0 ? 0 : 1,
                              child: FloatingActionButton(
                                onPressed: () {
                                  counterDecrement(state, theme, counterBloc);
                                },
                                tooltip: 'Минусовать',
                                child: const Icon(Icons.remove),
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        loading
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black.withOpacity(0.4),
                alignment: Alignment.center,
                child: const SizedBox(
                  height: 64,
                  width: 64,
                  child: CircularProgressIndicator(
                    color: Color(0xFF114dc8),
                  ),
                ),
              )
            : Container()
      ],
    );
  }
}
