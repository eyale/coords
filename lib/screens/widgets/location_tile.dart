import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationTile extends StatelessWidget {
  const LocationTile({
    Key? key,
    required LocationData? locationData,
  })  : _locationData = locationData,
        super(key: key);

  final LocationData? _locationData;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.near_me,
        color: Theme.of(context).colorScheme.secondary,
      ),
      title: Text(
        'Your location is:',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          fontSize: 20,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Text(
          'Latitude: ${_locationData!.latitude},\nLongitude: ${_locationData!.longitude}',
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}
