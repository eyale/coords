import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({Key? key}) : super(key: key);

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  LocationData? _locationData;

  bool _isLoading = false;

  void _getLocation() async {
    setState(() {
      _isLoading = !_isLoading;
    });
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    debugPrint('locationData: $locationData');
    setState(() {
      _locationData = locationData;
      _isLoading = !_isLoading;
    });
  }

  Future _onShare(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    debugPrint('box.size: ${box!.size.width.toDouble()}');

    try {
      final res = await Share.share(
        '${_locationData!.latitude},\n${_locationData!.longitude}',
        subject:
            'Latitude ${_locationData!.latitude}, Longitude: ${_locationData!.longitude}',
        sharePositionOrigin: Rect.fromLTWH(
          box.size.width.toDouble(),
          box.size.height.toDouble() / 1.6,
          10,
          10,
        ),
      );
    } catch (e) {
      debugPrint('e: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  void _launchMapsUrl() async {
    if (_locationData == null) return;

    Map<String, dynamic>? params = {
      'api': '1',
      'query': '${_locationData!.latitude},${_locationData!.longitude}'
    };

    final uri = Uri.https(
      'www.google.com',
      '/maps/search/',
      params,
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showErrorDialog(
          errorText:
              'Could not launch.\nCheck please if you have Google Maps Application on your device.');
      throw 'Could not launch ';
    }
  }

  void _showErrorDialog({
    String errorText = 'Could not launch',
  }) {
    showCupertinoDialog(
        context: context,
        builder: (bctx) {
          return CupertinoAlertDialog(
            title: const Text('Warning'),
            content: Text(errorText),
            actions: [
              CupertinoDialogAction(
                child: const Text('Close'),
                onPressed: () => Navigator.of(context).pop(false),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Coordinates'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _locationData == null
              ? Center(
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
                          onPressed: _getLocation,
                        ),
                      ],
                    ),
                  ),
                )
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.near_me,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: const Text(
                            'Your location is:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              'Latitude: ${_locationData!.latitude},\nLatitude: ${_locationData!.longitude}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(
                                  Icons.refresh,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                label: const Text('Retake location'),
                                onPressed: _getLocation,
                              ),
                              ElevatedButton.icon(
                                icon: const Icon(
                                  Icons.pin_drop,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                label: const Text('Open in Maps'),
                                onPressed: () => _launchMapsUrl(),
                              ),
                              ElevatedButton.icon(
                                icon: const Icon(
                                  Icons.ios_share,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                label: const Text('Share'),
                                onPressed: () => _onShare(context),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
    );
  }
}
