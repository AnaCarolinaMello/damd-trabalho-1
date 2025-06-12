class Address {
  final String? id;
  final String street;
  final String number;
  final String complement;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;

  const Address({
    this.id,
    required this.street,
    required this.number,
    this.complement = '',
    required this.neighborhood, 
    required this.city,
    required this.state,
    required this.zipCode,
  });

  String get fullAddress => '$street, $number${complement.isNotEmpty ? ', $complement' : ''}, $neighborhood, $city - $state, $zipCode';

  String get shortAddress => '$street, $number${complement.isNotEmpty ? ', $complement' : ''}';

  String get cityState => '$city - $state, $zipCode';

  static Address fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      street: json['street'] ?? '',
      number: json['number'] ?? '',
      complement: json['complement'] ?? '',
      neighborhood: json['neighborhood'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? json['zip_code'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'street': street,
      'number': number,
      'complement': complement,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'zip_code': zipCode,
    };
  }
}
