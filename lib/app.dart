import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'screens/home/home_screen.dart';
import 'services/api_service.dart';
import 'services/cart_local_service.dart';

class MiniECommerceApp extends StatelessWidget {
  const MiniECommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ApiService()),
        Provider(create: (_) => CartLocalService()),
        ChangeNotifierProvider(
          create: (context) => ProductProvider(context.read<ApiService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => CartProvider(context.read<CartLocalService>()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Ứng dụng bán hàng mini',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF5722)),
          scaffoldBackgroundColor: const Color(0xFFF8F8F8),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
