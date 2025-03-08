abstract class ConversionEvent {}

class MultiplyEvent extends ConversionEvent {
  final double energy;
  final double mass;

  MultiplyEvent(this.energy, this.mass);
}

class M1Changed extends ConversionEvent {
  final double newEnergy;
  M1Changed(this.newEnergy);
}

class M2Changed extends ConversionEvent {
  final double newMass;
  M2Changed(this.newMass);
}