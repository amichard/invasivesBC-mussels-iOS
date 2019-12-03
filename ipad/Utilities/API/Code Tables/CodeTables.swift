//
//  CodeTables.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-26.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Reachability

public enum CodeTableType {
    case observers
    case otherObservations
    case stations
    case watercraftList
    case waterBodies
    case cities
    case provinces
}

class CodeTables {
    
    static let shared = CodeTables()
    private init() {}
    
    private let waterBodyAPI: WaterBodyAPI =  WaterBodyAPI.api()
    private let codesAPI: CodesAPI = CodesAPI.api()
    
    var promise: Promise<RemoteResponse>?
    
    public func fetchCodes(completion: @escaping(_ success: Bool) -> Void, status: @escaping(_ newStatus: String) -> Void) {
        status("Fetching code tables")
        self.fetchAndStoreCodes { (codes) in
            if codes.count < 0 { return completion(false) }
            status("Loading Waterbodies")
            self.fetchAndStoreWaterBodies(completion: { (waterBodies) in
                if waterBodies.count < 0 { return completion(false) }
                status("Wrapping up")
                let provinces = waterBodies.map{$0.abbrev}.uniques.sorted{$0.lowercased() < $1.lowercased()}
                let cities = waterBodies.map{$0.closest}.uniques.sorted{$0.lowercased() < $1.lowercased()}
                let waters = waterBodies.map{$0.name}.uniques.sorted{$0.lowercased() < $1.lowercased()}
                
                let provincesTable = CodeTableModel()
                provincesTable.type = "provinces"
                for province in provinces {
                    provincesTable.items.append(province)
                }
                RealmRequests.saveObject(object: provincesTable)
                
                let citiesTable = CodeTableModel()
                citiesTable.type = "cities"
                for city in cities {
                    citiesTable.items.append(city)
                }
                RealmRequests.saveObject(object: citiesTable)
                
                let watersTable = CodeTableModel()
                watersTable.type = "waterBodies"
                for city in waters {
                    watersTable.items.append(city)
                }
                RealmRequests.saveObject(object: watersTable)
                
                return completion(true)
            }) { (statusUpdate) in
               status("Storing Waterbodies: \(statusUpdate)")
            }
        }
    }
    
    private func fetchAndStoreCodes(completion: @escaping (_ objects: [CodeTableModel]) -> Void) {
        do {
            let reacahbility = try Reachability()
            if (reacahbility.connection == .unavailable) {
                return completion([])
            }
        } catch let error as NSError {
            print("** Reachability ERROR")
            print(error)
        }
        
        self.promise = codesAPI.get()
        self.promise?.then({ (resp, _) in
            guard let data: [String: Any] = resp as? [String: Any] else {
                print("FAIL: Wrong resp")
                return completion([])
            }
            Storage.shared.deleteCodeTables()
            DispatchQueue.global(qos: .background).async {
                var codeTables: [CodeTableModel] = []
                for (type, items) in data {
                    guard let items = items as? [String] else {
                        continue
                    }
                    let model = CodeTableModel()
                    model.type = type
                    for item in items {
                        model.items.append(item)
                    }
                    RealmRequests.saveObject(object: model)
                    codeTables.append(model)
                }
                return completion(codeTables)
            }
        })
    }
    
    private func fetchAndStoreWaterBodies(completion: @escaping (_ objects: [WaterBodyTableModel]) -> Void, status: @escaping(_ newStatus: String) -> Void) {
        Storage.shared.saveWaterBodiesFromJSON(status: status)
        return completion(Storage.shared.fullWaterBodyTables())
        do {
            let reacahbility = try Reachability()
            if (reacahbility.connection == .unavailable) {
                return completion([])
            }
        } catch  let error as NSError {
            print("** Reachability ERROR")
            print(error)
            return completion([])
        }
        
        self.promise = waterBodyAPI.get()
        self.promise?.then({ (resp, _) in
            guard let data: [[String : Any]] = resp as? [[String: Any]] else {
                print("FAIL: Wrong resp")
                return completion([])
            }
            guard let _: [String: Any] = data.first else {
                print("FAIL: No first item")
                return completion([])
            }
            Storage.shared.deteleFullWaterBodyTables()
            DispatchQueue.global(qos: .background).async {
                var waterbodies: [WaterBodyTableModel] = []
                for item in data {
                    let model = WaterBodyTableModel()
                    model.name = item["name"] as? String ?? ""
                    model.water_body_id = item["water_body_id"] as? Int ?? 0
                    model.latitude = item["latitude"] as? Double ?? 0
                    model.longitude = item["longitude"] as? Double ?? 0
                    model.abbrev = item["abbrev"] as? String ?? ""
                    model.closest = item["closest"] as? String ?? ""
                    RealmRequests.saveObject(object: model)
                    waterbodies.append(model)
                }
                return completion(waterbodies)
            }
        })
    }
    
}
