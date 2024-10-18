//
//  ApplyCoupon.swift
//  rider
//
//  Created by Manly Man on 11/26/19.
//  Copyright © 2019 minimal. All rights reserved.
//

import UIKit
import MapKit

class ApplyCoupon: SocketRequest {
    typealias ResponseType = ApplyCouponResult
    var params: [Any]?
    
    init(code: String) {
        self.params = [code]
    }
}

public struct ApplyCouponResult: Codable {
    var costAfterCoupon: Double
}



//class CalculateFareAfterCoupon: SocketRequest {
//    typealias ResponseType = CalculateFareAfterCouponResult
//    var params: [Any]?
//    
//    init(code: String, pointsList: [CLLocationCoordinate2D]) {
//        
//        self.params = [code,pointsList.map() { loc in
//            return [
//                "x": loc.longitude,
//                "y": loc.latitude
//            ]
//        }]
//        
//    
//    
//    
////        let dto = CalculateFareAfterCouponDTO(code: code, pointsList: pointsList)
////        let dic = try! dto.asDictionary()
////       
//        print(self.params! )
////        self.params = [dic]
//    }
//    
//    
//}



