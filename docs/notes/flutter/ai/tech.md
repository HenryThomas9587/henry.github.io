---
title: Flutter开发指南
createTime: 2025/01/03 23:01:35
permalink: /flutter/ai/tech/
---

## 身份与技能

- 精通 Flutter、Dart、Dio、GoRouter 、Riverpod、Freezed、Supabase。

## 核心原则

- 编写简洁、清晰的 Dart 代码。
- 优先使用组合而非继承；函数式优先于命令式。
- 文件结构：**widget > 子 widget > 辅助函数 > 静态内容 > 类型**。
- 导入规则：使用包名路径 (`package:`)，分组导入。

## 代码规范

### 1. 代码风格

- 不可变 widget 使用 `const` 构造函数。
- 简单函数和方法使用箭头语法。
- 对 getter 和 setter 使用单行表达式体。
- 使用尾逗号提升代码可读性。
- 保持每行代码不超过 80 个字符。

### 2.导入规则

#### 2.1 导入顺序

- Dart SDK 导入。
- 第三方库导入。
- 项目内部导入。

  示例：

  ```dart
  import 'dart:async';

  import 'package:flutter/material.dart';
  import 'package:riverpod/riverpod.dart';

  import 'package:my_app/core/constants.dart';
  import 'package:my_app/features/user/user_provider.dart';
  ```

#### 2.2 使用 `as` 创建别名避免冲突

#### 2.3 使用 `show` 或 `hide` 限制导入内容

### 3. 错误处理

- 使用 `SelectableText.rich` 显示错误，避免 SnackBars。
- 使用 `AsyncValue` 处理加载和错误状态。
- 在视图中处理空状态，提供用户友好的反馈。

### 4.类型约束

#### 4.1 明确类型声明

- 避免使用 `var`，除非类型显而易见。
- 示例：

  ```dart
  final String name = 'Flutter';
  final int count = 10;
  ```

#### 4.2 集合类型

- 显式指定集合类型。
- 示例：

  ```dart
  final List<String> names = ['Alice', 'Bob'];
  final Map<String, int> scores = {'Alice': 100, 'Bob': 90};
  ```

#### 4.3 空安全

- 明确区分可空类型和不可空类型。
- 示例：

  ```dart
  String? nullableString;
  String nonNullableString = '';
  ```

## 性能优化

1. 尽可能使用 `const` 优化重建。
2. 列表优化：使用 `ListView.builder`。
3. 静态图片使用 `AssetImage`，远程图片使用 `cached_network_image`。
4. 针对 Flutter 性能指标（首次有效绘制、可交互时间）进行优化。
5. 优先使用无状态 widget：
   - 对依赖状态的 widget 使用 ConsumerWidget 与 Riverpod 结合。
6. 在异步操作中正确释放资源，避免泄漏。

## 存储与数据管理

1. **本地存储**

   - 优先使用 `hive` 管理轻量级数据。
   - 对于更复杂的本地数据库操作，使用 `drift` 库。
   - 避免在 `shared_preferences` 中存储大型或敏感数据。

2. **数据加密**

   - 对敏感数据使用加密存储，如 `flutter_secure_storage`。
   - 存储前对密码或令牌等信息进行哈希处理（推荐使用 `bcrypt` 或 `Argon2` 算法）。

3. **文件存储**

   - 使用 `path_provider` 获取平台独立的存储目录。
   - 存储大文件时，优先选择缓存目录（`getTemporaryDirectory`），避免占用持久存储。
   - 定期清理临时文件夹以节省空间。

4. **云存储**

   - 对云存储（如 Supabase、Firebase）的访问，封装到独立的存储服务类中，便于测试和维护。
   - 上传文件时，显示进度条并处理可能的网络错误。

5. **缓存管理**

   - 使用适当的缓存策略：例如 `dio_cache_interceptor`。
   - 设置缓存的最大大小和过期时间。
   - 提供清理缓存的功能，供用户或应用程序定期调用。

6. **最佳实践**
   - 避免直接暴露存储服务，通过 Repository 模式抽象存储层。
   - 将存储操作放在后台线程中执行，以免阻塞 UI。
   - 在应用启动时，检查存储权限并正确处理权限被拒绝的情况。

## 架构和工具

### GoRouter

#### 1. 路由定义

- 使用语义化路径，路径应简洁明了。
- 使用 `name` 属性定义命名路由，便于管理和跳转。

##### 示例 1

```dart
final GoRouter router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      name: 'home',
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      name: 'details',
      path: '/details/:id',
      builder: (context, state) {
        final id = state.params['id']!;
        return DetailsPage(id: id);
      },
    ),
  ],
);
```

#### 2. 动态参数

- 使用 `state.params` 获取路径参数，`state.queryParams` 获取查询参数。
- 参数验证应在页面层实现。

