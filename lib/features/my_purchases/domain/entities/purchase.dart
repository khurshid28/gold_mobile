import 'package:equatable/equatable.dart';

class Purchase extends Equatable {
  final String id;
  final String productName;
  final String productImage;
  final double totalPrice;
  final DateTime purchaseDate;
  final String status; // 'delivered', 'in_progress', 'cancelled'
  final bool isInstallment;
  final InstallmentDetails? installmentDetails;

  const Purchase({
    required this.id,
    required this.productName,
    required this.productImage,
    required this.totalPrice,
    required this.purchaseDate,
    required this.status,
    this.isInstallment = false,
    this.installmentDetails,
  });

  @override
  List<Object?> get props => [
        id,
        productName,
        productImage,
        totalPrice,
        purchaseDate,
        status,
        isInstallment,
        installmentDetails,
      ];

  // Mock data
  static List<Purchase> mockPurchases = [
    Purchase(
      id: '1',
      productName: 'Oltin uzuk 585',
      productImage: 'https://images.unsplash.com/photo-1605100804763-247f67b3557e',
      totalPrice: 5000000,
      purchaseDate: DateTime.now().subtract(const Duration(days: 90)),
      status: 'in_progress',
      isInstallment: true,
      installmentDetails: InstallmentDetails(
        totalAmount: 5000000,
        monthlyPayment: 500000,
        totalMonths: 12,
        paidMonths: 3,
        remainingAmount: 4000000,
        nextPaymentDate: DateTime.now().add(const Duration(days: 5)),
      ),
    ),
    Purchase(
      id: '2',
      productName: 'Oltin sirg\'a 750',
      productImage: 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908',
      totalPrice: 2500000,
      purchaseDate: DateTime.now().subtract(const Duration(days: 180)),
      status: 'delivered',
      isInstallment: false,
    ),
    Purchase(
      id: '3',
      productName: 'Oltin zanjir 585',
      productImage: 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f',
      totalPrice: 3000000,
      purchaseDate: DateTime.now().subtract(const Duration(days: 45)),
      status: 'in_progress',
      isInstallment: true,
      installmentDetails: InstallmentDetails(
        totalAmount: 3000000,
        monthlyPayment: 300000,
        totalMonths: 10,
        paidMonths: 2,
        remainingAmount: 2400000,
        nextPaymentDate: DateTime.now().add(const Duration(days: 12)),
      ),
    ),
  ];
}

class InstallmentDetails extends Equatable {
  final double totalAmount;
  final double monthlyPayment;
  final int totalMonths;
  final int paidMonths;
  final double remainingAmount;
  final DateTime nextPaymentDate;

  const InstallmentDetails({
    required this.totalAmount,
    required this.monthlyPayment,
    required this.totalMonths,
    required this.paidMonths,
    required this.remainingAmount,
    required this.nextPaymentDate,
  });

  int get remainingMonths => totalMonths - paidMonths;
  double get progressPercentage => (paidMonths / totalMonths) * 100;

  @override
  List<Object?> get props => [
        totalAmount,
        monthlyPayment,
        totalMonths,
        paidMonths,
        remainingAmount,
        nextPaymentDate,
      ];
}
