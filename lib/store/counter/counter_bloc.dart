import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

part 'counter_event.dart';
part 'counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterState(counter: 0)) {
    on<CounterEvent>((event, emit) {});
    on<IncrementEvent>((event, emit) {
      emit(CounterState(counter: event.counter));
    });
    on<DecrementEvent>((event, emit) {
      emit(CounterState(counter: event.counter));
    });
  }
}
