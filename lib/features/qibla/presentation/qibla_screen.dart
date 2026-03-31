import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../app/providers.dart';
import '../../../core/time/geo_coordinates.dart';

class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen> {
  GeoCoordinates? _deviceCoordinates;
  String? _locationMessage;
  bool _isLoadingLocation = false;

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(prayerCalculationConfigProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Qibla')),
      body: configAsync.when(
        data: (config) {
          final coordinates = _deviceCoordinates ?? config.coordinates;
          final bearing = ref
              .read(qiblaServiceProvider)
              .bearingFor(coordinates);

          return StreamBuilder<CompassEvent?>(
            stream: FlutterCompass.events,
            builder: (context, snapshot) {
              final event = snapshot.data;
              final heading = event?.heading;
              final rotation = heading == null ? bearing : bearing - heading;
              final accuracy = event?.accuracy;

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _deviceCoordinates == null
                                ? 'Using saved coordinates'
                                : 'Using device coordinates',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bearing ${bearing.toStringAsFixed(1)}° true',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Accuracy ${_accuracyLabel(accuracy)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (_locationMessage != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _locationMessage!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              FilledButton(
                                onPressed: _isLoadingLocation
                                    ? null
                                    : _loadDeviceCoordinates,
                                child: Text(
                                  _isLoadingLocation
                                      ? 'Locating...'
                                      : 'Use device location',
                                ),
                              ),
                              OutlinedButton(
                                onPressed: _deviceCoordinates == null
                                    ? null
                                    : () {
                                        setState(() {
                                          _deviceCoordinates = null;
                                          _locationMessage = null;
                                        });
                                      },
                                child: const Text('Use saved location'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 300,
                            child: Center(
                              child: _CompassDial(
                                rotationDegrees: rotation,
                                headingDegrees: heading,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            heading == null
                                ? 'Compass heading unavailable. Numeric bearing remains the fallback.'
                                : 'Turn until the arrow points up. The arrow always points toward the Kaaba.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (_needsCalibration(accuracy)) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text(
                                'Calibration: move your phone in a figure-8 pattern until the compass accuracy improves.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Coordinates',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Latitude ${coordinates.latitude.toStringAsFixed(4)}',
                          ),
                          Text(
                            'Longitude ${coordinates.longitude.toStringAsFixed(4)}',
                          ),
                          if (heading != null)
                            Text('Heading ${heading.toStringAsFixed(1)}°'),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(error.toString(), textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }

  Future<void> _loadDeviceCoordinates() async {
    setState(() {
      _isLoadingLocation = true;
      _locationMessage = null;
    });

    try {
      final servicesEnabled = await Geolocator.isLocationServiceEnabled();
      if (!servicesEnabled) {
        setState(() {
          _locationMessage = 'Location services are disabled on this device.';
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _locationMessage =
              'Location permission is required for live Qibla coordinates.';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _deviceCoordinates = GeoCoordinates(
          latitude: position.latitude,
          longitude: position.longitude,
        );
        _locationMessage = 'Using your current device coordinates.';
      });
    } catch (error) {
      setState(() {
        _locationMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  bool _needsCalibration(double? accuracy) {
    return accuracy == null || accuracy > 35;
  }

  String _accuracyLabel(double? accuracy) {
    if (accuracy == null) {
      return 'Unknown';
    }
    if (accuracy <= 15) {
      return 'High';
    }
    if (accuracy <= 35) {
      return 'Medium';
    }
    return 'Low';
  }
}

class _CompassDial extends StatelessWidget {
  const _CompassDial({
    required this.rotationDegrees,
    required this.headingDegrees,
  });

  final double rotationDegrees;
  final double? headingDegrees;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: scheme.surfaceContainerHighest,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned(top: 16, child: Text('N')),
            const Positioned(right: 18, child: Text('E')),
            const Positioned(bottom: 16, child: Text('S')),
            const Positioned(left: 18, child: Text('W')),
            Transform.rotate(
              angle: rotationDegrees * math.pi / 180,
              child: Icon(
                Icons.navigation_rounded,
                size: 120,
                color: scheme.primary,
              ),
            ),
            Positioned(
              bottom: 52,
              child: Text(
                headingDegrees == null
                    ? 'No heading'
                    : '${headingDegrees!.toStringAsFixed(1)}°',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
