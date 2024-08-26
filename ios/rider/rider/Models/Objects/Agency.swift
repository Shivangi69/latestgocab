//
//  Agency.swift
//  driver

//
//  Created by Admin on 28/06/24.
//  Copyright © 2024 minimal. All rights reserved.
//

import Foundation
public final class Agency: Codable {

     public var id: Int?
      public var agency_name: String?
      public var registered_name: String?
      public var logo_url: String?
      public var registration_year: String?
      public var registration_authority_url: String?
      public var insurance_url: String?
      public var license_url: String?
      public var address: String?
      public var city: String?
      public var pincode: String?
      public var latitude: String?
      public var longtitude: String?
      public var fullname: String?
      public var email: String?
      public var phone: String?
      public var last_updated_by: String?
      public var isActive: Bool?
      public var isEmailVerified: Bool?
      public var isPhoneVerified: Bool?
      public var isBlocked: Bool?
      public var blocked_at: String?
      public var registered_at: String?
      public var working_hours: String?
      public var total_drivers: Int?
      public var total_vehicles: Int?
      public var affiliations_with_taxi_association: String?
      public var password: String?
      public var created_at: String?
      public var updated_at: String?
    
    
}
