import Foundation

// Model for UserMedia
struct UserMedia: Codable {
    let id: Int?
    let title: String?
    let address: String?
    let type: String?
    let privacyLevel: String?
    let pathType: String?
    let base64: String?
}

// Model for UserResponse
struct UserResponse: Codable {
    let id: Int?
    let firstName: String?
    let lastName: String?
    let mobileNumber: Int?
    let status: String?
    let registrationTimestamp: String?
    let birthTimestamp: String?
    let email: String?
    let gender: String?
    let address: String?
    let infoChanged: Int?
    let notificationPlayerId: String?
    let rating: Int?
    let reviewCount: Int?
    let eula: String?
    let eulaAcceptedAt: String?
    let communicationPreference: String?
    let isMobileNumberVerified: Bool?
    let isEmailVerified: Bool?
    let media: UserMedia?
}

// Model for DataClass
struct DataClass: Codable {
    let user: UserResponse?
}

// Model for LoginResponse
struct LoginResponse: Codable {
    let success: Bool?
    let data: DataClass?
    let token: String?
}
