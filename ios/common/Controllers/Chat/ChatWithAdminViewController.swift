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
    @objc func messageReceived(notification: Notification) {
        messages.append(notification.object as! ChatMessage)
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.scrollToLastItem(animated: true)
    }
    
    var socket: SocketIOClient!

    var messages: [ChatMessage] = []
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.messageReceived), name: .messageReceived, object: nil)
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
        
        
//        GetMessages().execute() { result in
//            switch result {
//            case .success(let response):
//                self.messages = response
//                self.messagesCollectionView.reloadData()
//                break;
//                
//            case .failure(let error):
//                error.showAlert()
//            }
//            
//        }
    }
    
    func insertMessage(_ message: ChatMessage) {
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
        return sender
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let msg = message as! ChatMessage
        let url: URL
        if msg.sentBy == .Driver {
            let driver = msg.sender as! Driver
            url = URL(string: Config.Backend + (driver.media?.address?.replacingOccurrences(of: " ", with: "%20") ?? ""))!
            
            
            let driverMedia = driver.driverMedia?.first(where: { $0.mediaType == "profile" })?.url ?? ""
            let str = Config.Backend + driverMedia

    //        //print("Config.Backend: \(Config.Backend)")
    //        //print("driverMedia: \(driverMedia)")
    //        //print("Combined URL: \(str)")

           
            if let encodedDriverMedia = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                //print("Encoded Combined URL: \(encodedDriverMedia)")
                if let mediaUrl = URL(string: encodedDriverMedia) {
                   // //print("mediaUrl: \(mediaUrl)")
                    avatarView.kf.setImage(with: mediaUrl, placeholder: UIImage(named: "nobody"))

                } else {
                    ////print("Invalid mediaUrl: \(encodedDriverMedia)")
                }
            }
            
            
            avatarView.isHidden = isNextMessageSameSender(at: indexPath)
        } else {
            //avatarView.image = UIImage(named: "nobody")
            //avatarView.isHidden = true
        }
        
        
    }
    
    
}

extension ChatWithAdminViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        // Here we can parse for which substrings were autocompleted
        let attributedText = messageInputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { (_, range, _) in
            let substring = attributedText.attributedSubstring(from: range)
            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
            print("Autocompleted: `", substring, "` with context: ", context ?? [])
        }
        messageInputBar.inputTextView.text = String()
        messageInputBar.invalidatePlugins()
        
        // Send button activity animation
        messageInputBar.sendButton.startAnimating()
        messageInputBar.inputTextView.placeholder = "Sending..."
        
        let sendMessage = SupportSendMessage(content: text, receiverUserId: 1)
        sendMessage.send()
//        SupportSendMessage(content: text, receiverUserId: 1).execute() { result in
//            switch result {
//            case .success(let response):
//                self.messageInputBar.sendButton.stopAnimating()
//                self.messageInputBar.inputTextView.placeholder = "Aa"
//                self.insertMessage(response)
//                self.messagesCollectionView.scrollToLastItem(animated: true)
//
//            case .failure(let error):
//
        self.messageInputBar.sendButton.stopAnimating()
//                error.showAlert()
//            }
//        }
    }
    
    private func insertMessages(_ messages: [ChatMessage]) {
        for message in messages {
            insertMessage(message)
        }
    }
    
    
}


extension ChatWithAdminViewController: MessagesDisplayDelegate, MessagesLayoutDelegate {}
