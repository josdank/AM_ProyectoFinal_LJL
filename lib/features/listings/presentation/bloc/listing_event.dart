// part of 'listing_bloc.dart';

part of 'listing_bloc.dart';

abstract class ListingEvent extends Equatable {
  const ListingEvent();

  @override
  List<Object?> get props => [];
}

class ListingsLoadRequested extends ListingEvent {
  const ListingsLoadRequested();
}

class ListingCreateRequested extends ListingEvent {
  final Listing listing;

  const ListingCreateRequested({required this.listing});

  @override
  List<Object?> get props => [listing];
}

class ListingUpdateRequested extends ListingEvent {
  final Listing listing;

  const ListingUpdateRequested({required this.listing});

  @override
  List<Object?> get props => [listing];
}

class ListingDeleteRequested extends ListingEvent {
  final String listingId;

  const ListingDeleteRequested({required this.listingId});

  @override
  List<Object?> get props => [listingId];
}

class ListingsSearchRequested extends ListingEvent {
  final String? city;
  final double? minPrice;
  final double? maxPrice;
  final String? roomType;
  final List<String>? amenities;
  final bool? petsAllowed;
  final bool? smokingAllowed;

  const ListingsSearchRequested({
    this.city,
    this.minPrice,
    this.maxPrice,
    this.roomType,
    this.amenities,
    this.petsAllowed,
    this.smokingAllowed,
  });

  @override
  List<Object?> get props => [
        city,
        minPrice,
        maxPrice,
        roomType,
        amenities,
        petsAllowed,
        smokingAllowed,
      ];
}

class ListingImagesUploadRequested extends ListingEvent {
  final List<XFile> images;
  final String listingId;

  const ListingImagesUploadRequested({
    required this.images,
    required this.listingId,
  });

  @override
  List<Object?> get props => [images, listingId];
}