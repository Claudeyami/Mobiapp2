# Movie App - Flutter Application

Ứng dụng xem phim được phát triển bằng Flutter, hỗ trợ đăng nhập, xem danh sách phim, tìm kiếm, và quản lý thông tin cá nhân.

## 📱 Chức năng chính

### 1. Xác thực người dùng (Authentication)
- **Đăng nhập**: Người dùng đăng nhập bằng email và mật khẩu
- **Đăng ký**: Tạo tài khoản mới với email, mật khẩu và họ tên
- **Đăng xuất**: Thoát khỏi phiên đăng nhập hiện tại
- **Lưu trữ phiên đăng nhập**: Sử dụng SharedPreferences để lưu userId, tự động đăng nhập khi mở app

### 2. Danh sách phim (Movie List)
- **Hiển thị danh sách phim**: Lấy dữ liệu từ API và hiển thị dưới dạng grid/list
- **Lọc theo thể loại**: Dropdown để chọn thể loại phim (Hành động, Tình cảm, Kinh dị, v.v.)
- **Pull-to-refresh**: Kéo xuống để làm mới danh sách phim
- **Xử lý lỗi**: Hiển thị thông báo khi không tải được dữ liệu
- **Empty state**: UI khi không có phim hoặc lỗi

### 3. Chi tiết phim (Movie Detail)
- **Thông tin phim**: Hiển thị poster, tiêu đề, mô tả, thể loại
- **Đánh giá phim**: Người dùng có thể đánh giá phim từ 1-5 sao
- **Bình luận**: 
  - Xem danh sách bình luận của phim
  - Thêm bình luận mới
  - Hiển thị tên người dùng và nội dung bình luận
- **SliverAppBar**: AppBar co giãn khi scroll với poster làm background

### 4. Tìm kiếm (Search)
- **Tìm kiếm phim**: Nhập từ khóa để tìm phim theo tên
- **Kết quả tìm kiếm**: Hiển thị danh sách phim khớp với từ khóa
- **Empty state**: Hiển thị khi chưa tìm kiếm hoặc không có kết quả
- **Xóa từ khóa**: Nút xóa nhanh trong ô tìm kiếm

### 5. Thông tin cá nhân (Profile)
- **Xem thông tin**: Hiển thị avatar, tên, email, số điện thoại
- **Chỉnh sửa thông tin**: Cập nhật tên, email, số điện thoại
- **Lưu trữ local**: Lưu thông tin vào SharedPreferences nếu backend chưa hỗ trợ update
- **Avatar placeholder**: Hiển thị chữ cái đầu của tên khi không có avatar
- **Validation**: Kiểm tra định dạng email, số điện thoại
- **Đăng xuất**: Nút đăng xuất với xác nhận

### 6. Navigation
- **Bottom Navigation Bar**: 3 tab chính
  - Danh sách phim
  - Tìm kiếm
  - Cá nhân
- **Auto navigation**: Tự động chuyển đến HomeScreen khi đăng nhập thành công
- **Back navigation**: Quay lại màn hình trước bằng AppBar back button

## 🏗️ Kiến trúc & Công nghệ

### Kiến trúc ứng dụng

**MVVM Pattern (Model-View-ViewModel)**
- **Models**: Định nghĩa cấu trúc dữ liệu (Movie, User, Comment, LoginResponse)
- **Views (Screens)**: Giao diện người dùng (LoginScreen, HomeScreen, MovieListScreen, v.v.)
- **ViewModels (Providers)**: Quản lý state và business logic (AuthProvider, MovieProvider)
- **Services**: Xử lý API calls (AuthApiService, MovieApiService)

### State Management

**Provider Pattern**
- Sử dụng `provider` package để quản lý state toàn cục
- `AuthProvider`: Quản lý trạng thái đăng nhập, userId, loading, error
- `MovieProvider`: Quản lý danh sách phim (hiện tại ít sử dụng)
- `ChangeNotifier`: Thông báo các widget lắng nghe khi state thay đổi

### Công nghệ & Packages

