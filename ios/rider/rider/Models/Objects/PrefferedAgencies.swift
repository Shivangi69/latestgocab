//
//  PrefferedAgencies.swift
//  rider
//
//  Created by Admin on 26/09/24.
//  Copyright © 2024 minimal. All rights reserved.
//

import Foundation

// Model for the entire API response
struct PreferredAgencyResponse: Codable {
    let success: Bool
    let message: String
    let data: AgencyData
}

struct AgencyData: Codable {
    let preferredAgencies: [PreferredAgency]
}

struct PreferredAgency: Codable {
    let agencyId: Int
    let agencyName: String
    let priority: Int = 0
    
//    let id: Int
//    let agencyName: String
//    let status: String
//    let approvalStatus: String
//    let registeredName: String
//    let logoUrl: String?
//    let registrationYear: String
//    let registrationAuthorityUrl: String?
//    let insuranceUrl: String?
//    let licenseUrl: String?
//    let address: String
//    let city: String?
//    let pincode: String?
//    let latitude: String?
//    let longtitude: String?
//    let fullname: String
//    let email: String
//    let phone: String
//    let lastUpdatedBy: String?
//    let isEmailVerified: Bool
//    let isPhoneVerified: Bool
//    let registeredAt: String?
//    let workingHours: String?
//    let totalDrivers: Int?
//    let totalVehicles: Int?
//    let affiliationsWithTaxiAssociation: String?
//    let password: String?
//    let accountNumber: String?
//    let bankName: String?
//    let bankRoutingNumber: String?
//    let bankSwift: String?
//    let createdAt: String
//    let updatedAt: String

    // Custom coding keys to map snake_case in JSON to camelCase in Swift
    enum CodingKeys: String, CodingKey {
        
        case agencyId
        case agencyName = "agencyName"
        case priority
//        case id
//        case agencyName = "agency_name"
//        case status
//        case approvalStatus = "approval_status"
//        case registeredName = "registered_name"
//        case logoUrl = "logo_url"
//        case registrationYear = "registration_year"
//        case registrationAuthorityUrl = "registration_authority_url"
//        case insuranceUrl = "insurance_url"
//        case licenseUrl = "license_url"
//        case address
//        case city
//        case pincode
//        case latitude
//        case longtitude
//        case fullname
//        case email
//        case phone
//        case lastUpdatedBy = "last_updated_by"
//        case isEmailVerified = "isEmailVerified"
//        case isPhoneVerified = "isPhoneVerified"
//        case registeredAt = "registered_at"
//        case workingHours = "working_hours"
//        case totalDrivers = "total_drivers"
//        case totalVehicles = "total_vehicles"
//        case affiliationsWithTaxiAssociation = "affiliations_with_taxi_association"
//        case password
//        case accountNumber
//        case bankName
//        case bankRoutingNumber
//        case bankSwift
//        case createdAt = "created_at"
//        case updatedAt = "updated_at"
    }
}
