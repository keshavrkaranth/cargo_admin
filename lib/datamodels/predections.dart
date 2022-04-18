class Predictions{
  late String placeId;
  late String mainText;
  late String secondaryText;

  Predictions({
    required this.placeId,
    required this.mainText,
    required this.secondaryText
  });

  Predictions.fromJson(Map<String,dynamic> json){
    placeId = json['place_id'];
    mainText = json['structured_formatting']['main_text'];
    secondaryText = json['structured_formatting']['secondary_text'];
  }
}