1. **Flutter SDK**: Framework phát triển ứng dụng mobile cross-platform
   - Material Design 3
   - Widget tree architecture
   - Hot reload/Hot restart

2. **HTTP Client - Dio** (`dio: ^5.4.0`)
   - Gửi HTTP requests (GET, POST, PUT, PATCH)
   - Xử lý timeout, error handling
   - Singleton pattern cho ApiClient

3. **State Management - Provider** (`provider: ^6.1.2`)
   - Quản lý state toàn cục
   - `ChangeNotifier` cho reactive programming
   - `Consumer` và `context.watch()` để lắng nghe thay đổi

4. **Local Storage - SharedPreferences** (`shared_preferences: ^2.2.2`)
   - Lưu trữ dữ liệu key-value trên thiết bị
   - Lưu userId sau khi đăng nhập
   - Lưu thông tin profile khi backend không hỗ trợ

### Cấu trúc thư mục

```
lib/
├── main.dart                    # Entry point của app
├── core/
│   └── network/
│       └── api_client.dart      # HTTP client singleton (Dio)
├── models/
│   ├── movie.dart              # Model cho Movie
│   ├── user.dart               # Model cho User
│   ├── comment.dart            # Model cho Comment
│   └── login_response.dart     # Model cho Login response
├── services/
│   ├── auth_api_service.dart   # API service cho authentication
│   └── movie_api_service.dart  # API service cho movies
├── providers/
│   ├── auth_provider.dart      # Provider cho authentication state
│   └── movie_provider.dart     # Provider cho movie state
└── screens/
    ├── login_screen.dart       # Màn hình đăng nhập
    ├── register_screen.dart    # Màn hình đăng ký
    ├── home_screen.dart        # Màn hình chính với BottomNavBar
    ├── movie_list_screen.dart  # Danh sách phim
    ├── movie_detail_screen.dart # Chi tiết phim
    ├── search_screen.dart      # Tìm kiếm phim
    └── profile_screen.dart     # Thông tin cá nhân
```

## 🔌 API Integration

### Base URL
```
http://10.0.2.2:4000/api
```
(Lưu ý: `10.0.2.2` là IP của localhost trong Android Emulator)

### Endpoints

**Authentication:**
- `POST /auth/login` - Đăng nhập
- `POST /auth/register` - Đăng ký
- `GET /users/:id` - Lấy thông tin user (fallback endpoints: `/users/me`, `/profile`, `/user/profile`)
- `PUT /users/:id` - Cập nhật thông tin user (fallback: `PATCH`, multiple endpoints)

**Movies:**
- `GET /movies` - Lấy danh sách phim
- `GET /movies/:id` - Lấy chi tiết phim
- `GET /movies/search?q=:keyword` - Tìm kiếm phim
- `GET /movies/:id/comments` - Lấy bình luận của phim
- `POST /movies/:id/comments` - Thêm bình luận
- `POST /movies/:id/rating` - Đánh giá phim

### Error Handling

- **Robust parsing**: Xử lý các trường hợp id có thể là null, int, String, hoặc double
- **Multiple endpoint retry**: Thử nhiều endpoint khi một endpoint trả về 404
- **Fallback to local storage**: Lưu vào local storage nếu backend không hỗ trợ
- **User-friendly error messages**: Trích xuất error message từ server response (message, error, msg, errors, missingFields)

## 🎨 UI/UX Features

### Design System
- **Material Design 3**: Sử dụng Material 3 design system
- **Color Scheme**: Deep Purple làm màu chủ đạo
- **Gradient Backgrounds**: Màn hình đăng nhập/đăng ký có gradient purple
- **Card-based Layout**: Sử dụng Card widget cho form inputs và list items
- **Rounded Corners**: Border radius 12-16px cho các UI elements

### Responsive Design
- **SafeArea**: Bảo vệ nội dung khỏi notch/status bar
- **SingleChildScrollView**: Scroll được khi bàn phím xuất hiện
- **Flexible Layout**: Sử dụng Expanded, Flexible cho responsive

### Loading States
- **CircularProgressIndicator**: Hiển thị khi đang tải dữ liệu
- **Skeleton/Shimmer**: Có thể thêm trong tương lai

