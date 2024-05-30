List<String> getTopClothingRecommendations(double temperature) {
  if (temperature >= 28) {
    return ['반팔', '반바지', '치마'];
  } else if (temperature >= 23) {
    return ['반팔', '셔츠', '반바지', '슬랙스'];
  } else if (temperature >= 20) {
    return ['셔츠', '후드', '면바지', '청바지'];
  } else if (temperature >= 17) {
    return ['후드티', '맨투맨', '면바지', '청바지'];
  } else if (temperature >= 12) {
    return ['재킷', '니트', '청바지', '스타킹'];
  } else if (temperature >= 9) {
    return ['트랜치코트', '자켓', '청바지', '스타킹'];
  } else if (temperature >= 5) {
    return ['코트', '니트', '청바지', '기모바지'];
  } else {
    return ['패딩', '롱패딩', '기모바지', '내복'];
  }
}

String getClothingImage(String clothing) {
  switch (clothing) {
    case '반팔':
      return 'assets/images/tshirt.png';
    case '셔츠':
      return 'assets/images/shirt.png';
    case '후드':
      return 'assets/images/hoodie.png';
    case '후드티':
      return 'assets/images/hoodie.png';
    case '맨투맨':
      return 'assets/images/sweatshirt.png';
    case '재킷':
      return 'assets/images/jacket.png';
    case '니트':
      return 'assets/images/knit.png';
    case '트랜치코트':
      return 'assets/images/trenchcoat.png';
    case '자켓':
      return 'assets/images/jacket.png';
    case '코트':
      return 'assets/images/coat.png';
    case '패딩':
      return 'assets/images/padding.png';
    case '롱패딩':
      return 'assets/images/longpadding.png';
    case '반바지':
      return 'assets/images/shorts.png';
    case '치마':
      return 'assets/images/skirt.png';
    case '슬랙스':
      return 'assets/images/slacks.png';
    case '면바지':
      return 'assets/images/cottonpants.png';
    case '청바지':
      return 'assets/images/jeans.png';
    case '스타킹':
      return 'assets/images/stockings.png';
    case '기모바지':
      return 'assets/images/fleecypants.png';
    case '내복':
      return 'assets/images/thermalunderwear.png';
    default:
      return 'assets/images/default.png';
  }
}

// http 해서 얻어서 return 수정하는거 해야함.
// 서버에서는 db에 저장되어있는것들 중 하나만 '랜덤'으로 base64로 보내는거 구현하면 됨.