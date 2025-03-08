import 'package:flutter_bloc/flutter_bloc.dart';

import 'ConversionEvent.dart';
import 'ConversionState.dart';

class ConversionBloc extends Bloc<ConversionEvent, ConversionState> {
  double speedOfLight = 299792458;

  ConversionBloc() : super(ConversionState(0, 0)) {
    on<M1Changed>((event, emit) {
      emit(ConversionState(event.newEnergy, event.newEnergy / speedOfLight));
    });

    on<M2Changed>((event, emit) {
      emit(ConversionState(event.newMass * speedOfLight, event.newMass));
    });
  }
}
