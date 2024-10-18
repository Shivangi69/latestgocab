//
//  GetMessages.swift
//  Shared
//
//  Created by Manly Man on 11/23/19.
//  Copyright © 2019 Innomalist. All rights reserved.
//

import Foundation

public class GetMessages: SocketRequest {
    public typealias ResponseType = [ChatMessage]
    
    required public init() {}
}
//public class SupportGetMessage: SocketRequest {
//    public typealias ResponseType = [ChatMessage]
//
//    required public init() {}
//}

public class SupportGetMessage: SocketRequest {
    public typealias ResponseType = [AdminChatMessage]
    public var params: [Any]?
    
    init(riderId: Int) {
        self.params = [riderId]
    }
}

//public class SupportGetMessage: SocketRequest {
//    public typealias ResponseType = ChatMessage
//    public var params: [Any]?
//
////    public init(content: String, receiverUserId: Int) {
////        self.params = [content, receiverUserId]
////    }
//
//    required public init() {}
//
//    public func send() {
//        SocketNetworkDispatcher.instance.dispatchnew(event: "SupportGetMessage", params: params) { result in
//            switch result {
//            case .success(let response):
//                // Handle success
//                print("Message Get successfully: \(response)")
//            case .failure(let error):
//                // Handle error
//                print("Error sending message: \(error.localizedDescription)")
//            }
//        }
//    }
//}
