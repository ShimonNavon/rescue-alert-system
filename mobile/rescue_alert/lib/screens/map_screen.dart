import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../logic/map/map_bloc.dart';
import '../repositories/location_repository.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    final token = const String.fromEnvironment('MAPBOX_ACCESS_TOKEN');
    if (token.isNotEmpty) {
      MapboxOptions.setAccessToken(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MapBloc(locationRepository: context.read<LocationRepository>())
            ..add(MapStarted()),
      child: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    MapWidget(
                      key: const ValueKey('mapbox-map'),
                      styleUri: MapboxStyles.OUTDOORS,
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: FloatingActionButton.small(
                        onPressed: () =>
                            context.read<MapBloc>().add(MapRefreshRequested()),
                        child: const Icon(Icons.refresh),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  itemCount: state.locations.length,
                  itemBuilder: (context, index) {
                    final location = state.locations[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.person_pin_circle),
                      title: Text('${location.userName} (${location.role})'),
                      subtitle: Text(
                        '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}',
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
