part of 'counter_bloc.dart';

@immutable
abstract class CounterEvent extends Equatable {
  const CounterEvent();

  @override
  List<Object> get props => [];
}

@immutable
class IncrementEvent extends CounterEvent {
  final int counter;
  const IncrementEvent(this.counter);

  @override
  List<Object> get props => [counter];
}

class DecrementEvent extends CounterEvent {
  final int counter;
  const DecrementEvent(this.counter);

  @override
  List<Object> get props => [counter];
}
