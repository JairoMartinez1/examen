import 'package:flutter/material.dart';
import 'package:wear/wear.dart';
import 'package:weather/weather.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.grey[900],
        accentColor: Colors.blue,
        fontFamily: 'Helvetica',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''), // English
        const Locale('es', ''), // Spanish
      ],
      home: const WatchScreen(),
    );
  }
}

class WatchScreen extends StatelessWidget {
  const WatchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        return AmbientMode(
          builder: (context, mode, child) {
            return DateTimeScreen(mode);
          },
        );
      },
    );
  }
}

class DateTimeScreen extends StatefulWidget {
  final WearMode mode;

  const DateTimeScreen(this.mode, {Key? key}) : super(key: key);

  @override
  _DateTimeScreenState createState() => _DateTimeScreenState();
}

class _DateTimeScreenState extends State<DateTimeScreen> {
  Stream<DateTime> _dateTimeStream = Stream<DateTime>.periodic(
    const Duration(seconds: 1),
    (count) => DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    Color textColor = widget.mode == WearMode.active ? Colors.red : Colors.white;

    return Scaffold(
      backgroundColor:
          widget.mode == WearMode.active ? Colors.white : Colors.grey[900],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              StreamBuilder<DateTime>(
                stream: _dateTimeStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    DateTime dateTime = snapshot.data!;
                    String formattedDateTime = _formatDateTimeWithSeconds(dateTime);
                    return Text(
                      formattedDateTime,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              const SizedBox(height: 16.0),
              FutureBuilder<Weather>(
                future: _getWeather(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Weather weather = snapshot.data!;
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WeatherScreen(weather: weather),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Text(
                            'Temperatura:',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            '${weather.temperature!.celsius?.toStringAsFixed(1)}°C',
                            style: TextStyle(
                              fontSize: 32.0,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),

                          Icon(
                            _getTemperatureIcon(weather.temperature!.celsius),
                            size: 48.0,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                      'Error al obtener los datos del clima',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Weather> _getWeather() async {
    WeatherFactory weatherFactory = WeatherFactory('6c9901e89779b15f112020014c45ef09', language: Language.SPANISH);
    Weather weather =
        await weatherFactory.currentWeatherByCityName('San Juan Del Río');
    return weather;
  }

  String _formatDateTimeWithSeconds(DateTime dateTime) {
    DateFormat timeFormat = DateFormat('h:mm:ss a');
    String formattedTime = timeFormat.format(dateTime);

    DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    String formattedDate = dateFormat.format(dateTime);

    return '$formattedTime\n$formattedDate';
  }

  IconData _getTemperatureIcon(double? temperature) {
    if (temperature != null) {
      if (temperature >= 25) {
        return Icons.wb_sunny;
      } else if (temperature >= 10) {
        return Icons.cloud;
      } else {
        return Icons.ac_unit;
      }
    }
    return Icons.help_outline;
  }
}

class WeatherScreen extends StatelessWidget {
  final Weather weather;

  const WeatherScreen({required this.weather, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clima'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Temperatura: ${weather.temperature!.celsius?.toStringAsFixed(1)}°C',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Condición: ${weather.weatherDescription!}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 16.0),
            Icon(
              _getWeatherIcon(weather.weatherDescription!),
              size: 48.0,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String weatherDescription) {
    switch (weatherDescription.toLowerCase()) {
      case 'sol':
        return Icons.wb_sunny;
      case 'nubes':
        return Icons.cloud;
      case 'lluvia':
        return Icons.beach_access;
      case 'cielo claro':
        return Icons.cloud_queue_sharp;
      case 'muy nuboso':
        return Icons.cloud;
      case 'algo de nubes':
        return Icons.cloud;
      case 'nubes dispersas':
        return Icons.cloud;
      default:
        return Icons.help_outline;
    }
  }
}
