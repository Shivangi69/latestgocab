//
//  CalculateFare.swift
//  rider
//
//  Created by Manly Man on 11/26/19.
//  Copyright © 2019 minimal. All rights reserved.
//

import UIKit
import MapKit

class CalculateFare: SocketRequest {
    typealias ResponseType = CalculateFareResult
    var params: [Any]?
    
    init(locations: [CLLocationCoordinate2D]) {
        self.params = [locations.map() { loc in
            return [
                "x": loc.longitude,
                "y": loc.latitude
            ]
        }]
    }

}

struct CalculateFareResult: Codable {
    var categories: [ServiceCategory]
    var distance: Int
    var duration: Int
    var currency: String
}

class CalculateFareAfterCoupon: SocketRequest {
    
    typealias ResponseType = CalculateFareAfterCouponResult
    var params: [Any]?

    init(code: String, locations: [CLLocationCoordinate2D]) {
        let locationsArray = locations.map { loc in
            return [
                "x": loc.longitude,
                "y": loc.latitude
            ]
        }
        
        // Construct the parameters like in Android
        let requestObj: [String: Any] = [
            "code": code,
            "locations": locationsArray
        ]
        
        self.params = [requestObj]
        
        print(self.params as Any)
    }
}




struct CalculateFareAfterCouponResult: Codable {
    var categories: [ServiceCategory]
    var distance: Int
    var duration: Int
    var currency: String
}
