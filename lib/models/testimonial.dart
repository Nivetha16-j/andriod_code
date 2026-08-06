class Testimonial {
  final int id;
  final String name;
  final String email;
  final int rating;
  final String description;
  final String createdAt;

  Testimonial({
    required this.id,
    required this.name,
    required this.email,
    required this.rating,
    required this.description,
    required this.createdAt,
  });

  factory Testimonial.fromJson(Map<String, dynamic> json) {
    return Testimonial(
      id: json["id"],
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      rating: json["rating"] ?? 0,
      description: json["description"] ?? "",
      createdAt: json["created_at"] ?? "",
    );
  }
}
