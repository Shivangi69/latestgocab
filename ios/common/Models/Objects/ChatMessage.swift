
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let chatMessage = try? newJSONDecoder().decode(ChatMessage.self, from: jsonData)

import Foundation
import UIKit
import MessageKit

// MARK: - ChatMessageElement
public class ChatMessage: Codable, MessageType {
    let id: Int?
    let sentAt: Double?
    let content: String?
    let sentBy: ClientType?
    let state: String?
    
    public var sender: SenderType { get {
        if(self.sentBy == .Driver) {
            return Request.shared.driver!
        } else {
            return Request.shared.rider!
        }
      }
    }
    
    public var messageId: String { get {
        return String(self.id!)
        }
    }
    
    public var sentDate: Date { get {
        return Date(timeIntervalSince1970: sentAt! / 1000)
    }
}
    
    public var kind: MessageKind { get {
        return MessageKind.text(self.content!)
        }
    }
}

public enum ClientType: String, Codable {
    case Driver = "d"
    case Rider = "r"
}
typealias ChatMessages = [ChatMessage]


//public class AdminChatMessage: Codable, MessageType {
//    let id: Int?
//    let sentAt: Double?
//    let content: String?
//    let sentBy: AdminClientType?
//    let state: String?
//
//    public var sender: SenderType { get {
//        if(self.sentBy == .Driver) {
//            return Request.shared.driver!
//        } else {
//            return Request.shared.rider!
//        }
//      }
//    }

//    public var messageId: String { get {
//        return String(self.id!)
//        }
//    }
//
//
////    public var sender: String { get {
////        return String(self.sentBy!)
////        }
////    }
//
//    public var sentDate: Date { get {
//        return Date(timeIntervalSince1970: sentAt! / 1000)
//        }}
//
//    public var kind: MessageKind { get {
//        return MessageKind.text(self.content!)
//        }
//    }
//}


public class AdminChatMessage: Codable ,MessageType{
    let id: Int?
    let sentAt: Double?
    let content: String?
    let sentBy: AdminClientType?
    let state: String?

    public var messageId: String {
        return String(self.id ?? 0) // Safe unwrapping of id
    }

    public var sentDate: Date {
        return Date(timeIntervalSince1970: (sentAt ?? 0) / 1000) // Safe unwrapping of sentAt
    }

    
    public var kind: MessageKind {
        return MessageKind.text(self.content ?? "") // Default to empty string if content is nil
    }
    
    
    public var sender: SenderType {
            if self.sentBy == .Driver {
                guard let driver = Request.shared.driver else {
                    // Handle the nil case appropriately
                   // print("Warning: Driver is nil")
                    return DefaultSender() // Provide a default sender
                }
                return driver
            }
            else {
                guard let rider = Request.shared.rider else {
                    // Handle the nil case appropriately
                   // print("Warning: Rider is nil")
                    return DefaultSender() // Provide a default sender
                }
                return rider
            }
        }

    // Optionally, you can add a method to get the sender's details if needed
    public func getSenderDetails() -> String {
        switch sentBy {
        case .Driver:
            return "Sent by Driver"
        case .Rider:
            return "Sent by Rider"
        case .none:
            return "Sender information not available"
        }
    }
    public init(id: Int?, sentAt: Double?, content: String?, sentBy: AdminClientType?, state: String?) {
            self.id = id
            self.sentAt = sentAt
            self.content = content
            self.sentBy = sentBy
            self.state = state
        }
}

public enum AdminClientType: String, Codable {
    case Driver = "admin"
    case Rider = "rider"
}
public struct DefaultSender: SenderType {
    public var senderId: String {
        return "defaultSender"
    }

    public var displayName: String {
        return "Unknown Sender"
    }
}
typealias AdminChatMessages = [AdminChatMessage]
