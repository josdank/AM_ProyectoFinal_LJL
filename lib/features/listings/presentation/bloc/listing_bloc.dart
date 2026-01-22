import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/listing.dart';
import '../../domain/usecases/create_listing.dart';
import '../../domain/usecases/delete_listing.dart';
import '../../domain/usecases/get_listings.dart';
import '../../domain/usecases/search_listings.dart';
import '../../domain/usecases/update_listing.dart';

part 'listing_event.dart';
part 'listing_state.dart';

class ListingBloc extends Bloc<ListingEvent, ListingState> {
  final GetListings getListings;
  final CreateListing createListing;
  final UpdateListing updateListing;
  final DeleteListing deleteListing;
  final SearchListings searchListings;

  ListingBloc({
    required this.getListings,
    required this.createListing,
    required this.updateListing,
    required this.deleteListing,
    required this.searchListings,
  }) : super(const ListingInitial()) {
    on<ListingsLoadRequested>(_onLoadRequested);
    on<ListingCreateRequested>(_onCreateRequested);
    on<ListingUpdateRequested>(_onUpdateRequested);
    on<ListingDeleteRequested>(_onDeleteRequested);
    on<ListingsSearchRequested>(_onSearchRequested);
    on<ListingImagesUploadRequested>(_onImagesUploadRequested);
  }

  Future<void> _onLoadRequested(
    ListingsLoadRequested event,
    Emitter<ListingState> emit,
  ) async {
    emit(const ListingLoading());

    final result = await getListings(const NoParams());

    result.fold(
      (failure) => emit(ListingError(message: failure.message)),
      (listings) => emit(ListingsLoaded(listings: listings)),
    );
  }

  Future<void> _onCreateRequested(
    ListingCreateRequested event,
    Emitter<ListingState> emit,
  ) async {
    emit(const ListingCreating());

    final result = await createListing(
      CreateListingParams(listing: event.listing),
    );

    result.fold(
      (failure) => emit(ListingError(message: failure.message)),
      (listing) => emit(ListingCreated(listing: listing)),
    );
  }

  Future<void> _onUpdateRequested(
    ListingUpdateRequested event,
    Emitter<ListingState> emit,
  ) async {
    emit(const ListingUpdating());

    final result = await updateListing(
      UpdateListingParams(listing: event.listing),
    );

    result.fold(
      (failure) => emit(ListingError(message: failure.message)),
      (listing) => emit(ListingUpdated(listing: listing)),
    );
  }

  Future<void> _onDeleteRequested(
    ListingDeleteRequested event,
    Emitter<ListingState> emit,
  ) async {
    emit(const ListingDeleting());

    final result = await deleteListing(
      DeleteListingParams(listingId: event.listingId),
    );

    result.fold(
      (failure) => emit(ListingError(message: failure.message)),
      (_) => emit(const ListingDeleted()),
    );
  }

  Future<void> _onSearchRequested(
    ListingsSearchRequested event,
    Emitter<ListingState> emit,
  ) async {
    emit(const ListingSearching());

    final result = await searchListings(
      SearchListingsParams(
        city: event.city,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
        roomType: event.roomType,
        amenities: event.amenities,
        petsAllowed: event.petsAllowed,
        smokingAllowed: event.smokingAllowed,
      ),
    );

    result.fold(
      (failure) => emit(ListingError(message: failure.message)),
      (listings) => emit(ListingsSearchResults(listings: listings)),
    );
  }

  Future<void> _onImagesUploadRequested(
    ListingImagesUploadRequested event,
    Emitter<ListingState> emit,
  ) async {
    emit(const ListingUploadingImages());

    // Este evento se maneja directamente en el repository
    // Se emite un estado de confirmación
    emit(const ListingImagesUploaded());
  }
}