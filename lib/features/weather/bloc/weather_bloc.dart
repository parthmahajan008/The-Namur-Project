import 'package:active_ecommerce_flutter/features/weather/bloc/weather_event.dart';
import 'package:active_ecommerce_flutter/features/weather/bloc/weather_state.dart';
import 'package:active_ecommerce_flutter/features/weather/weather_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherBloc() : super(WeatherScreenDataNotReceived()) {
    // on<WeatherSectionInfoRequested>((event, emit) async {
    //   emit(Loading());
    //   final currentData = await WeatherRepository().fetchCurrent();
    //   // await Future.delayed(Duration(seconds: 3));
    //   emit(WeatherSectionInfoReceived(responseData: currentData));
    //   // });
    // });

    on<WeatherSreenDataRequested>((event, emit) async {
      emit(Loading());
      final responseData = await WeatherRepository().fetchForecast();
      // await Future.delayed(Duration(seconds: 3));
      emit(WeatherSreenDataReceived(responseData: responseData));
      // });
    });
  }
}