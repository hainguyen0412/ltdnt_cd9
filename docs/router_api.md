# Named routes và tổng quan Router API

Nội dung lý thuyết do Nguyễn Đức Hải phụ trách, tương ứng slide 9–15 của bài thuyết trình 25 slide. File PowerPoint được giữ ngoài repo.

## Named routes trong demo

Luồng bắt đầu ở `NoteListScreen`. Khi chọn ghi chú:

```dart
final updatedNote = await Navigator.pushNamed<Note>(
  context,
  AppRoutes.detail,
  arguments: note,
);
```

- `AppRoutes.detail` là hằng chuỗi `/detail`.
- `arguments` truyền object `Note` vào route.
- `AppRoutes.onGenerateRoute` đọc `settings.name` và `settings.arguments`, sau đó tạo `MaterialPageRoute<Note>`.
- `settings: settings` giữ tên và tham số của route.
- `<Note>` là kiểu kết quả khi route đóng. Nếu không có kết quả, `await` nhận `null`.
- Sau `await`, danh sách kiểm tra `mounted` và `null` trước khi cập nhật bằng `setState`.

`arguments` có kiểu `Object?`. Demo quy ước mọi lần mở `/detail` đều gửi một `Note`; phép ép `as Note` không phải cơ chế kiểm tra đầu vào đầy đủ. `onUnknownRoute` xử lý khi không tạo được route theo tên, không tự bắt lỗi ép kiểu arguments, và không áp dụng cho lỗi của `initialRoute`.

Named routes vẫn dùng Navigator. Trên web, cơ chế này không hỗ trợ nút Forward của trình duyệt và có hạn chế về cách xử lý deep link. Khi nhận deep link mới, cơ chế named routes đẩy một route mới; đây không phải mô tả cho mọi API điều hướng theo tên.

## Ý tưởng của Router API

Với Navigator mệnh lệnh, code gọi `push` và `pop` để thay đổi ngăn xếp. Với cách khai báo, trạng thái hiện tại quyết định danh sách `Page`:

| Trạng thái | Danh sách page minh họa |
| --- | --- |
| Chưa chọn ghi chú | `[Danh sách]` |
| Chọn ghi chú có id = 1 | `[Danh sách, Chi tiết 1]` |
| Đang sửa ghi chú 1 | `[Danh sách, Chi tiết 1, Chỉnh sửa 1]` |

Route tạo từ `Page` là **page-backed**. Route được đẩy bằng `push`, chẳng hạn hộp thoại qua `showDialog`, là **pageless**. Chỉ tạo `Page` chưa đủ để ứng dụng hỗ trợ deep link; vẫn cần cấu hình định tuyến và xử lý URL tương ứng.

## Các thành phần chính

| Thành phần | Trách nhiệm |
| --- | --- |
| `RouteInformationProvider` | Cung cấp thông tin route, chẳng hạn URL hiện tại. |
| `RouteInformationParser<T>` | Chuyển thông tin route thành cấu hình `T`; có thể chuyển cấu hình ngược lại thành thông tin route. |
| `RouterDelegate<T>` | Nhận cấu hình, quản lý trạng thái và xây Navigator cùng các page. |
| `BackButtonDispatcher` | Chuyển yêu cầu Back hệ thống tới Router phù hợp. |
| `MaterialApp.router` | Cấu hình Router bằng `routerConfig` hoặc các thành phần tương ứng. Khi đã truyền `routerConfig`, không truyền thêm các thành phần rời tương ứng. |

## URL và lịch sử điều hướng

```text
URL /notes/1
    -> RouteInformationProvider
    -> RouteInformationParser.parseRouteInformation
    -> cấu hình noteId = 1
    -> RouterDelegate cập nhật trạng thái và build
    -> Navigator hiển thị [Danh sách, Chi tiết 1]
```

Chiều ngược lại: `RouterDelegate.currentConfiguration` cung cấp cấu hình hiện tại; `RouteInformationParser.restoreRouteInformation` chuyển cấu hình thành thông tin route để Router có thể cập nhật URL.

Khi người dùng Back hoặc Forward trên trình duyệt, thông tin route mới đi vào Router qua provider và parser. `restoreRouteInformation` không tự đảm nhiệm toàn bộ việc xử lý hai nút này.

Demo nhỏ hiện tại dùng Navigator và named routes. Router API được trình bày ở mức tổng quan; repo không triển khai `RouterDelegate`, parser hoặc `go_router`.

## Tài liệu chính thức

- [Navigation and routing](https://docs.flutter.dev/ui/navigation)
- [Pass arguments to a named route](https://docs.flutter.dev/cookbook/navigation/navigate-with-arguments)
- [Router](https://api.flutter.dev/flutter/widgets/Router-class.html)
- [restoreRouteInformation](https://api.flutter.dev/flutter/widgets/RouteInformationParser/restoreRouteInformation.html)
- [MaterialApp.onUnknownRoute](https://api.flutter.dev/flutter/material/MaterialApp/onUnknownRoute.html)
