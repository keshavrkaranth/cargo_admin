class Address{
  String placeName;
  double latitude;
  double longitude;
  String placeId;
  String placeFormatAddress;

  Address({
    required this.placeName,
    required this.placeFormatAddress,
    required this.placeId,
    required this.latitude,
    required this.longitude
  });
}