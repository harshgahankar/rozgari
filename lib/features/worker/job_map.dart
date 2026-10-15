import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../app/theme.dart';
import '../../core/constants/meta.dart';
import '../../core/i18n/strings.dart';
import '../../core/utils/matching.dart';
import '../../data/models/models.dart';

/// Real interactive map for Find Work: pan, zoom, tappable job pins on
/// OpenStreetMap tiles (no API key needed). Pins use the app's real
/// locality coordinates; tiles need network, everything else is offline.
class JobMapView extends StatefulWidget {
  final List<Job> jobs;
  final String workerArea;
  final double radiusKm;
  final String lang;
  final String Function(Job) employerOf;
  const JobMapView({
    super.key,
    required this.jobs,
    required this.workerArea,
    required this.radiusKm,
    required this.lang,
    required this.employerOf,
  });
  @override
  State<JobMapView> createState() => _JobMapViewState();
}

class _JobMapViewState extends State<JobMapView> {
  final _map = MapController();
  bool _fitted = false;

  LatLngBounds _bounds(Map<String, List<Job>> byLoc) {
    final pts = <LatLng>[];
    final wc = kAreaCoords[widget.workerArea];
    if (wc != null) pts.add(LatLng(wc[0], wc[1]));
    for (final loc in byLoc.keys) {
      final c = kAreaCoords[loc]!;
      pts.add(LatLng(c[0], c[1]));
    }
    return LatLngBounds.fromPoints(pts);
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    final byLoc = <String, List<Job>>{};
    for (final j in widget.jobs) {
      if (kAreaCoords[j.location] == null) continue;
      byLoc.putIfAbsent(j.location, () => []).add(j);
    }
    if (byLoc.isEmpty) {
      return Center(child: Text(tr(lang, 'noJobsMatch')));
    }
    final bounds = _bounds(byLoc);
    final wc = kAreaCoords[widget.workerArea];
    final center = LatLng(
      (bounds.north + bounds.south) / 2,
      (bounds.east + bounds.west) / 2,
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 11,
              minZoom: 4,
              maxZoom: 18,
              onMapReady: () {
                if (!_fitted) {
                  _fitted = true;
                  _map.fitCamera(
                    CameraFit.bounds(
                      bounds: bounds,
                      padding: const EdgeInsets.all(56),
                    ),
                  );
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.rozgari.rozgari',
              ),
              if (wc != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: LatLng(wc[0], wc[1]),
                      radius: widget.radiusKm * 1000,
                      useRadiusInMeter: true,
                      color: const Color(0xFF2C4D42).withOpacity(.10),
                      borderColor: const Color(0xFF2C4D42).withOpacity(.45),
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  if (wc != null)
                    Marker(
                      point: LatLng(wc[0], wc[1]),
                      width: 36,
                      height: 36,
                      child: Container(
                        decoration: BoxDecoration(
                          color: KsColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.home_outlined,
                          color: KsColors.primary,
                          size: 18,
                        ),
                      ),
                    ),
                  for (final loc in byLoc.keys)
                    Marker(
                      point: (() {
                        final c = kAreaCoords[loc]!;
                        return LatLng(c[0], c[1]);
                      })(),
                      width: 72,
                      height: 72,
                      child: GestureDetector(
                        onTap: () =>
                            _spotSheet(context, loc, byLoc[loc]!),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: KsColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                byLoc[loc]!.length == 1
                                    ? '₹${byLoc[loc]!.first.payAmount.toStringAsFixed(0)}'
                                    : '×${byLoc[loc]!.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.location_on,
                              color: KsColors.danger,
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              color: Colors.white70,
              child: const Text(
                '© OpenStreetMap contributors',
                style: TextStyle(fontSize: 9, color: KsColors.muted),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _spotSheet(BuildContext context, String loc, List<Job> spot) {
    final lang = widget.lang;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: KsColors.danger,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      loc,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            for (final j in spot)
              ListTile(
                title: Text(
                  j.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  '${widget.employerOf(j)} • ₹${j.payAmount.toStringAsFixed(0)} • ${areaDistanceKm(widget.workerArea, j.location).toStringAsFixed(1)} km',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: FilledButton.tonal(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/job', arguments: j.id);
                  },
                  child: Text(tr(lang, 'details')),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
