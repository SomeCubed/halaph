import 'package:flutter/material.dart';
import 'package:halaph/models/destination.dart';
import 'package:halaph/services/destination_service.dart';
import 'package:halaph/screens/route_options_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ExploreDetailsScreen extends StatefulWidget {
  final String destinationId;
  final String? source;
  final Destination? destination;

  const ExploreDetailsScreen({
    super.key,
    required this.destinationId,
    this.source,
    this.destination,
  });

  @override
  State<ExploreDetailsScreen> createState() => _ExploreDetailsScreenState();

  static void showAsBottomSheet(BuildContext context, {required String destinationId, String? source, Destination? destination}) {
    print('=== EXPLORE DETAILS OPENING ===');
    print('Opening details for destination ID: $destinationId');
    print('Source: $source');
    print('Destination provided: ${destination != null ? destination.name : 'No'}');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: ExploreDetailsScreen(
          destinationId: destinationId,
          source: source,
          destination: destination,
        ),
      ),
    );
  }
}

class _ExploreDetailsScreenState extends State<ExploreDetailsScreen> {
  Destination? _destination;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDestination();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadDestination() async {
    setState(() => _isLoading = true);

    try {
      print('=== EXPLORE DETAILS: Loading destination ===');
      print('Destination ID: "${widget.destinationId}"');
      print('Source: "${widget.source}"');
      
      Destination? found;
      
      // If destination is already provided (from explore screen), use it
      if (widget.destination != null) {
        print('✅ Using provided destination: ${widget.destination!.name}');
        found = widget.destination;
      }
      
      // Only search if destination not already found
      if (found == null && widget.source == 'home') {
        print('Loading from home screen...');
        final destinations = await DestinationService.getTrendingDestinations();
        print('Found ${destinations.length} trending destinations');
        
        for (var dest in destinations) {
          print('  - ${dest.name} (ID: ${dest.id})');
          if (dest.id == widget.destinationId) {
            found = dest;
            print('✅ MATCH FOUND by ID!');
            break;
          }
        }
      } else if (found == null && widget.source == 'explore') {
        print('Loading from explore search results...');
        // For explore results, search with the destination name to get similar results
        final searchResults = await DestinationService.searchDestinationsEnhanced(
          query: widget.destinationId,
        );
        print('Found ${searchResults.length} search results');
        
        // First try by ID
        for (var dest in searchResults) {
          print('  - ${dest.name} (ID: ${dest.id})');
          if (dest.id == widget.destinationId) {
            found = dest;
            print('✅ MATCH FOUND by ID!');
            break;
          }
        }
        
        // If not found by ID, try by name
        if (found == null) {
          print('❌ No match by ID, trying by name...');
          for (var dest in searchResults) {
            if (dest.name.toLowerCase() == widget.destinationId.toLowerCase()) {
              found = dest;
              print('✅ MATCH FOUND by name!');
              break;
            }
          }
        }
      } else if (found == null) {
        print('Loading from search results...');
        // For search results, try to find in all destinations
        final allDestinations = await DestinationService.searchDestinationsEnhanced();
        print('Found ${allDestinations.length} total destinations');
        
        // First try by ID
        for (var dest in allDestinations) {
          print('  - ${dest.name} (ID: ${dest.id})');
          if (dest.id == widget.destinationId) {
            found = dest;
            print('✅ MATCH FOUND by ID!');
            break;
          }
        }
        
        // If not found by ID, try by name
        if (found == null) {
          print('❌ No match by ID, trying by name...');
          for (var dest in allDestinations) {
            if (dest.name.toLowerCase() == widget.destinationId.toLowerCase()) {
              found = dest;
              print('✅ MATCH FOUND by name!');
              break;
            }
          }
        }
        
        // If still not found, try a broader search with the destination name
        if (found == null) {
          print('❌ Still no match, trying broader search...');
          final searchResults = await DestinationService.searchDestinationsEnhanced(
            query: widget.destinationId,
          );
          print('Search returned ${searchResults.length} results');
          
          for (var dest in searchResults) {
            if (dest.id == widget.destinationId) {
              found = dest;
              print('✅ MATCH FOUND in broader search!');
              break;
            }
          }
        }
      }

      setState(() {
        _destination = found;
        _isLoading = false;
      });
      
      if (found != null) {
        print('✅ SUCCESS: Loaded ${found.name}');
      } else {
        print('❌ FAILED: Destination not found');
      }
    } catch (e) {
      print('❌ ERROR loading destination: $e');
      debugPrint('Error loading destination: $e');
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_destination == null) {
      return const Center(child: Text('Destination not found'));
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar at the top
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Close button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Explore Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeroImageWithOverlay(),
                    const SizedBox(height: 16),
                    _buildCategorySection(),
                    const SizedBox(height: 16),
                    _buildAddToPlanButton(),
                    const SizedBox(height: 24),
                    _buildAboutSection(),
                    const SizedBox(height: 24),
                    _buildViewRoutesButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImageWithOverlay() {
    final imageUrl = _destination!.imageUrl;
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[100],
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.blue[600],
                          ),
                        ),
                      ),
                      errorWidget: (_, _, _) => _buildFallbackImage(),
                    )
                  : _buildFallbackImage(),
            ),
          ),
          // Heart icon in top right
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.favorite_border,
                color: Colors.red,
                size: 20,
              ),
            ),
          ),
          // Text overlay at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _destination!.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _destination!.location,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF81D4FA), Color(0xFF29B6F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.place, size: 48, color: Colors.white),
            SizedBox(height: 8),
            Text(
              'No Photo Available',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getCategoryIcon(_destination!.category),
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  DestinationService.getCategoryName(_destination!.category),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(DestinationCategory category) {
    switch (category) {
      case DestinationCategory.park:
        return Icons.park;
      case DestinationCategory.landmark:
        return Icons.location_city;
      case DestinationCategory.food:
        return Icons.restaurant;
      case DestinationCategory.activities:
        return Icons.beach_access;
      case DestinationCategory.museum:
        return Icons.museum;
      case DestinationCategory.market:
        return Icons.shopping_cart;
    }
  }


  Widget _buildAboutSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About the destination',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _destination!.description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToPlanButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Add to Plan',
            style: TextStyle(
              color: Colors.green,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.green,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildViewRoutesButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RouteOptionsScreen(
                destinationId: widget.destinationId,
                destinationName: _destination?.name ?? 'Destination',
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'View Routes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}