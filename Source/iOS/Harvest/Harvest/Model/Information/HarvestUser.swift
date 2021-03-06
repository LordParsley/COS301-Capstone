//
//  HarvestUser.swift
//  Harvest
//
//  Created by Letanyan Arumugam on 2018/04/24.
//  Copyright © 2018 University of Pretoria. All rights reserved.
//

import FirebaseAuth

public final class HarvestUser {
  var workingForID: [(uid: String, wid: String)]
  var selectedWorkingForID: (uid: String, wid: String)?
  var accountIdentifier: String
  var firstname: String
  var lastname: String
  var uid: String
  var organisationName: String
  var temporary: HarvestUser?
  
  var displayName: String {
    return firstname + " " + lastname
  }
  
  init() {
    workingForID = []
    selectedWorkingForID = nil
    accountIdentifier = ""
    firstname = ""
    lastname = ""
    uid = ""
    organisationName = ""
  }
  
  init(json: [String: Any]) {
    uid = json["uid"] as? String ?? ""
    firstname = json["firstname"] as? String ?? ""
    lastname = json["lastname"] as? String ?? ""
    accountIdentifier = json["email"] as? String ?? ""
    let defaultFarmName = accountIdentifier
    organisationName = json["organization"] as? String ?? defaultFarmName
    workingForID = []
    selectedWorkingForID = nil
  }
  
  func json() -> [String: Any] {
    return [
      "firstname": firstname,
      "lastname": lastname,
      "organization": organisationName,
      "email": accountIdentifier,
      "uid": uid
    ]
  }
  
  func setUser(
    _ user: User,
    _ password: String?,
    _ completion: @escaping ([(uid: String, wid: String)]?, Bool) -> Void
  ) {
    if let password = password {
      UserDefaults.standard.set(password: password)
    }
    UserDefaults.standard.set(username: accountIdentifier)
    
    accountIdentifier = user.email ?? user.phoneNumber ?? ""
    if HarvestUser.current.isFarmer {
      uid = user.uid
      UserDefaults.standard.set(uid: uid)
    }
    
    HarvestDB.getWorkingFor(completion: { ids in
      HarvestUser.current.workingForID = ids
      
      HarvestDB.getHarvestUser { (user) in
        guard let user = user else {
          completion(ids, true)
          return
        }
        
        HarvestUser.current.firstname = user.firstname
        HarvestUser.current.lastname = user.lastname
        HarvestUser.current.organisationName = user.organisationName
        StatStore.shared.updateStore()
        completion(nil, true)
      }
    })
  }
  
  func reset() {
    UserDefaults.standard.set(username: nil)
    UserDefaults.standard.set(password: nil)
    UserDefaults.standard.set(uid: nil, wid: nil)
    
    HarvestUser.current.firstname = ""
    HarvestUser.current.lastname = ""
    HarvestUser.current.accountIdentifier = ""
    HarvestUser.current.organisationName = ""
    HarvestUser.current.uid = ""
    HarvestUser.current.workingForID = []
    HarvestUser.current.selectedWorkingForID = nil
  }
  
  var isFarmer: Bool {
    return (Auth.auth().currentUser?.phoneNumber ?? "") == ""
  }
  
  static var current = HarvestUser()
}

public extension UserDefaults {
  var uid: String {
    return HarvestUser.current.accountIdentifier
  }
  
  public func set(username: String?) {
    guard let u = username else {
      removeObject(forKey: "username")
      return
    }
    set(u, forKey: "username")
  }
  
  public func getUsername() -> String? {
    return string(forKey: "username")
  }
  
  public func set(password: String?) {
    guard let p = password else {
      removeObject(forKey: "password")
      return
    }
    
    set(p, forKey: "password")
  }
  
  public func getPassword() -> String? {
    return string(forKey: "password")
  }
  
  public func set(verificationID: String?) {
    guard let v = verificationID else {
      removeObject(forKey: "verificationID")
      return
    }
    
    set(v, forKey: "verificationID")
  }
  
  public func getVerificationID() -> String? {
    return string(forKey: "verificationID")
  }
  
  public func set(uid: String?) {
    if let u = uid {
      set(u, forKey: "uid")
    } else {
      removeObject(forKey: "uid")
    }
  }
  
  public func set(wid: String?) {
    if let w = wid {
      set(w, forKey: "wid")
    } else {
      removeObject(forKey: "wid")
    }
  }
  
  public func set(uid: String?, wid: String?) {
    set(uid: uid)
    set(wid: wid)
  }
  
  public func getUID() -> String? {
    return string(forKey: "uid")
  }
  
  public func getWID() -> String? {
    return string(forKey: "wid")
  }
  
  public func getUWID() -> (uid: String?, wid: String?) {
    return (getUID(), getWID())
  }
}
