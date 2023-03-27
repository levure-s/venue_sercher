import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_places_flutter/model/place_details.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:venue_sercher/const.dart';
import 'package:venue_sercher/venue.dart';

class SerchVenuePage extends StatefulWidget {
  const SerchVenuePage({super.key});

  @override
  State<SerchVenuePage> createState() => _SerchVenuePageState();
}

class _SerchVenuePageState extends State<SerchVenuePage> {
  final _apiKey = Const.apiKey;
  Venue? venue;
  Uri? mapUrl;

  @override
  void initState() {
    super.initState();

    _serchLocation();
  }

  @override
  Widget build(BuildContext context) {
    if (venue == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('ライブ会場'),
      ),
      body: Column(children: [
        Image.network(
          venue!.photo!,
          width: double.infinity,
          fit: BoxFit.contain,
        ),
        SizedBox(
          height: 24,
        ),
        Text(
          venue!.name!,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        SizedBox(
          height: 24,
        ),
        ElevatedButton(
            onPressed: () async {
              await launchUrl(mapUrl!);
            },
            child: const Text('Google Mapへ'))
      ]),
    );
  }

  Future _serchLocation() async {
    final position = await _determinePosition();
    final latitude = position.latitude;
    final longitude = position.longitude;

    final place = FlutterGooglePlacesSdk(_apiKey);
    final predictions = await place.findAutocompletePredictions('自由学園明日館');
    final placeId = predictions.predictions.first.placeId;
    List<PlaceField> _placeFiields = [
      PlaceField.Name,
      PlaceField.PhotoMetadatas,
      PlaceField.WebsiteUri,
    ];
    final result = await place.fetchPlace(placeId, fields: _placeFiields);

    String? urlString;

    if (Platform.isAndroid) {
      final name = Uri.encodeFull(result.place!.name!);
      urlString =
          'https://www.google.com/maps/dir/?api=1&destination=$name&destination_place_id=$placeId&origin=$latitude,$longitude';
    } else if (Platform.isIOS) {
      final name = Uri.encodeFull(result.place!.name!);
      urlString = 'comgooglemaps://?saddr=$latitude,$longitude&daddr=$name';
    }
    mapUrl = Uri.parse(urlString!);

    if (result.place != null) {
      final photoReference = result.place?.photoMetadatas?.first.photoReference;
      final photo =
          'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=$photoReference&key=$_apiKey';

      setState(() {
        venue = Venue(result.place?.name, photo, result.place?.websiteUri);
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('設定にて位置情報を許可してください');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('設定にて位置情報を許可してください');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('設定にて位置情報を許可してください');
    }

    return await Geolocator.getCurrentPosition();
  }
}
