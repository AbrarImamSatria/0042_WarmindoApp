import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapViewSection extends StatelessWidget {
  final LatLng? selectedLocation;
  final LatLng defaultLocation;
  final Set<Marker> markers;
  final Function(GoogleMapController) onMapCreated;
  final Function(LatLng) onMapTap;

  const MapViewSection({
    Key? key,
    required this.selectedLocation,
    required this.defaultLocation,
    required this.markers,
    required this.onMapCreated,
    required this.onMapTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0),
      ),
      child: ClipRRect(
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: selectedLocation ?? defaultLocation,
            zoom: selectedLocation != null ? 16 : 13,
          ),
          onMapCreated: onMapCreated,
          onTap: onMapTap,
          markers: markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
          style: '''
            [
              {
                "featureType": "poi",
                "elementType": "labels",
                "stylers": [{"visibility": "off"}]
              }
            ]
          ''',
        ),
      ),
    );
  }
}