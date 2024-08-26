////
////  Finish.swift
////  driver
////
////  Created by Manly Man on 11/23/19.
////  Copyright © 2019 minimal. All rights reserved.
////
//
//import Foundation
//import CoreLocation
//
//
//class Finish: SocketRequest {
//    typealias ResponseType = FinishResult
//
//    var params: [Any]?
//
//  //  required public init(confirmationCode: Int?, distance: Int, log: String,waypoints: [CLLocationCoordinate2D])
////    {
//////        let waypointsString = waypoints.map {"{" + "\($0.latitude),\($0.longitude)" }.joined(separator: ";")
//////        print("waypointsString",waypointsString)
//////        self.params = [[
//////            "confirmationCode": confirmationCode ?? 0,
//////            "distance": distance,
//////            "log": log,
//////            "waypoints": waypointsString
//////        ]]
////
////    }
//
//    required public init(confirmationCode: Int?, distance: Int, log: String, waypoints: [CLLocationCoordinate2D]) {
//        print("waypoints", waypoints)
//
//        // Convert CLLocationCoordinate2D to dictionaries
//        let waypointDicts = waypoints.map { waypoint in
//            return ["latitude": waypoint.latitude, "longitude": waypoint.longitude]
//        }
//
//        self.params = [[
//            "confirmationCode": confirmationCode ?? 0,
//            "distance": distance,
//            "log": log,
//            "waypoints": waypointDicts
//        ]]
//    }
//}
//
//struct FinishResult: Codable {
//    public var status: Bool
//}
//
//class FinishService: Codable {
//    public var log: String?
//    public var cost: Double?
//    public var distance: Int?
//    public var confirmationCode: Int?
//    public var  waypoints:[CLLocationCoordinate2D]?
//
//    public init(cost: Double, log: String? = "", distance: Int, confirmationCode: Int,waypoints: [CLLocationCoordinate2D]) {
//        self.log = log
//        self.cost = cost
//        self.confirmationCode = confirmationCode
//        self.distance = distance
//        self.waypoints = waypoints
//
//    }
//
//    public init(cost: Double, log: String? = "", distance: Int,waypoints: [CLLocationCoordinate2D]) {
//        self.log = log
//        self.cost = cost
//        self.distance = distance
//        self.waypoints = waypoints
//
//    }
//}
import Foundation
import CoreLocation

import Foundation
import CoreLocation

class Finish: SocketRequest {
    typealias ResponseType = FinishResult
    
    var params: [Any]?
    
    required public init(confirmationCode: Int?, distance: Int, log: String, waypoints: [CLLocationCoordinate2D]) {
        print("waypoints", waypoints)

        // Convert CLLocationCoordinate2D to dictionaries with "x" and "y" keys
        let waypointDicts = waypoints.map { waypoint in
            return ["x": waypoint.longitude, "y": waypoint.latitude]
        }

        self.params = [[
            "confirmationCode": confirmationCode ?? 0,
            "distance": distance,
            "log": log,
            "waypoints": waypointDicts
        ]]
        print("params", params!)

    }
}

struct FinishResult: Codable {
    public var status: Bool
}

class FinishService: Codable {
    public var log: String?
    public var cost: Double?
    public var distance: Int?
    public var confirmationCode: Int?
    public var waypoints: [[String: Double]]?

    public init(cost: Double, log: String? = "", distance: Int, confirmationCode: Int, waypoints: [CLLocationCoordinate2D]) {
        self.log = log
        self.cost = cost
        self.confirmationCode = confirmationCode
        self.distance = distance
        self.waypoints = waypoints.map { waypoint in
            return ["x": waypoint.longitude, "y": waypoint.latitude]
        }
    }
    
    public init(cost: Double, log: String? = "", distance: Int, waypoints: [CLLocationCoordinate2D]) {
        self.log = log
        self.cost = cost
        self.distance = distance
        self.waypoints = waypoints.map { waypoint in
            return ["x": waypoint.longitude, "y": waypoint.latitude]
        }
    }
}
