import 'dart:async';
import '../models/user_model.dart';
import 'user_repository.dart';

class FakeUserRepository implements UserRepository {
  @override
  Future<UserModel> fetchCurrentUser() async {
    // Simula retardo de red
    await Future.delayed(const Duration(milliseconds: 500));
    return const UserModel(
      name: 'Sandra Chavez',
      email: 'san@example.com',
      tier: 'VIP',
      purchaseCount: 12,
      points: 250,
      nextTierTarget: 20,
      activeOrderId: 'ORD-98431',
    );
  }
}
