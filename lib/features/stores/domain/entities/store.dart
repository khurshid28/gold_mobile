import 'package:equatable/equatable.dart';

class Store extends Equatable {
  final String id;
  final String name;
  final String address;
  final String phoneNumber;
  final String workingHours;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final List<String> imageGallery;
  final bool hasParking;
  final bool hasAccessibility;

  const Store({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.workingHours,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    this.imageGallery = const [],
    this.hasParking = false,
    this.hasAccessibility = false,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        phoneNumber,
        workingHours,
        latitude,
        longitude,
        imageUrl,
        imageGallery,
        hasParking,
        hasAccessibility,
      ];

  // Mock data for demo
  static List<Store> mockStores = [
    Store(
      id: '1',
      name: 'Gold Imperia Tashkent City',
      address: 'Tashkent City, Amir Temur shox ko\'chasi, 108',
      phoneNumber: '+998 71 123-45-67',
      workingHours: '10:00 - 21:00',
      latitude: 41.311081,
      longitude: 69.240562,
      imageUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8',
      imageGallery: [
        'https://images.unsplash.com/photo-1441986300917-64674bd600d8',
        'https://images.unsplash.com/photo-1574643156929-51fa098b0394',
        'https://images.unsplash.com/photo-1555421689-d68471e189f2',
      ],
      hasParking: true,
      hasAccessibility: true,
    ),
    Store(
      id: '2',
      name: 'Gold Imperia Next',
      address: 'Next, Nurafshon ko\'chasi, 1',
      phoneNumber: '+998 71 234-56-78',
      workingHours: '10:00 - 22:00',
      latitude: 41.285545,
      longitude: 69.203752,
      imageUrl: 'https://images.unsplash.com/photo-1574643156929-51fa098b0394',
      imageGallery: [
        'https://images.unsplash.com/photo-1574643156929-51fa098b0394',
        'https://images.unsplash.com/photo-1555421689-d68471e189f2',
      ],
      hasParking: true,
      hasAccessibility: false,
    ),
    Store(
      id: '3',
      name: 'Gold Imperia Mega Planet',
      address: 'Mega Planet, Furqat ko\'chasi, 175',
      phoneNumber: '+998 71 345-67-89',
      workingHours: '10:00 - 23:00',
      latitude: 41.335171,
      longitude: 69.289933,
      imageUrl: 'https://images.unsplash.com/photo-1555421689-d68471e189f2',
      imageGallery: [
        'https://images.unsplash.com/photo-1555421689-d68471e189f2',
        'https://images.unsplash.com/photo-1441986300917-64674bd600d8',
      ],
      hasParking: true,
      hasAccessibility: true,
    ),
  ];
}
