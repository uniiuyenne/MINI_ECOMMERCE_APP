class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final double rating;
  final int ratingCount;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
    required this.ratingCount,
  });

    static const Map<String, String> _categoryTranslations = {
    "electronics": 'Điện tử',
    "jewelery": 'Trang sức',
    "men's clothing": 'Thời trang nam',
    "women's clothing": 'Thời trang nữ',
    };

    static const Map<String, String> _titleTranslations = {
    'Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops':
      'Balo Fjallraven Foldsack số 1, vừa laptop 15 inch',
    'Mens Casual Premium Slim Fit T-Shirts ': 'Áo thun nam slim fit cao cấp',
    'Mens Cotton Jacket': 'Áo khoác cotton nam',
    'Mens Casual Slim Fit': 'Áo nam casual slim fit',
    'John Hardy Women\'s Legends Naga Gold & Silver Dragon Station Chain Bracelet':
      'Vòng tay rồng vàng bạc nữ John Hardy',
    'Solid Gold Petite Micropave ': 'Nhẫn vàng nguyên khối đính đá nhỏ',
    'White Gold Plated Princess': 'Nhẫn công chúa mạ vàng trắng',
    'Pierced Owl Rose Gold Plated Stainless Steel Double':
      'Khuyên cú mèo thép không gỉ mạ vàng hồng',
    'WD 2TB Elements Portable External Hard Drive - USB 3.0 ': 
      'Ổ cứng di động WD Elements 2TB USB 3.0',
    'SanDisk SSD PLUS 1TB Internal SSD - SATA III 6 Gb/s':
      'Ổ cứng SSD trong SanDisk Plus 1TB SATA III',
    'Silicon Power 256GB SSD 3D NAND A55 SLC Cache Performance Boost SATA III 2.5':
      'SSD Silicon Power 256GB A55 3D NAND',
    'WD 4TB Gaming Drive Works with Playstation 4 Portable External Hard Drive':
      'Ổ cứng gaming WD 4TB cho Playstation 4',
    'Acer SB220Q bi 21.5 inches Full HD (1920 x 1080) IPS Ultra-Thin':
      'Màn hình Acer SB220Q 21.5 inch Full HD IPS',
    'Samsung 49-Inch CHG90 144Hz Curved Gaming Monitor (LC49HG90DMNXZA) – Super Ultrawide Screen QLED ': 
      'Màn hình cong gaming Samsung 49 inch CHG90 144Hz',
    'BIYLACLESEN Women\'s 3-in-1 Snowboard Jacket Winter Coats':
      'Áo khoác trượt tuyết nữ 3 trong 1 BIYLACLESEN',
    'Lock and Love Women\'s Removable Hooded Faux Leather Moto Biker Jacket':
      'Áo khoác da biker nữ có mũ tháo rời',
    'Rain Jacket Women Windbreaker Striped Climbing Raincoats':
      'Áo mưa gió nữ sọc leo núi',
    'MBJ Women\'s Solid Short Sleeve Boat Neck V ': 
      'Áo nữ tay ngắn cổ thuyền MBJ',
    'Opna Women\'s Short Sleeve Moisture': 'Áo thể thao nữ tay ngắn Opna',
    'DANVOUY Womens T Shirt Casual Cotton Short':
      'Áo thun nữ casual cotton DANVOUY',
    };

    static const Map<String, String> _descriptionTranslations = {
    'Your perfect pack for everyday use and walks in the forest. Stash your laptop (up to 15 inches) in the padded sleeve, your everyday':
      'Chiếc balo lý tưởng cho việc sử dụng hằng ngày và những buổi đi dạo. Có ngăn chống sốc vừa laptop đến 15 inch cùng không gian chứa đồ tiện lợi.',
    'Slim-fitting style, contrast raglan long sleeve, three-button henley placket, light weight & soft fabric for breathable and comfortable wearing.':
      'Áo thun dáng ôm, tay dài phối màu, cài ba nút kiểu henley. Chất vải nhẹ, mềm, thoáng khí và mặc rất thoải mái.',
    'great outerwear jackets for Spring/Autumn/Winter, suitable for many occasions, such as working, hiking, camping, mountain/rock climbing, cycling, traveling or other outdoors.':
      'Áo khoác ngoài phù hợp cho xuân, thu, đông. Thích hợp đi làm, leo núi, cắm trại, đạp xe, du lịch và nhiều hoạt động ngoài trời khác.',
    'The color could be slightly different between on the screen and in practice. / Please note that body builds vary by person, therefore, detailed size information should be reviewed below on the product description.':
      'Màu sắc thực tế có thể chênh lệch nhẹ so với trên màn hình. Vui lòng xem kỹ thông tin kích thước chi tiết trong phần mô tả trước khi mua.',
    'From our Legends Collection, the Naga was inspired by the mythical water dragon that protects the ocean\'s pearl. Wear facing inward to be bestowed with love and abundance, or outward for protection.':
      'Thiết kế thuộc bộ sưu tập Legends, lấy cảm hứng từ rồng nước thần thoại bảo vệ ngọc trai đại dương. Có thể đeo hướng vào trong để tượng trưng cho tình yêu và sự sung túc, hoặc hướng ra ngoài để cầu bình an.',
    'Satisfaction Guaranteed. Return or exchange any order within 30 days.Designed and sold by Hafeez Center in the United States.':
      'Cam kết hài lòng. Có thể đổi hoặc trả hàng trong vòng 30 ngày. Thiết kế và phân phối bởi Hafeez Center tại Hoa Kỳ.',
    'Classic Created Wedding Engagement Solitaire Diamond Promise Ring for Her. Gifts to spoil your love more for Engagement, Wedding, Anniversary, Valentine\'s Day...':
      'Mẫu nhẫn solitaire cổ điển dành cho đính hôn, cưới hỏi hoặc kỷ niệm. Phù hợp làm quà tặng trong nhiều dịp đặc biệt như Valentine và ngày cưới.',
    'Rose Gold Plated Double Flared Tunnel Plug Earrings. Made of 316L Stainless Steel':
      'Khuyên tai tunnel hai đầu loe mạ vàng hồng. Chất liệu thép không gỉ 316L bền đẹp.',
    'USB 3.0 and USB 2.0 Compatibility Fast data transfers Improve PC Performance High Capacity; Compatibility Formatted NTFS for Windows 10, Windows 8.1, Windows 7':
      'Tương thích USB 3.0 và USB 2.0, truyền dữ liệu nhanh, dung lượng lớn, giúp cải thiện hiệu năng lưu trữ cho máy tính Windows.',
    'Easy upgrade for faster boot-up, shutdown, application load and response':
      'Giải pháp nâng cấp dễ dàng giúp khởi động, tắt máy và mở ứng dụng nhanh hơn rõ rệt.',
    '3D NAND flash are applied to deliver high transfer speeds. Remarkable transfer speeds that enable faster bootup and improved overall system performance.':
      'Sử dụng bộ nhớ 3D NAND cho tốc độ truyền tải cao, giúp khởi động nhanh hơn và cải thiện hiệu năng tổng thể của hệ thống.',
    'Expand your PS4 gaming experience, Play anywhere Fast and easy, setup Sleek design with high capacity, 3-year manufacturer\'s limited warranty':
      'Mở rộng không gian lưu trữ cho PS4, cài đặt nhanh chóng, thiết kế gọn đẹp và dung lượng lớn, phù hợp mang theo mọi nơi.',
    '21. 5 inches Full HD (1920 x 1080) widescreen IPS display And Radeon free Sync technology.':
      'Màn hình IPS rộng 21.5 inch Full HD, hiển thị sắc nét và hỗ trợ công nghệ đồng bộ hình ảnh mượt mà.',
    '49 INCH SUPER ULTRAWIDE 32:9 CURVED GAMING MONITOR with dual 27 inch screen side by side':
      'Màn hình cong siêu rộng 49 inch tỷ lệ 32:9, tương đương hai màn hình 27 inch đặt cạnh nhau, tối ưu cho chơi game và đa nhiệm.',
    'Note:The Jackets is US standard size, Please choose size as your usual wear Material: 100% Polyester; Detachable Liner Fabric: Warm Fleece.':
      'Áo khoác theo chuẩn size Mỹ, chất liệu polyester 100% kèm lớp lót nỉ ấm có thể tháo rời, phù hợp thời tiết lạnh.',
    '100% POLYURETHANE(shell) 100% POLYESTER(lining) 75% POLYESTER 25% COTTON':
      'Vỏ ngoài polyurethane, lớp lót polyester pha cotton, mang lại cảm giác chắc chắn và thoải mái khi mặc.',
    'Lightweight perfet for trip or casual wear---Long sleeve with hooded, adjustable drawstring waist design.':
      'Áo khoác nhẹ, phù hợp đi chơi hoặc mặc thường ngày, tay dài có mũ và dây rút eo điều chỉnh linh hoạt.',
    '95%Cotton,5%Spandex, Features: Casual, Short Sleeve, Letter Print, V-Neck, Fashion Tees':
      'Áo nữ chất liệu cotton pha spandex, cổ V, tay ngắn, phong cách trẻ trung và thoải mái.',
    '100% Polyester, Machine wash, 100% cationic polyester interlock, Moisture-wicking, Lightweight':
      'Chất liệu polyester thoáng nhẹ, thấm hút mồ hôi tốt, phù hợp cho vận động và tập luyện.',
    };

    String get displayCategory =>
      _categoryTranslations[category.toLowerCase()] ?? category;

    String get displayTitle => _titleTranslations[title.trim()] ?? title;

      String get displayDescription =>
        _descriptionTranslations[description.trim()] ?? description;

  factory Product.fromJson(Map<String, dynamic> json) {
    final ratingJson = json['rating'] as Map<String, dynamic>?;

    return Product(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      image: json['image'] as String? ?? '',
      rating: (ratingJson?['rate'] as num?)?.toDouble() ?? 0,
      ratingCount: (ratingJson?['count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
      'rating': {
        'rate': rating,
        'count': ratingCount,
      },
    };
  }
}
