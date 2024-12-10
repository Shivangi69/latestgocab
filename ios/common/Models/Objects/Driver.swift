//
//  Driver.swift
//
//  Copyright (c) Minimalistic Apps. All rights reserved.
//

import Foundation
import MessageKit

public final class Driver: Codable, SenderType {
    public var senderId: String { get {
            return "d\(String(self.id!))"
        }
    }
    
    public var displayName: String { get {
         return "\(self.firstName ?? "") \(self.lastName ?? "")"
        }
    }
    
    
    // MARK: Properties
    public var id: Int?
    public var firstName: String?
    public var lastName: String?
    public var certificateNumber: String?
    public var mobileNumber: Int64?
    public var email: String?
    public var balance: Wallet?
    public var car: Car?
    public var carColor: String?
    public var carProductionYear: Int?
    public var carPlate: String?
    public var carMedia: Media?
    public var status: Status?
    public var rating: Double?
    public var reviewCount: Int?
    public var media: Media?
    public var gender: String?
    public var accountNumber: String?
    public var bankName: String?
    public var bankRoutingNumber: String?
    public var bankSwift: String?
    public var address: String?
    public var infoChanged: Int?
    public var documentsNote: String?
    public var services: [Service]?
    public var documents: [Media]?
    

   
         public var agency: Agency?
         public var assignedVehicle: AssignedVehicle?
         public var driverMedia: [DriverMedia]?
         public var vehicle_images: [VehicleImage]?
         public var vehicle_documents: [VehicleDocument]?
         public var authority: String?
         public var biography: String?
         public var bloodgroup: String?
         public var character_certificate_expired_at: String?
         public var character_certificate_issued_at: String?
         public var created_at: String?
         public var dob: String?
         public var insurance_expired_at: String?
         public var insurance_issued_at: String?
         public var isDisabled: Bool?
         public var lastSeenTimestamp: Int?
         public var license_expiry: String?
         public var license_number: String?
         public var notificationPlayerId: String?
         public var paymentPreference: String?
         public var reference1: String?
         public var reference2: String?
         public var registrationTimestamp: String?
         public var skills_or_certification: String?
         public var updated_at: String?
        
    
    
    
    
    public enum Status: String, Codable {
        case Offline = "offline"
        case Online = "online"
        case InService = "in service"
        case Blocked = "blocked"
        case Disabled = "disabled"
        case PendingApproval = "pending appro public var"
        case WaitingDocuments = "waiting documents"
        case SoftReject = "soft reject"
        case HardReject = "hard rejet"
    }
}

//public final class Agency: Codable {
//
//     public var id: Int?
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
