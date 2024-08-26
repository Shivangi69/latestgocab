import Foundation

public final class Service: Codable, Hashable, CustomStringConvertible {
    public static func == (lhs: Service, rhs: Service) -> Bool {
        return lhs.id == rhs.id
    }
    
    public var description: String {
        return title ?? ""
    }
    
    // MARK: Properties
    public var id: Int?
    public var title: String?
    public var baseFare: Double? // Make baseFare optional
    public var distanceFeeMode: DistanceFee = .PickupToDestination
    public var perHundredMeters: Double = 0
    public var perMinuteWait: Double = 0
    public var perMinuteDrive: Double = 0
    public var feeEstimationMode = FeeEstimationMode.Static
    public var canEnableVerificationCode: Bool = false
    public var paymentMethod: PaymentMethod = .CashCredit
    public var paymentTime: PaymentTime = .PostPay
    public var prePayPercent: Int = 0
    public var rangePlusPercent: Int = 0
    public var rangeMinusPercent: Int = 0
    public var quantityMode: QuantityMode = .Singular
    public var eachQuantityFee: Double = 0
    public var maxQuantity: Int = 0
    public var minimumFee: Double?
    public var cost: Double? = 0
    public var bookingMode: BookingMode = .OnlyNow // Default value
    public var media: Media?
    public var category: ServiceCategory?
    public var availableTimeFrom: String?
    public var availableTimeTo: String?

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public enum DistanceFee: String, Codable {
        case None = "None"
        case PickupToDestination = "PickupToDestination"
    }
    
    public enum FeeEstimationMode: String, Codable {
        case Static = "Static"
        case Dynamic = "Dynamic"
        case Ranged = "Ranged"
        case RangedStrict = "RangedStrict"
        case Disabled = "Disabled"
    }

    public enum PaymentMethod: String, Codable {
        case CashCredit = "CashCredit"
        case OnlyCredit = "OnlyCredit"
        case OnlyCash = "OnlyCash"
    }
    
    public enum BookingMode: String, Codable {
        case OnlyNow = "OnlyNow"
        case Time = "Time"
        case DateTime = "DateTime"
        case DateTimeAbosoluteHour = "DateTimeAbosoluteHour"
    }

    public enum PaymentTime: String, Codable {
        case PrePay = "PrePay"
        case PostPay = "PostPay"
    }

    public enum QuantityMode: String, Codable {
        case Singular = "Singular"
        case Multiple = "Multiple"
    }

    // Custom initializer to handle missing keys
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try? container.decode(Int.self, forKey: .id)
        self.title = try? container.decode(String.self, forKey: .title)
        self.baseFare = try? container.decode(Double.self, forKey: .baseFare)
        self.distanceFeeMode = (try? container.decode(DistanceFee.self, forKey: .distanceFeeMode)) ?? .PickupToDestination
        self.perHundredMeters = (try? container.decode(Double.self, forKey: .perHundredMeters)) ?? 0
        self.perMinuteWait = (try? container.decode(Double.self, forKey: .perMinuteWait)) ?? 0
        self.perMinuteDrive = (try? container.decode(Double.self, forKey: .perMinuteDrive)) ?? 0
        self.feeEstimationMode = (try? container.decode(FeeEstimationMode.self, forKey: .feeEstimationMode)) ?? .Static
        self.canEnableVerificationCode = (try? container.decode(Bool.self, forKey: .canEnableVerificationCode)) ?? false
        self.paymentMethod = (try? container.decode(PaymentMethod.self, forKey: .paymentMethod)) ?? .CashCredit
        self.paymentTime = (try? container.decode(PaymentTime.self, forKey: .paymentTime)) ?? .PostPay
        self.prePayPercent = (try? container.decode(Int.self, forKey: .prePayPercent)) ?? 0
        self.rangePlusPercent = (try? container.decode(Int.self, forKey: .rangePlusPercent)) ?? 0
        self.rangeMinusPercent = (try? container.decode(Int.self, forKey: .rangeMinusPercent)) ?? 0
        self.quantityMode = (try? container.decode(QuantityMode.self, forKey: .quantityMode)) ?? .Singular
        self.eachQuantityFee = (try? container.decode(Double.self, forKey: .eachQuantityFee)) ?? 0
        self.maxQuantity = (try? container.decode(Int.self, forKey: .maxQuantity)) ?? 0
        self.minimumFee = try? container.decode(Double.self, forKey: .minimumFee)
        self.cost = (try? container.decode(Double.self, forKey: .cost)) ?? 0
        self.bookingMode = (try? container.decode(BookingMode.self, forKey: .bookingMode)) ?? .OnlyNow
        self.media = try? container.decode(Media.self, forKey: .media)
        self.category = try? container.decode(ServiceCategory.self, forKey: .category)
        self.availableTimeFrom = try? container.decode(String.self, forKey: .availableTimeFrom)
        self.availableTimeTo = try? container.decode(String.self, forKey: .availableTimeTo)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case baseFare
        case distanceFeeMode
        case perHundredMeters
        case perMinuteWait
        case perMinuteDrive
        case feeEstimationMode
        case canEnableVerificationCode
        case paymentMethod
        case paymentTime
        case prePayPercent
        case rangePlusPercent
        case rangeMinusPercent
        case quantityMode
        case eachQuantityFee
        case maxQuantity
        case minimumFee
        case cost
        case bookingMode
        case media
        case category
        case availableTimeFrom
        case availableTimeTo
    }
}
