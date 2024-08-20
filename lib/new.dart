class CarDetails {
  final int carSeats;

  CarDetails({required this.carSeats});

  factory CarDetails.fromJson(Map<String, dynamic> json) {
    return CarDetails(
      carSeats: json['carSeats'] ?? 0,
    );
  }
}
