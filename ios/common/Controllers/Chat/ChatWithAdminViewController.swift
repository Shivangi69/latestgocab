//
//  ChatWithAdminViewController.swift
//  rider
//
//  Created by Admin on 13/09/24.
//  Copyright © 2024 minimal. All rights reserved.
//

import UIKit
import MessageKit
import Kingfisher
import InputBarAccessoryView
import FirebaseAuth
import FirebaseMessaging
import SPAlert
import SocketIO


class ChatWithAdminViewController: MessagesViewController {
    
    @objc func supportMessageReceived(notification: Notification) {
        messages.append(notification.object as! AdminChatMessage)
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.scrollToLastItem(animated: true)
    }

    var socket: SocketIOClient!
//AdminAdminChatMessage
    var messages: [AdminChatMessage] = []
    var sender: SenderType!
    func connectSocket(token:String) {
        Messaging.messaging().token() { (fcmToken, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
                if let token = UserDefaultsConfig.jwtToken {
                    self.connectSocket(token: token)
                }
            }
            SocketNetworkDispatcher.instance.connect(namespace: .Rider, token: token, notificationId: fcmToken ?? "") { result in
                switch result {
                case .success(_):

                    print("")
//                    UserDefaults.standard.set("yes", forKey: "Firsttyme")
//
//
//                    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController") as? MainViewController {
//
//                        self.navigationController!.pushViewController(vc, animated: true)
//                    }
//
//                    self.performSegue(withIdentifier: "segueHost", sender: nil)
//

                    SupportGetMessage(riderId: 60).execute() { result in
                        switch result {
                        case .success(let response):

                            self.messages = response
                            print("self.messages",self.messages)
                            self.messagesCollectionView.reloadData()
                            self.messagesCollectionView.scrollToLastItem(animated: true)

                            break;

                        case .failure(let error):
                            error.showAlert()
                        }

                    }


                case .failure(let error):
                    switch error {
                    case .NotFound:
                        let title = NSLocalizedString("Message", comment: "Message Default Title")
                        let dialog = UIAlertController(title: title, message: "User Info not found. Do you want to register again?", preferredStyle: .alert)
                        dialog.addAction(UIAlertAction(title: "Register", style: .default) { action in
//                            self.onLoginClicked(self.buttonLogin)
                        })
                        dialog.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        self.present(dialog, animated: true, completion: nil)

                    default:
                        SPAlert.present(title: "Error", message: error.rawValue, preset: .error)
//                        self.indicatorLoading.isHidden = true
//                        self.textLoading.isHidden = true
//                        self.buttonLogin.isHidden = false
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)

        self.title = "Chat".uppercased()
        NotificationCenter.default.addObserver(self, selector: #selector(self.supportMessageReceived), name: .supportMessageReceived, object: nil)
        self.title = NSLocalizedString("Chat", comment: "Title of chat screen")
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        self.messageInputBar.delegate = self
        if #available(iOS 13.0, *) {
            self.messagesCollectionView.backgroundColor = .systemBackground
        }
        if #available(iOS 13.0, *) {
            messageInputBar.inputTextView.textColor = .label
            messageInputBar.inputTextView.placeholderLabel.textColor = .secondaryLabel
            messageInputBar.backgroundView.backgroundColor = .systemBackground
        } else {
            messageInputBar.inputTextView.textColor = .black
            messageInputBar.inputTextView.backgroundColor = .white
        }

        connectSocket(token: UserDefaultsConfig.jwtTokenNew ?? "")


//        let GetMessage = SupportGetMessage()
//        GetMessage.send()
    }

    func insertMessage(_ message: AdminChatMessage) {
        messages.append(message)
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.scrollToLastItem(animated: true)
    }

    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messages.count else { return false }
        return messages[indexPath.section].sentBy == messages[indexPath.section + 1].sentBy
    }
}

extension ChatWithAdminViewController: MessagesDataSource {

