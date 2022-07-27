import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';

import './widgets/no_location_data.dart';
import './widgets/location_tile.dart';
import './widgets/custom_icon_button.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({Key? key}) : super(key: key);

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  LocationData? _locationData;
  Location location = Location();

  bool _isLoading = false;

  void _getLocation() async {
    setState(() {
      _isLoading = !_isLoading;
    });

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

  Future _onShare() async {
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
              ? NoLocationData(handleTapGetLocation: _getLocation)
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        LocationTile(locationData: _locationData),
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              CustomIconButton(
                                title: 'Retake location',
                                handleTap: _getLocation,
                                iconName: Icons.refresh,
                              ),
                              CustomIconButton(
                                title: 'Open in Maps',
                                handleTap: _launchMapsUrl,
                                iconName: Icons.pin_drop,
                              ),
                              CustomIconButton(
                                title: 'Share',
                                handleTap: _onShare,
                                iconName: Icons.ios_share,
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
