//
//  SendMessage.swift
//  Shared
//
//  Created by Manly Man on 11/23/19.
//  Copyright © 2019 Innomalist. All rights reserved.
//

import Foundation

public class SendMessage: SocketRequest {
    public typealias ResponseType = ChatMessage
    public var params: [Any]?
    
    public init(content: String) {
        self.params = [content]
    }
    
    required public init() {}
}
public class SupportSendMessage: SocketRequest {
    public typealias ResponseType = AdminChatMessage
    public var params: [Any]?

    public init(content: String, receiverUserId: Int) {
        self.params = [content, receiverUserId]
    }
    
    required public init() {}
    
//    public func send() {
//        SocketNetworkDispatcher.instance.dispatchnew(event: "SupportSendMessage", params: params) { result in
//            switch result {
//            case .success(let response):
//                // Handle success
//                print("Message sent successfully: \(response)")
//            case .failure(let error):
//                // Handle error
//                print("Error sending message: \(error.localizedDescription)")
//            }
//        }
//    }
    public func send(completion: @escaping (Result<String, Error>) -> Void) {
        SocketNetworkDispatcher.instance.dispatchnew(event: "SupportSendMessage", params: params) { result in
            switch result {
            case .success(let response):
                // Assuming response is of type AdminChatMessage
                print("Message sent successfully: \(response)")
                completion(.success(response as! String)) // Return the response
            case .failure(let error):
                // Handle error
                print("Error sending message: \(error.localizedDescription)")
                completion(.failure(error)) // Return the error
            }
        }
    }

}

