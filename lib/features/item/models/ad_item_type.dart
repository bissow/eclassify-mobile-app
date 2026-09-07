enum AdItemType {
  regularAd,
  videoAd;

  String get value => this == AdItemType.regularAd ? 'normal' : 'reel';

  static AdItemType fromName(String name) {
    return switch (name) {
      'normal' => AdItemType.regularAd,
      'reel' => AdItemType.videoAd,
      _ => throw Exception('Invalid ad type: $name'),
    };
  }
}
