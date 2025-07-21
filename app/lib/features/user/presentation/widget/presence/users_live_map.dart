import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:habitvote/features/user/application/cubits/presence_cubit.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

class UsersLiveMap extends StatelessWidget {
  const UsersLiveMap({super.key});

  @override
  Widget build1(BuildContext context) {
    return IgnorePointer(
      child:
          BlocBuilder<PresenceCubit, PresenceState>(builder: (context, state) {
        return SfMaps(
          layers: [
            MapShapeLayer(
              key: Key(state.coordinates.hashCode.toString()),
              color: Colors.grey.shade400.withAlpha(140),
              strokeWidth: 0.2,
              source: MapShapeSource.asset(
                'assets/world_map.json',
                shapeDataField: 'name',
              ),
              initialMarkersCount: state.coordinates.length,
              markerBuilder: (BuildContext context, int index) {
                return MapMarker(
                  latitude: state.coordinates[index].latitude,
                  longitude: state.coordinates[index].longitude,
                  iconColor: Colors.teal.shade600,
                  size: const Size(2, 2),
                );
              },
            )
          ],
        );
      }),
    );
  }

// https://www.perplexity.ai/search/in-futter-i-have-this-widget-a-T2jVAhVeRfiiJUaL60H9yw
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.white.withOpacity(0.0)],
          stops: const [0.0, 0.05], // Adjust the stop to control the fade speed
        ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
      },
      blendMode:
          BlendMode.dstOut, // This blend mode will fade the top of the child
      child: SvgPicture.asset(
        'assets/world.svg',
        fit: BoxFit.fill,
        colorFilter: ColorFilter.mode(
          Colors.grey.shade300.withAlpha(200),
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
