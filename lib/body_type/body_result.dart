class BodyTypeData {
  final String bodyType;
  final String description;
  final List<String> recommendedItems;
  final List<String> recommendedImages;
  final List<String> avoidItems;
  final List<String> avoidImages;

  BodyTypeData({
    required this.bodyType,
    required this.description,
    required this.recommendedItems,
    required this.recommendedImages,
    required this.avoidItems,
    required this.avoidImages,
  });
}

BodyTypeData? getBodyTypeData(String bodyType) {
  switch (bodyType) {
    case '모래시계형':
      return BodyTypeData(
        bodyType: '모래시계형',
        description: '골반과 가슴둘레가 거의 같고, 허리는 가느다란 균형 잡힌 체형입니다. 모래시계형은 어떤 코디에도 어색하지 않습니다.',
        recommendedItems: [
          '- 네크라인이 깊고 허리선이 강조되는 원피스',
          '- 슬림한 H라인 펜슬 스커트',
        ],
        recommendedImages: [
          'assets/body_type/hourglass/hourglass_1.jpg',
          'assets/body_type/hourglass/hourglass_2.jpg',
          'assets/body_type/hourglass/hourglass_3.jpg',
          'assets/body_type/hourglass/hourglass_4.jpg',
          'assets/body_type/hourglass/hourglass_5.jpg',
        ],
        avoidItems: [
          '- 펑퍼짐한 오버사이즈 의류',
        ],
        avoidImages: [
          'assets/body_type/hourglass/hourglass_6.jpg',
          'assets/body_type/hourglass/hourglass_7.jpg',
        ],
      );
    case '타원형':
      return BodyTypeData(
        bodyType: '타원형',
        description: '상체와 하체가 둥글게 이어지는 체형입니다. 몸의 중심인 복부가 어깨와 골반보다 크게 발달하여 중심부가 돋보이는 경향이 있습니다.',
        recommendedItems: [
          '- 가슴 밑부터 퍼지는 플레어 상의',
          '- 세로 스트라이프 상의',
        ],
        recommendedImages: [
          'assets/body_type/round/round_1.jpg',
          'assets/body_type/round/round_2.jpg',
          'assets/body_type/round/round_3.jpg',
          'assets/body_type/round/round_4.jpg',
          'assets/body_type/round/round_5.jpg',
        ],
        avoidItems: [
          '- 복부에 주름이 잡히거나 딱 달라붙는 상의',
        ],
        avoidImages: [
          'assets/body_type/round/round_6.jpg',
          'assets/body_type/round/round_7.jpg',
        ],
      );
    case '삼각형':
      return BodyTypeData(
        bodyType: '삼각형',
        description: '어깨와 가슴이 골반/엉덩이보다 좁아, 하체가 발달한 체형입니다. 상대적으로 상체가 빈약해서 팔이 가늘고 허리가 얇은 분들이 많습니다.',
        recommendedItems: [
          '- 각진 어깨의 반팔 재킷 (블레이저)',
          '- 블랙 계열 부츠컷 or 스트레이트 팬츠',
        ],
        recommendedImages: [
          'assets/body_type/triangle/triangle_1.jpg',
          'assets/body_type/triangle/triangle_2.jpg',
          'assets/body_type/triangle/triangle_3.jpg',
          'assets/body_type/triangle/triangle_4.jpg',
          'assets/body_type/triangle/triangle_5.jpg',
        ],
        avoidItems: [
          '- 너무 헐렁한 하의 (와이드팬츠/ 배기팬츠)',
        ],
        avoidImages: [
          'assets/body_type/triangle/triangle_6.jpg',
          'assets/body_type/triangle/triangle_7.jpg',
        ],
      );
    case '일자형':
      return BodyTypeData(
        bodyType: '일자형',
        description: '가슴둘레와 골반이 좁아, 전체적으로 일(1)자 처럼 보이는 체형입니다. 대개 볼륨감이 부족해서 밋밋해 보이거나 깡마른 이미지가 많습니다.',
        recommendedItems: [
          '- 허리를 감싸주는 원피스',
          '- 튜브탑 or 오프숄더',
        ],
        recommendedImages: [
          'assets/body_type/straight/straight_1.png',
          'assets/body_type/straight/straight_2.jpg',
          'assets/body_type/straight/straight_3.jpg',
          'assets/body_type/straight/straight_4.jpg',
          'assets/body_type/straight/straight_5.jpg',
        ],
        avoidItems: [
          '- H라인 펜슬 스커트',
        ],
        avoidImages: [
          'assets/body_type/straight/straight_6.jpg',
          'assets/body_type/straight/straight_7.jpg',
        ],
      );
    default:
      return null;
  }
}
