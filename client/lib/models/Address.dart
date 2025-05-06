class Address {
  final String street;
  final String number;
  final String complement;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;

  const Address({
    required this.street,
    required this.number,
    required this.complement,
    required this.neighborhood, 
    required this.city,
    required this.state,
    required this.zipCode,
  });

  String get fullAddress => '$street, $number${complement.isNotEmpty ? ', $complement' : ''}, $neighborhood, $city - $state, $zipCode';

  String get shortAddress => '$street, $number${complement.isNotEmpty ? ', $complement' : ''}';

  String get cityState => '$city - $state, $zipCode';
}
