import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/account_profile_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'screens/home/home_screen.dart';
import 'services/api_service.dart';
import 'services/cart_local_service.dart';
import 'services/order_remote_service.dart';

class MiniECommerceApp extends StatelessWidget {
  const MiniECommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ApiService()),
        Provider(create: (_) => CartLocalService()),
        Provider(create: (_) => OrderRemoteService()),
        ChangeNotifierProvider(create: (_) => AccountProfileProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (context) => ProductProvider(context.read<ApiService>()),
        ),
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (context) => CartProvider(context.read<CartLocalService>()),
          update: (context, authProvider, cartProvider) {
            final provider =
                cartProvider ?? CartProvider(context.read<CartLocalService>());
            provider.updateUser(authProvider.user?.uid);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
          create: (context) => OrderProvider(context.read<OrderRemoteService>()),
          update: (context, authProvider, orderProvider) {
            final provider =
                orderProvider ?? OrderProvider(context.read<OrderRemoteService>());
            provider.updateUser(authProvider.user?.uid);
            return provider;
          },
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
