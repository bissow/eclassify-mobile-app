enum AdItemType {
  regularAd,
  videoAd;

  String get value => this == AdItemType.regularAd ? 'normal' : 'reel';

  static AdItemType fromName(String? name) {
    return switch (name) {
      'reel' => AdItemType.videoAd,
      _ => AdItemType.regularAd,
    };
  }
}
