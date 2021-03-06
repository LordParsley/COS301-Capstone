//
//  Session.swift
//  Harvest
//
//  Created by Letanyan Arumugam on 2018/04/20.
//  Copyright © 2018 University of Pretoria. All rights reserved.
//

import CoreLocation

extension Dictionary where Key == String, Value == Any {
  func track() -> [CLLocationCoordinate2D] {
    guard let _track = self["track"] as? [Any] else {
      return []
    }
    
    var result = [CLLocationCoordinate2D]()
    
    for _coord in _track {
      guard let coord = _coord as? [String: Any] else {
        continue
      }
      
      guard let lat = coord["lat"] as? Double else {
        continue
      }
      
      guard let lng = coord["lng"] as? Double else {
        continue
      }
      
      result.append(CLLocationCoordinate2D(latitude: lat, longitude: lng))
    }
    
    return result
  }
  
  func collections() -> [Worker: [CollectionPoint]] {
    guard let _collections = self["collections"] as? [String: Any] else {
      return [:]
    }
    var result: [Worker: [CollectionPoint]] = [:]
    
    for (key, _collectionPoints) in _collections {
      guard let collectionPoints = _collectionPoints as? [Any] else {
        continue
      }
      
      var colps = [CollectionPoint]()
      for _point in collectionPoints {
        guard let point = _point as? [String: Any] else {
          continue
        }
        
        guard let coord = point["coord"] as? [String: Any] else {
          continue
        }
        
        guard let lat = coord["lat"] as? Double else {
          continue
        }
        
        guard let lng = coord["lng"] as? Double else {
          continue
        }
        
        guard let _date = point["date"] as? String else {
          continue
        }
        
        let loc = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let date = DateFormatter.rfc2822Date(from: _date)
        
        colps.append(CollectionPoint(location: loc, date: date, selectedOrchard: nil))
      }
      
      if let worker = Entities.shared.workers.first(where: { (_, value) -> Bool in
        value.id == key
      })?.value {
        result[worker, default: []] = colps
      }
    }
    return result
  }
}

public final class Session {
  var endDate: Date
  var startDate: Date
  
  var foreman: Worker
  
  var track: [CLLocationCoordinate2D]
  var collections: [Worker: [CollectionPoint]]
  
  var id: String
  var tempory: Session?
  
  init(json: [String: Any], id: String) {
    self.id = id
    
    startDate = DateFormatter.rfc2822Date(from: json["start_date"] as? String ?? "")
    endDate = DateFormatter.rfc2822Date(from: json["end_date"] as? String ?? "")
    
    let wid = json["wid"] as? String ?? ""
    foreman = Entities.shared.worker(withId: wid) ?? Worker(json: ["name": "Farm Owner"], id: HarvestUser.current.uid)
    
    track = json.track()
    collections = json.collections()
    
    tempory = nil
  }
  
  func json() -> [String: [String: Any]] {
    return [id: [
      "start_date": DateFormatter.rfc2822String(from: startDate),
      "end_date": DateFormatter.rfc2822String(from: endDate),
      "wid": foreman.id,
      "track": track.firbaseCoordRepresentation(),
      "collections": collections.firebaseSessionRepresentation()
    ]]
  }
  
  func search(for text: String) -> [(String, String)] {
    var result = [(String, String)]()
    
    let text = text.lowercased()
    
    let formatter = DateFormatter()
    formatter.dateStyle = .full
    formatter.timeStyle = .full
    
    let personProps = ["Name", "ID Number", "Phone Number"]
    let orchardProps = ["Name", "Crop", "Cultivar", "Irrigation Kind"]
    
    for (prop, reason) in foreman.search(for: text) {
      if personProps.contains(prop) {
        result.append(("Foreman " + prop, reason))
      }
    }
    
    for (w, points) in collections {
      for (prop, reason) in w.search(for: text) {
        if personProps.contains(prop) {
          result.append(("Worker " + prop, reason))
        }
      }
      
      var orchards = [Orchard]()
      for point in points {
        let allOrchards = point.orchards
        if !orchards.contains(where: { o in allOrchards.contains { $0.id == o.id } }) {
          orchards.append(contentsOf: allOrchards)
          for orchard in orchards {
            for (prop, reason) in orchard.search(for: text) {
              if orchardProps.contains(prop) {
                result.append(("Orchard " + prop, reason))
              }
            }
          }
        }
      }
    }
    
    return result
  }
  
  enum CollectionBagSummary {
    case mass(Double)
    case count(Int)
  }
  
  func collectionBagSummary() -> CollectionBagSummary {
    let points = collections.flatMap { $0.value }
    var totalMass = 0.0
    var orch: Orchard?
    for point in points {
      if point.orchards.count != 1 {
        return .count(points.count)
      } else if let orchard = point.orchards.first, let mass = orchard.bagMass {
        if let orch = orch {
          if orch == orchard {
            totalMass += mass
          } else {
            return .count(points.count)
          }
        } else {
          orch = orchard
          totalMass += mass
        }
      } else {
        return .count(points.count)
      }
    }
    return .mass(totalMass)
  }
}

extension Session: Hashable {
  public static func == (lhs: Session, rhs: Session) -> Bool {
    return lhs.id == rhs.id
      && lhs.startDate == rhs.startDate
      && lhs.endDate == rhs.endDate
      && lhs.foreman == rhs.foreman
      && lhs.track == rhs.track
  }
  
  public var hashValue: Int {
    return id.hashValue
  }
}

extension Session: CustomStringConvertible {
  public var description: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .medium
    
    return formatter.string(from: startDate) + " ・ " + foreman.description
  }
  
  var key: String {
    return startDate.timeIntervalSince1970.description + id
  }
}

extension SortedDictionary where Key == Date, Value == SortedSet<Session> {
  func contains(session: Session) -> Bool {
    return contains { _, list in
      list.contains { $0.id == session.id }
    }
  }
  
  mutating func accumulateByDay(with sessions: [Session]) {
    for session in sessions where !contains(session: session) {
      var inserted = false
      for (key, _) in self {
        if key.sameDay(as: session.startDate) {
          self[key]!.insert(unique: session)
          inserted = true
          break
        }
      }
      if !inserted {
        self[session.startDate] = SortedSet<Session> { $0.startDate > $1.startDate }
        self[session.startDate]!.insert(unique: session)
      }
    }
  }
}

extension SortedDictionary where Value == SortedSet<Session> {
  func search(for text: String) -> SortedDictionary<String, SortedArray<SearchPair<Session>>> {
    var result = SortedDictionary<String, SortedArray<SearchPair<Session>>>()
    for (_, sessions) in self {
      for session in sessions {
        let props = session.search(for: text)
        
        for (prop, reason) in props {
          if result[prop] == nil {
            result[prop] = SortedArray<SearchPair<Session>>([]) { $0.item.startDate > $1.item.startDate }
          }
          let pair = SearchPair(session, reason)
          if !(result[prop]?.contains(pair) ?? true) {
            result[prop]?.insert(pair)
          }
        }
      }
    }
    return result
  }
}
