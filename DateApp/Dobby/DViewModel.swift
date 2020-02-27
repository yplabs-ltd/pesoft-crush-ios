/*
 //  Dobby.swift
 //  Dobby
 //
 //  Created by ryan on 1/5/16.
 //  Copyright © 2016 while1.io. All rights reserved.
*/

import Foundation

struct HandlerInfo {
    weak var view: AnyObject?
    let once: Bool
    var removed: Bool
    init(view: AnyObject?, once: Bool) {
        self.view = view
        self.once = once
        self.removed = false
    }
}

protocol Reloadable {
    func reload()
    func reloadIfNeeds()
    func setNeedsReload()
}

public class DViewModel <M>: Reloadable {
    
    public typealias Handler = (_ model: M?, _ oldModel: M?) -> ()
    private typealias HandlerAndInfo = (handler: Handler, info: HandlerInfo)
    private var handlerAndInfos: [HandlerAndInfo] = []
    
    public var model: M? {
        didSet {
            let newModel = model
            oldModel = oldValue
            
            // newModel이 nil 인데 이전에도 nil 이면 change 이벤트 또 발생시킬 필요없음
            var nilDouble = false
            if newModel == nil && oldModel == nil {
                nilDouble = true
            }
            if !nilDouble {
                modelDidChange(newModel: newModel, oldModel: oldModel)
            }
        }
    }
    private(set) var oldModel: M?
    
    public init() {
        
    }
    
    public convenience init(_ model: M) {
        self.init()
        self.model = model
    }
    
    public convenience init(_ view: AnyObject?, _ handler: @escaping Handler) {
        self.init()
        let handlerInfo = HandlerInfo(view: view, once: false)
        handlerAndInfos.append((handler,handlerInfo))
    }
    
    public convenience init(_ model: M, _ view: AnyObject?, _ handler: @escaping Handler) {
        self.init()
        self.model = model
        let handlerInfo = HandlerInfo(view: view, once: false)
        handlerAndInfos.append((handler,handlerInfo))
    }
    
    private func modelDidChange(newModel: M?, oldModel: M?) {
        //TODO:: Must be checked - svp
        handlerAndInfos = handlerAndInfos.map({ (handlerAndInfo) -> HandlerAndInfo in
            guard !handlerAndInfo.info.removed else {
                return handlerAndInfo
            }
            var newHandler = handlerAndInfo
            if handlerAndInfo.info.once {
                // 한번만 bind handler 호출하고 제거한다.
                newHandler.info.removed = true
                DispatchQueue.main.async(execute: {() -> Void in
                    newHandler.handler(newModel, oldModel)
                })
                
            } else if let _ = handlerAndInfo.info.view {
                DispatchQueue.main.async(execute: {() -> Void in
                    newHandler.handler(newModel, oldModel)
                })
            } else {
                // bind 된 view 가 사라지면 handler 도 제거한다
                newHandler.info.removed = true
            }
            return newHandler
        }).filter({ (handlerAndInfo) -> Bool in
            guard !handlerAndInfo.info.removed else {
                return false
            }
            return true
        })
    }
    
    public func bind(view: AnyObject?, handler: @escaping Handler) {
        let handlerInfo = HandlerInfo(view: view, once: false)
        handlerAndInfos.append((handler,handlerInfo))
    }
    
    public func bindOnce(handler: @escaping Handler) {
        let handlerInfo = HandlerInfo(view: nil, once: true)
        handlerAndInfos.append((handler,handlerInfo))
    }
    
    public func bindThenFire(view: AnyObject?, handler: @escaping Handler) {
        bind(view: view, handler: handler)
        handler(model, oldModel)
    }
    
    // MARK: - Reloadable 관련구현
    
    private var needsReload = false
    
    public func reloadIfNeeds() {
        if needsReload {
            needsReload = false
            reload()
        }
    }
    
    public func setNeedsReload() {
        needsReload = true
    }
    
    public func reload() {
        fatalError("This method should be implemented.")
    }
    
    public func reloadWithCompletion(completion: (() -> Void)? = nil) {
        fatalError("This method should be implemented.")
    }
}