##### 示例 2

```dart
GoRoute(
  path: '/profile/:username',
  builder: (context, state) {
    final username = state.params['username']!;
    final age = state.queryParams['age'];
    return ProfilePage(username: username, age: age);
  },
);
```

#### 3. 嵌套路由

- 使用嵌套路由管理层级页面导航。
- 路径设计应避免过深的嵌套。

##### 示例 3

```dart
GoRoute(
  path: '/dashboard',
  builder: (context, state) => const DashboardPage(),
  routes: [
    GoRoute(
      path: 'settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: 'profile',
      builder: (context, state) => const ProfilePage(),
    ),
  ],
);
```

#### 4. 路由守卫

- 使用 `redirect` 属性实现访问控制。
- 可根据登录状态或其他条件跳转到特定页面。

##### 示例 4

```dart
final GoRouter router = GoRouter(
  redirect: (context, state) {
    final isLoggedIn = AuthService().isLoggedIn;
    if (!isLoggedIn && state.location != '/login') {
      return '/login';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
  ],
);
```

#### 5. 错误页面

- 配置 `errorBuilder` 属性处理导航错误或未知路径。
- 提供统一的错误页面设计，提升用户体验。

##### 示例 5

```dart
final GoRouter router = GoRouter(
  errorBuilder: (context, state) => const ErrorPage(),
  routes: [
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
  ],
);
```

#### 6. 动态导航栏

- 使用 `ShellRoute` 结合 `BottomNavigationBar` 实现动态页面切换。

##### 示例 6

```dart
final GoRouter router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _getIndex(state.location),
            onTap: (index) {
              switch (index) {
                case 0:
                  router.go('/home');
                  break;
                case 1:
                  router.go('/profile');
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        );
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),
  ],
);

int _getIndex(String location) {
  if (location.startsWith('/home')) return 0;
  if (location.startsWith('/profile')) return 1;
  return 0;
}
```

#### 7. 跳转与导航

- 使用 `go` 或 `goNamed` 方法进行页面跳转。
- 返回上一页时使用 `pop` 方法。

##### 示例 7

```dart
// 跳转到指定路径
router.go('/details/123');

// 使用命名路由跳转
router.goNamed('details', params: {'id': '123'});

// 返回上一页
router.pop();
```

### Riverpod

1. 使用 `@riverpod` 注解生成 provider。
2. 优先使用 `AsyncNotifierProvider` 和 `NotifierProvider`。
3. 避免使用 `StateProvider`、`ChangeNotifierProvider` 等旧模式。
4. 使用 `ref.invalidate()` 手动触发 provider 更新。

### Dio

#### 1. 配置

- 使用单例模式创建 `Dio` 实例。
- 配置基础 URL 和超时时间。
- 添加日志拦截器处理请求和响应。

  ```dart
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.example.com',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  dio.interceptors.add(LogInterceptor(
    request: true,
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
    responseBody: true,
  ));
  ```

#### 2. 错误处理

- 使用 `try-catch` 捕获 `DioException`。
- 区分网络错误和业务逻辑错误。

  ```dart
  try {
    final response = await dio.get('/endpoint');
    return response.data;
  } on DioException catch (e) {
    if (e.response != null) {
      throw ServerException(e.response!.data['message']);
    } else {
      throw NetworkException(e.message ?? '网络连接失败');
    }
  }
  ```

#### 3. 文件上传

- 使用 `FormData` 上传文件，支持显示上传进度。

  ```dart
  final formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(filePath),
    'other_field': 'value',
  });

  final response = await dio.post(
    '/upload',
    data: formData,
    onSendProgress: (sent, total) {
      final progress = sent / total;
      // 更新进度
    },
  );
  ```

#### 4. 缓存

- 使用 `dio_cache_interceptor` 实现缓存机制。
- 支持强制刷新策略。

## UI 和样式

1. 使用 `Theme.of(context)` 设置一致样式。
2. 响应式设计：`LayoutBuilder` 和 `MediaQuery`。
3. 使用 `textTheme` 替代旧的 `headline` 系列。

## Dart/Flutter 工具

1. `dart format` 格式化代码。
2. `dart analyze` 检查代码问题。
3. `dart fix` 自动修复语法问题。
4. 使用 `flutter pub run build_runner build` 生成代码。
5. 使用 `flutter pub run build_runner watch` 自动监听代码变化并生成。
6. 使用注解工具生成代码：`Freezed`、`Riverpod`、`JsonSerializable`。
7. 修改注解类后运行：

   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

## 日志和调试

1. 使用 `log` 替代 `print`。
2. 使用 `logger` 管理日志。
3. 在生产环境中禁用日志。

## 总结

通过本指南，开发者可以高效构建清晰、规范和性能优化的 Flutter 应用！
