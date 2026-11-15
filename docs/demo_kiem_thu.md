# Kịch bản demo và kiểm thử — Nguyễn Đức Hải

Phần code màn hình Chi tiết và Chỉnh sửa cần được tích hợp từ Phạm Thị Hồng Nhung trước khi thực hiện các bước dưới đây.

## Demo 1: truyền dữ liệu và lưu kết quả — khoảng 2 phút

| Bước | Thao tác | Điểm giải thích / kết quả |
| --- | --- | --- |
| 1 | Chạy app, chọn ghi chú “Ôn tập Flutter” | Danh sách gọi `pushNamed`, gửi `arguments: note`; chi tiết hiển thị đúng ghi chú. |
| 2 | Nhấn Chỉnh sửa | Route trực tiếp nhận dữ liệu qua constructor. |
| 3 | Đổi tiêu đề, nội dung rồi nhấn Lưu | Màn hình sửa `pop(updatedNote)`; chi tiết nhận kết quả qua `await` và cập nhật. |
| 4 | Back về danh sách | Danh sách nhận `Note` đã lưu, thay đúng phần tử theo id bằng `setState`. |
| 5 | Mở lại ghi chú | Dữ liệu mới vẫn còn trong phiên chạy. |

File chính để giải thích phần của Hải: `lib/screens/note_list_screen.dart`, `lib/app_routes.dart`, `lib/models/note.dart` và `lib/data/sample_notes.dart`.

## Demo 2: phối hợp trình diễn Back và bản nháp — khoảng 1,5 phút

1. Mở form, chưa thay đổi rồi Back: quay lại ngay.
2. Thay tiêu đề rồi Back: xuất hiện hộp thoại xác nhận.
3. Chọn Tiếp tục sửa: bản nháp được giữ.
4. Back lần nữa, chọn Bỏ thay đổi: bản nháp bị bỏ, chi tiết vẫn giữ phiên bản đã lưu gần nhất.
5. Trên Android, kiểm tra thêm Back hệ thống. Trên web, dùng Back của AppBar; đóng tab hoặc tải lại trang là thao tác khác.

Nhung giải thích phần bảo vệ bản nháp bằng `PopScope`; Hải phụ trách chuẩn bị dữ liệu và kiểm thử kịch bản.

## Kiểm thử tự động

Chạy tại thư mục dự án đã tích hợp đủ mã:

```sh
flutter pub get
flutter analyze
flutter test test/navigation_test.dart
```

Bộ kiểm thử gồm 8 tình huống:

1. Named route nhận đúng ghi chú, Back không sửa giữ nguyên danh sách.
2. Lưu cập nhật chi tiết, danh sách và lần mở tiếp theo.
3. Back hệ thống trả bản đã lưu về danh sách.
4. Back trên AppBar cho phép tiếp tục sửa hoặc bỏ bản nháp.
5. Bỏ bản nháp sau một lần lưu vẫn giữ phiên bản đã lưu trước đó.
6. Form chưa sửa quay lại không cần xác nhận.
7. Tiêu đề / nội dung rỗng bị từ chối.
8. Màn hình nhỏ và cỡ chữ lớn vẫn cuộn tới nút Lưu.

Bộ kiểm thử tích hợp được chạy trên bản mã nhóm đầy đủ, gồm cả màn hình Danh sách, Chi tiết và Chỉnh sửa. Khi tích hợp các phần việc vào repo chung, chạy lại các lệnh trên để kiểm tra luồng hoàn chỉnh.