    func currentSender() -> SenderType {
//        print(sender!)
        return sender
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    internal func isFromCurrentSender(message: MessageType) -> Bool {
        let msg = message as! AdminChatMessage

        if msg.sentBy == .Rider {
       return true
            
        }else{
            return false
        }}

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let msg = message as! AdminChatMessage
        let url: URL
        if msg.sentBy == .Driver {

//            let driver = msg.sender as! Driver
//            url = URL(string: Config.Backend + (driver.media?.address?.replacingOccurrences(of: " ", with: "%20") ?? ""))!
//
//
//            let driverMedia = driver.driverMedia?.first(where: { $0.mediaType == "profile" })?.url ?? ""
//            let str = Config.Backend + driverMedia

    //        //print("Config.Backend: \(Config.Backend)")
    //        //print("driverMedia: \(driverMedia)")
    //        //print("Combined URL: \(str)")


//            if let encodedDriverMedia = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
//                //print("Encoded Combined URL: \(encodedDriverMedia)")
//                if let mediaUrl = URL(string: encodedDriverMedia) {
//                   // //print("mediaUrl: \(mediaUrl)")
//                    avatarView.kf.setImage(with: mediaUrl, placeholder: UIImage(named: "nobody"))
//
//                } else {
//                    ////print("Invalid mediaUrl: \(encodedDriverMedia)")
//                }
//            }
            avatarView.image = UIImage(named: "bot 2")

        } else {
            avatarView.image = UIImage(named: "profile1")

            //avatarView.isHidden = true
        }
    }
}

extension ChatWithAdminViewController: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        // Send button activity animation
        messageInputBar.sendButton.startAnimating()
        messageInputBar.inputTextView.placeholder = "Sending..."

        let sendMessage = SupportSendMessage(content: text, receiverUserId: 1)
        sendMessage.send { result in
            DispatchQueue.main.async {
                self.messageInputBar.sendButton.stopAnimating()
                self.messageInputBar.inputTextView.placeholder = "Type Message..." // Reset placeholder

                switch result {
                case .success(let success):
                    // Add the successfully sent message to the list
                 //   self.insertMessage(message)
//                    let newMessage = AdminChatMessage(id: (messages.last?.id ?? 0) + 1,
//                                    sentAt: Date().timeIntervalSince1970 * 1000, // Current time
//                                    content: text,
//                                    sentBy: "rider", // Assuming the sender is Rider
//                                    state: "sent") // Adjust state as necessary

                    
                    let newMessage = AdminChatMessage(id: (self.messages.last?.id ?? 0) + 1,
                                                         sentAt: Date().timeIntervalSince1970 * 1000, // Current time
                                                         content: text,
                                                         sentBy: .Rider, // Assuming the sender is Rider
                                                         state: "sent")
                    
                    
                    
                                   // Insert the new message into the list
                    self.insertMessage(newMessage)
                    self.messagesCollectionView.scrollToLastItem(animated: true)
                    self.messageInputBar.inputTextView.text = ""

                
                case .failure(let error):
                    // Handle error (e.g., show an alert)
                    print("Error sending message: \(error.localizedDescription)")
                    // Optionally, show an alert to the user about the error
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    private func insertMessages(_ messages: [AdminChatMessage]) {
        for message in messages {
            insertMessage(message)
        }
    }


}


extension ChatWithAdminViewController: MessagesDisplayDelegate, MessagesLayoutDelegate {
    
    internal func textColor(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UIColor {
        let msg = message as! AdminChatMessage

        if msg.sentBy == .Rider {
            
         return   UIColor.white
            
        }else{
            return      .black
        }
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        let msg = message as! AdminChatMessage

        if msg.sentBy == .Rider {
            
         return   UIColor.green
            
        }else{
            return      .lightGray
        }
          // return isFromCurrentSender(message: message) ? .blue : .lightGray // Change colors as needed
       }

      

       func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
           
           let msg = message as! AdminChatMessage

           if msg.sentBy == .Rider {
               let tail: MessageStyle.TailCorner = .bottomRight
               return .bubbleTail(tail, .curved)
               
           }else{
               let tail: MessageStyle.TailCorner = .bottomLeft
               return .bubbleTail(tail, .curved)            }
           // You can customize this further if needed
       }

}


