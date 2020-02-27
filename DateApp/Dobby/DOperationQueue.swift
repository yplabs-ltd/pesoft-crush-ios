//
//  DOperationQueue.swift
//  Dobby
//
//  Created by ryan on 1/3/16.
//  Copyright © 2016 while1.io. All rights reserved.
//

import Foundation

public struct DOperationQueue {
    
    let queue = OperationQueue()
    
    public init(maxConcurrent: Int) {
        queue.maxConcurrentOperationCount = maxConcurrent
    }
    
    // operation 없이 nil 만 반환 할 수도 있음
    public func addOperation(operation: () -> Operation?) -> DOperationQueue {
        let me = self
        if let op = operation() {
            queue.addOperation(op)
        }
        return me
    }
    
    public func addOperation(operationBlock: @escaping () -> ()) -> DOperationQueue {
        let me = self
        queue.addOperation(operationBlock)
        return me
    }
    
    // 기존에 queue에 있는 operation 모두 취소 후 바로 실행
    public func replaceOperation(operation: () -> Operation?) -> DOperationQueue {
        let me = self
        if let op = operation() {
            queue.cancelAllOperations()
            queue.addOperation(op)
        }
        return me
    }
}
