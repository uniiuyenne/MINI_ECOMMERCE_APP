# MINI E-COMMERCE APP - SKELETON

Repo này chỉ chứa **khung xương dự án** để các thành viên trong nhóm cùng phát triển.

## Mục tiêu
- Giữ nguyên kiến trúc thư mục của project chính
- Không đưa business logic hiện tại lên GitHub
- Cung cấp placeholder/stub để team phát triển theo branch riêng

## Cấu trúc chính

```text
lib/
  models/
  providers/
  screens/
    account/
    cart/
    checkout/
    home/
    orders/
    product_detail/
  services/
  utils/
  widgets/
  app.dart
  firebase_options.dart
  main.dart
assets/
  fake_products.json
  extra_products.json
```

## Chạy project

```bash
flutter pub get
flutter run
```

## Quy tắc làm việc nhóm
- Không commit trực tiếp vào `main`
- Mỗi thành viên làm việc trên branch riêng
- Tạo pull request để review trước khi merge

## Gợi ý chia nhánh
- `feature/home-screen`
- `feature/product-detail`
- `feature/cart-provider`
- `feature/checkout-orders`

## Ghi chú
- Đây là skeleton repo, không chứa logic nghiệp vụ gốc.
- Firebase đang ở trạng thái placeholder an toàn.
- Dữ liệu assets hiện là placeholder rỗng.
