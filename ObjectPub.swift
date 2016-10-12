//
//  ObjectPub.swift
//  SBPub
//
//  Created by LiDehua on 16/10/12.
//  Copyright © 2016年 LiDehua. All rights reserved.
//

import Foundation

var subscriptions = [String: Any!]()

extension NSObject {
    func publish(_ string: String) {
        publish(string, data: nil)
    }
    func publish(_ string: String, data: AnyObject?) {
        NotificationCenter.default.post(name: Notification.Name(string), object: nil, userInfo: ["SBPubData": data])
    }
    //subscribe
    func subscribe(_ eventName: String, aSelector: Selector) -> AnyObject? {
        return subscribe(eventName, obj: nil, aSelector: aSelector)
    }
    func subscribe(_ eventName: String, obj: AnyObject?, aSelector: Selector) -> AnyObject? {
        return subscribe(eventName, obj: obj, handle: { (string, obj, data) in
            self.perform(aSelector, with: (string, obj, data))
        })
    }
    func subscribe(_ eventName: String, handler: @escaping ((String, AnyObject?, AnyObject?) -> Void)) -> AnyObject? {
        return subscribe(eventName, obj: nil, handle: handler)
    }
    func subscribe(_ eventName: String, obj: AnyObject?, handle:@escaping ((String, AnyObject?, AnyObject?) -> Void)) -> AnyObject? {
        let observer = NotificationCenter.default.addObserver(forName: Notification.Name(eventName), object: obj, queue: OperationQueue.current, using: { notification in
            guard let userInfo = notification.userInfo as? [String: Any?] else {
                handle(eventName, obj, nil)
                return
            }
            handle(eventName, obj, userInfo["SBPubData"] as AnyObject?)
        })
        subscriptions[eventName] = observer
        return observer
    }
    //subscribeOnce
    func subscribeOnce(_ eventName: String, aSelector: Selector) -> AnyObject? {
        return subscribeOnce(eventName, obj: nil, aSelector: aSelector)
    }
    func subscribeOnce(_ eventName: String, obj: AnyObject?, aSelector: Selector) -> AnyObject? {
        return subscribeOnce(eventName, obj: obj, handle: { (string, obj, data) in
            self.perform(aSelector, with: (string, obj, data))
        })
    }
    func subscribeOnce(_ eventName: String, handler: @escaping ((String, AnyObject?, AnyObject?) -> Void)) -> AnyObject? {
        return subscribeOnce(eventName, obj: nil, handle: handler)
    }
    func subscribeOnce(_ eventName: String, obj: AnyObject?, handle:@escaping ((String, AnyObject?, AnyObject?) -> Void)) -> AnyObject? {
        return subscribe(eventName, obj: obj, handle: { (string, obj, data) in
            self.unsubscribe(eventName)
            handle(string, obj, data)
        })
    }
    //unsubscribe
    func unsubscribe(_ eventName: String) {
        NotificationCenter.default.removeObserver(subscriptions[eventName])
    }
    func unsubscribeAll() {
        for observer in subscriptions.values {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
