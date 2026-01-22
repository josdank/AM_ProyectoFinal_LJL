// part of 'listing_bloc.dart';

part of 'listing_bloc.dart';

abstract class ListingState extends Equatable {
  const ListingState();

  @override
  List<Object?> get props => [];
}

class ListingInitial extends ListingState {
  const ListingInitial();
}

class ListingLoading extends ListingState {
  const ListingLoading();
}

class ListingCreating extends ListingState {
  const ListingCreating();
}

class ListingUpdating extends ListingState {
  const ListingUpdating();
}

class ListingDeleting extends ListingState {
  const ListingDeleting();
}

class ListingSearching extends ListingState {
  const ListingSearching();
}

class ListingUploadingImages extends ListingState {
  const ListingUploadingImages();
}

class ListingsLoaded extends ListingState {
  final List<Listing> listings;

  const ListingsLoaded({required this.listings});

  @override
  List<Object?> get props => [listings];
}

class ListingCreated extends ListingState {
  final Listing listing;

  const ListingCreated({required this.listing});

  @override
  List<Object?> get props => [listing];
}

class ListingUpdated extends ListingState {
  final Listing listing;

  const ListingUpdated({required this.listing});

  @override
  List<Object?> get props => [listing];
}

class ListingDeleted extends ListingState {
  const ListingDeleted();
}

class ListingsSearchResults extends ListingState {
  final List<Listing> listings;

  const ListingsSearchResults({required this.listings});

  @override
  List<Object?> get props => [listings];
}

class ListingImagesUploaded extends ListingState {
  const ListingImagesUploaded();
}

class ListingError extends ListingState {
  final String message;

  const ListingError({required this.message});

  @override
  List<Object?> get props => [message];
}