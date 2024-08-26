//
//  Travel.swift
//
//  Copyright (c) Minimalistic Apps. All rights reserved.
//

import Foundation
import CoreLocation

public final class Request: Codable, Hashable {
    public static func == (lhs: Request, rhs: Request) -> Bool {
        return lhs.id == rhs.id
    }
    
    public static var shared = Request()
    
    // MARK: Properties
    public var addresses: [String] = []
    public var points: [CLLocationCoordinate2D] = []
    public var durationReal: Int?
    public var durationBest: Int?
    public var distanceReal: Int?
    public var requestTimestamp: Double?
    public var expectedTimestamp: Double?
    public var currency: String?
    public var startTimestamp: Double?
    public var etaPickup: Double?
    public var finishTimestamp: Double?
    public var driver: Driver?
    public var coupon: Coupon?
    public var rating: Double?
    public var costBest: Double?
    public var costAfterCoupon: Double?
    public var costAfterVAT: Double?
    public var providerShare: Double?
    public var rider: Rider?
    public var distanceBest: Int?
    public var status: Status?
    public var cost: Double?
    public var id: Int?
    public var isHidden: Int?
    public var log: String?
    public var service: Service?
    public var confirmationCode: Int?
    public var imageUrl: String?

    public var  vehicle: Vehicle?
    public var  waypoints:[CLLocationCoordinate2D]?
   
    
    public enum Status: String, Codable {
        case Requested = "Requested"
        case NotFound = "NotFound"
        case NoCloseFound = "NoCloseFound"
        case Found = "Found"
        case DriverAccepted = "DriverAccepted"
        case WaitingForPrePay = "WaitingForPrePay"
        case DriverCanceled = "DriverCanceled"
        case RiderCanceled = "RiderCanceled"
        case Arrived = "Arrived"
        case Started = "Started"
        case WaitingForPostPay = "WaitingForPostPay"
        case WaitingForReview = "WaitingForReview"
        case Finished = "Finished"
        case Booked = "Booked"
        case Expired = "Expired"
        case DriverMarkedPaymentNotReceived = "DriverMarkedPaymentNotReceived"
        case PendingReview = "PendingReview"

    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}



//public final class Agency: Codable {
//
// 
//    public var id: Int?
//      public var agency_name: String?
//      public var registered_name: String?
//      public var logo_url: String?
//      public var registration_year: String?
//      public var registration_authority_url: String?
//      public var insurance_url: String?
//      public var license_url: String?
//      public var address: String?
//      public var city: String?
//      public var pincode: String?
//      public var latitude: String?
//      public var longtitude: String?
//      public var fullname: String?
//      public var email: String?
//      public var phone: String?
//      public var last_updated_by: String?
//      public var isActive: Bool?
//      public var isEmailVerified: Bool?
//      public var isPhoneVerified: Bool?
//      public var isBlocked: Bool?
//      public var blocked_at: String?
//      public var registered_at: String?
//      public var working_hours: String?
//      public var total_drivers: Int?
//      public var total_vehicles: Int?
//      public var affiliations_with_taxi_association: String?
//      public var password: String?
//      public var created_at: String?
//      public var updated_at: String?
//    
//    
//}


import Foundation
public final class AssignedVehicle: Codable {
    
    
    public var color: String?
    public var created_at: String?
    public var expiration_date: String?
    public var id: Int?
    public var identification_number: String?
    public var insurance_expire_date: String?
    public var insurance_policy_number: String?
    public var insurance_provider: String?
    public var isAssigned: Bool?
    public var license_plate_number: String?
    public var make: String?
    public var model: String?
    public var notes: String?
    public var propertiership_type: String?
    public var registration_date: String?
    public var updated_at: String?
    public var vehicle_type: String?
    
    
}
public final class DriverMedia: Codable {
    
    
    public var id: Int?
    public var url: String?
    public var mediaType: String?
    public var created_at: String?
    public var updated_at: String?
    
    
}
public final class VehicleImage: Codable {
    public var id: Int?
    public var url: String?
    public var created_at: String?
    public var updated_at: String?
    
}
public final class VehicleDocument: Codable {
    public var id: Int?
    public var url: String?
    public var created_at: String?
    public var updated_at: String?
    
    
}
public final class Vehicle: Codable {
    
    public var license_plate_number: String?
    public var make: String?
    public var model: String?
    public var vehicle_type: String?
}
