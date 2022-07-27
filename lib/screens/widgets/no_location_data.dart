import 'package:flutter/material.dart';

class NoLocationData extends StatelessWidget {
  Function handleTapGetLocation;

  NoLocationData({Key? key, required this.handleTapGetLocation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 150,
        child: Column(
          children: [
            Icon(
              Icons.warning,
              color: Theme.of(context).colorScheme.primary,
              size: 50,
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'There is no coordinates',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.grey),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton.icon(
              icon: const Icon(
                Icons.map_outlined,
                size: 30,
                color: Colors.white,
              ),
              label: const Text('GET MY LOCATION'),
              onPressed: () => handleTapGetLocation(),
            ),
          ],
        ),
      ),
    );
  }
}
