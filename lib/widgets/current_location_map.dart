import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class CurrentLocationMap extends StatefulWidget {
  const CurrentLocationMap({super.key});

  @override
  State<CurrentLocationMap> createState() => _CurrentLocationMapState();
}

class _CurrentLocationMapState extends State<CurrentLocationMap> {
  GoogleMapController? _controller;
  LatLng? _currentLatLng;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _currentLatLng = LatLng(position.latitude, position.longitude);
    });
    if (!mounted) return;
    if (_controller != null && _currentLatLng != null) {
      try {
        _controller!.animateCamera(
          CameraUpdate.newLatLng(_currentLatLng!),
        );
      } catch (_) {
        // ignore errors if controller is not ready
      }
    }
  }

  @override
  void dispose() {
    try {
      _controller?.dispose();
    } catch (_) {
      // ignore dispose errors
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF232323),
        borderRadius: BorderRadius.circular(12),
      ),
      child: _currentLatLng == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLatLng!,
                zoom: 16,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (controller) => _controller = controller,
              markers: {
                Marker(
                  markerId: const MarkerId('me'),
                  position: _currentLatLng!,
                  infoWindow: const InfoWindow(title: 'Você está aqui'),
                ),
              },
            ),
    );
  }
}