//
//  GMSConverter.swift
//  Harvest
//
//  Created by Letanyan Arumugam on 2018/04/21.
//  Copyright © 2018 University of Pretoria. All rights reserved.
//

import GoogleMaps

extension Array where Element == CLLocationCoordinate2D {
  func gmsPath() -> GMSPath {
    let path = GMSMutablePath()
    
    for point in self {
      path.add(point)
    }
    
    return path
  }
  
  func gmsPolyline(mapView: GMSMapView, color: UIColor = .red, width: CGFloat = 3.0) -> GMSPolyline {
    let result = GMSPolyline(path: gmsPath())
    result.strokeColor = color
    result.strokeWidth = width
    result.map = mapView
    return result
  }
  
  func gmsPolygon(mapView: GMSMapView, color: UIColor, width: CGFloat = 3.0) -> GMSPolygon {
    let result = GMSPolygon(path: gmsPath())
    result.fillColor = color.withAlphaComponent(0.25)
    result.strokeColor = color.withAlphaComponent(0.75)
    result.strokeWidth = width
    result.map = mapView
    return result
  }
  
  func gmsPolygonMarkers(mapView: GMSMapView) -> [GMSMarker] {
    let result = map(GMSMarker.init)
    result.forEach { $0.map = mapView }
    return result
  }
}

extension Dictionary where Key == Worker, Value == [CollectionPoint] {
  func gmsMarkers(mapView: GMSMapView) -> [GMSMarker] {
    var result: [GMSMarker] = []
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    for (key, value) in self {
      for (i, point) in value.enumerated() {
        let marker = GMSMarker(position: point.location)
        marker.title = key.description
          + " - "
          + formatter.string(from: point.date)
          + " (\(i + 1) / \(value.count))"
        marker.map = mapView
        result.append(marker)
      }
    }
    return result
  }
}

extension GMSMapViewType {
  var title: String {
    switch self {
    case .normal: return "Normal"
    case .hybrid: return "Hybrid"
    case .satellite: return "Satellite"
    case .terrain: return "Terrain"
    case .none: return "None"
    }
  }
}