### Empty States
- **Icons**: Icon rõ ràng (search, error_outline, movie_filter_outlined)
- **Messages**: Thông báo ngắn gọn, dễ hiểu
- **Retry buttons**: Nút thử lại khi có lỗi

## 🔒 Security & Best Practices

### Authentication
- **Session persistence**: Lưu userId trong SharedPreferences
- **Auto logout**: Xóa session khi đăng xuất
- **Form validation**: Validate email format, password length

### Data Handling
- **Defensive parsing**: Kiểm tra null, type conversion an toàn
- **Error boundaries**: Try-catch ở mọi async operations
- **Mounted check**: Kiểm tra `mounted` trước khi `setState()` sau async

### Code Quality
- **Separation of concerns**: Models, Services, Providers, Screens tách biệt
- **Singleton pattern**: ApiClient sử dụng singleton
- **Null safety**: Sử dụng nullable types và null-aware operators
- **DRY principle**: Tránh lặp code, tái sử dụng components

## 🚀 Cài đặt & Chạy ứng dụng

### Yêu cầu
- Flutter SDK >= 3.10.0
- Dart SDK >= 3.10.0
- Android Studio / VS Code với Flutter extensions
- Android Emulator hoặc thiết bị thật

### Cài đặt dependencies
```bash
flutter pub get
```

### Chạy ứng dụng
```bash
flutter run
```

### Build APK (Android)
```bash
flutter build apk --release
```

## 📝 Lý thuyết áp dụng

### 1. Reactive Programming
- **ChangeNotifier**: Khi state thay đổi, tất cả listeners được thông báo
- **Consumer/context.watch()**: Widget tự động rebuild khi state thay đổi
- **setState()**: Local state management trong StatefulWidget

### 2. Asynchronous Programming
- **Future/async-await**: Xử lý các operations bất đồng bộ (API calls)
- **Error handling**: Try-catch cho async operations
- **Loading states**: Quản lý trạng thái loading để cải thiện UX

### 3. HTTP/REST API
- **RESTful principles**: GET (read), POST (create), PUT (update), PATCH (partial update)
- **Request/Response cycle**: Gửi request, xử lý response, error handling
- **Timeout handling**: Connection timeout, receive timeout

### 4. Local Storage
- **SharedPreferences**: Key-value storage trên thiết bị
- **Persistence**: Dữ liệu được lưu ngay cả khi đóng app
- **Offline support**: Fallback to local storage khi API không khả dụng

### 5. State Management Patterns
- **Provider Pattern**: Centralized state management
- **InheritedWidget**: Provider sử dụng InheritedWidget để truyền state xuống widget tree
- **Observer Pattern**: ChangeNotifier là implementation của Observer pattern

### 6. Widget Lifecycle
- **initState()**: Khởi tạo state, gọi API
- **dispose()**: Cleanup resources (controllers, listeners)
- **mounted**: Kiểm tra widget còn trong tree trước khi setState()

### 7. Navigation
- **Navigator.push()**: Chuyển đến màn hình mới
- **Navigator.pop()**: Quay lại màn hình trước
- **Navigator.pushReplacement()**: Thay thế màn hình hiện tại

### 8. Form Validation
- **GlobalKey<FormState>**: Quản lý form state
- **TextFormField validator**: Validation callback cho mỗi field
- **Real-time validation**: Validate khi user nhập

## 🔮 Tính năng có thể mở rộng

1. **Offline mode**: Cache dữ liệu phim, xem offline
2. **Favorites/Watchlist**: Lưu phim yêu thích
3. **Push notifications**: Thông báo phim mới
4. **Social features**: Chia sẻ phim, theo dõi bạn bè
5. **Advanced search**: Lọc theo năm, rating, diễn viên
6. **Image caching**: Cache poster phim để tải nhanh hơn
7. **Dark mode**: Chế độ tối
8. **Multi-language**: Đa ngôn ngữ

## 📄 License

Dự án này được phát triển cho mục đích học tập và đồ án cá nhân.
