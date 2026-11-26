import 'package:flutter/material.dart';
import '../core/tokens.dart';
import '../navigation/section_registry.dart';

/// The request's current layer of travel, driving the background tint,
/// path gradient, and Pak's accent color.
enum NetLayer { browser, network, gateway, api, logic, database, response }

abstract final class NetLayers {
  static const Map<SectionId, NetLayer> _sectionLayer = {
    SectionId.browserHero: NetLayer.browser,
    SectionId.networkAbout: NetLayer.network,
    SectionId.gatewaySkills: NetLayer.gateway,
    SectionId.apiProjects: NetLayer.api,
    SectionId.logicApproach: NetLayer.logic,
    SectionId.databaseExperience: NetLayer.database,
    SectionId.responseContact: NetLayer.response,
    SectionId.teardownFooter: NetLayer.response,
  };

  static NetLayer layerFor(SectionId id) => _sectionLayer[id] ?? NetLayer.browser;

  /// browser/network -> netCyan, gateway/api/logic -> apiViolet,
  /// database -> dbAmber, response -> okGreen (verbatim PRD mapping).
  static Color accentFor(NetLayer layer) {
    switch (layer) {
      case NetLayer.browser:
      case NetLayer.network:
        return AppColors.netCyan;
      case NetLayer.gateway:
      case NetLayer.api:
      case NetLayer.logic:
        return AppColors.apiViolet;
      case NetLayer.database:
        return AppColors.dbAmber;
      case NetLayer.response:
        return AppColors.okGreen;
    }
  }
}
