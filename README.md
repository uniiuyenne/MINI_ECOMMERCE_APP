# MINI E-COMMERCE APP (TH4)

Ứng dụng demo luồng mua sắm cơ bản với 4 màn hình:
- Home
- Product Detail
- Cart
- Checkout + Orders

## 1) Chạy dự án

```bash
flutter pub get
flutter run
```

## 2) Yêu cầu đã triển khai

- AppBar trang chủ đúng format: `TH4 - Nhóm [Số nhóm]`
- Home: SliverAppBar sticky + Search, badge giỏ hàng, banner auto slide + dots, category grid, grid sản phẩm, pull-to-refresh, infinite scroll
- Detail: Hero animation, gallery, giá bán/giá gốc, variation sheet (size/màu/số lượng), thêm vào giỏ + snackbar
- Cart (Provider): checkbox item, chọn tất cả, tổng tiền theo item được tick, tăng/giảm realtime, dismissible xóa
- Checkout/Orders: nhập địa chỉ, chọn thanh toán, đặt hàng, xóa item đã mua khỏi giỏ, tab đơn mua
- Persistence: lưu giỏ hàng local bằng `SharedPreferences`

## 3) Kiến trúc thư mục

```text
lib/
	models/
	providers/
	screens/
		home/
		product_detail/
		cart/
		checkout/
		orders/
	services/
	widgets/
	utils/
	app.dart
	main.dart
```

## 4) Phân chia nhóm 4 người (đề xuất)

### Thành viên 1 - Home Screen
- Nhánh: `feature/home-screen`
- File chính:
	- `lib/screens/home/home_screen.dart`
	- `lib/widgets/banner_slider.dart`
	- `lib/widgets/category_grid.dart`
	- `lib/widgets/product_card.dart`

### Thành viên 2 - Product Detail
- Nhánh: `feature/product-detail`
- File chính:
	- `lib/screens/product_detail/product_detail_screen.dart`
	- `lib/widgets/quantity_selector.dart`

### Thành viên 3 - Cart + State Management
- Nhánh: `feature/cart-provider`
- File chính:
	- `lib/screens/cart/cart_screen.dart`
	- `lib/providers/cart_provider.dart`
	- `lib/models/cart_item.dart`
	- `lib/widgets/cart_badge_icon.dart`

### Thành viên 4 - Checkout + Orders + Integration
- Nhánh: `feature/checkout-orders`
- File chính:
	- `lib/screens/checkout/checkout_screen.dart`
	- `lib/screens/orders/orders_screen.dart`
	- `lib/providers/order_provider.dart`
	- `lib/app.dart`

## 5) Quy tắc Git nhóm

- Không commit trực tiếp vào `main`
- Mỗi người tạo nhánh riêng theo màn hình
- Mỗi tính năng tạo Pull Request để review chéo
- Commit message gợi ý:
	- `feat(home): add sticky sliver search`
	- `feat(cart): sync select-all with item checkbox`
	- `fix(checkout): remove selected cart items after order`

## 6) Tích hợp Firebase Google Sign-In

### Cài đặt dependency

```bash
flutter pub get
```

### Kết nối dự án Firebase (bắt buộc trước khi đăng nhập Google)

1. Tạo project trên Firebase Console.
2. Bật **Authentication > Sign-in method > Google**.
3. Cài FlutterFire CLI (nếu chưa có):

```bash
dart pub global activate flutterfire_cli
```

4. Chạy cấu hình Firebase trong project:

```bash
flutterfire configure
```

Lệnh này sẽ tạo `lib/firebase_options.dart` và tự cấu hình các file nền tảng.

> Trong source hiện tại đã có sẵn file `lib/firebase_options.dart` dạng template để app không crash.
> Sau khi chạy `flutterfire configure`, hãy **ghi đè** file đó bằng file do FlutterFire sinh ra.

### Lưu ý theo nền tảng

- Android: tải `google-services.json` đúng package name.
- iOS: tải `GoogleService-Info.plist` đúng bundle id.
- Web: FlutterFire CLI sẽ tự thêm cấu hình web.

### Sử dụng trong app

- Nút đăng nhập Google nằm trên AppBar trang Home.
- Khi đăng nhập thành công, icon tài khoản chuyển thành avatar chữ cái đầu.
- Menu avatar hỗ trợ đăng xuất.
- Nếu Firebase chưa cấu hình xong, app sẽ hiện thông báo lỗi rõ ràng thay vì crash.

## 7) Firestore Rules đơn giản nhất

Project đã được thêm sẵn file [firestore.rules](firestore.rules) và [firebase.json](firebase.json).

Rule đang dùng:
- chỉ user đã đăng nhập mới được đọc/ghi dữ liệu của chính mình trong nhánh `users/{uid}/...`
- phù hợp luôn với lịch sử mua hàng đang lưu ở `users/{uid}/orders/{orderId}`

Nội dung rule:

```javascript
rules_version = '2';
service cloud.firestore {
	match /databases/{database}/documents {
		match /users/{uid}/{document=**} {
			allow read, write: if request.auth != null && request.auth.uid == uid;
		}
	}
}
```

Áp dụng nhanh trên Firebase Console:
1. Mở **Firestore Database**.
2. Chọn tab **Rules**.
3. Dán nội dung trong [firestore.rules](firestore.rules).
4. Bấm **Publish**.

Nếu dùng Firebase CLI thì có thể deploy rules từ thư mục project sau khi đăng nhập Firebase.
