import 'dart:async';

import 'package:eClassify/features/location/screens/helpers/location_dialog.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/features/location/screens/widgets/location_map/location_map_controller.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/utils/map_style.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationMapWidget extends StatefulWidget {
  const LocationMapWidget({
    required this.controller,
    this.showCircleArea = true,
    this.showMarker = true,
    this.showMyLocationButton = true,
    this.interactive = true,
    super.key,
  });

  final LocationMapController controller;
  final bool showCircleArea;
  final bool showMarker;
  final bool showMyLocationButton;
  final bool interactive;

  @override
  State<LocationMapWidget> createState() => _LocationMapWidgetState();
}

class _LocationMapWidgetState extends State<LocationMapWidget> {
  Timer? _tapCooldown;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.controller.init(),
    );
    _tapCooldown = Timer(const Duration(seconds: 3), () {
      _tapCooldown = null;
    });
  }

  @override
  void dispose() {
    _tapCooldown?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListenableBuilder(
          listenable: widget.controller,
          builder: (context, child) {
            if (!widget.controller.isReady) {
              return Center(child: LoadingIndicator());
            }

            final mapData = widget.controller.data;

            return GoogleMap(
              initialCameraPosition: mapData.cameraPosition,
              onMapCreated: widget.controller.onMapCreated,
              circles: {
                if (widget.showCircleArea)
                  mapData.circle.copyWith(
                    fillColorParam: context.colorScheme.primary.withValues(
                      alpha: .5,
                    ),
                    strokeColorParam: context.colorScheme.primary,
                  ),
              },
              markers: widget.showMarker ? {mapData.marker} : {},
              onTap: widget.interactive ? widget.controller.onTap : null,
              zoomControlsEnabled: false,
              zoomGesturesEnabled: widget.interactive,
              compassEnabled: false,
              indoorViewEnabled: true,
              mapToolbarEnabled: false,
              myLocationButtonEnabled: false,
              myLocationEnabled: false,
              style: MapStyle.style,
            );
          },
        ),
        if (widget.showMyLocationButton)
          PositionedDirectional(
            end: 15,
            bottom: 15,
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: context.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                fixedSize: Size.square(40), // Size of a mini FAB
              ),
              onPressed: () async {
                if (_tapCooldown?.isActive ?? false) return;

                widget.controller.getLocation(
                  onPermissionDenied: (permission, serviceEnabled) =>
                      LocationDialog.show(
                        context,
                        permission: permission,
                        isLocationServiceEnabled: serviceEnabled,
                      ),
                );

                _tapCooldown = Timer(const Duration(seconds: 3), () {
                  _tapCooldown = null;
                });
              },
              icon: Icon(AppIcons.gpsFixFill),
            ),
          ),
      ],
    );
  }
}
