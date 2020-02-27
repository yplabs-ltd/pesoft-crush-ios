//
//  ApiResponse.swift
//  Hogwarts
//
//  Created by ryan on 9/9/15.
//  Copyright (c) 2015 kakao. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias ApiResponseModel = Any

struct ApiResponse {
    
    private(set) var statusCode: Int
    private(set) var code: Int?
    private(set) var message: String?
    private(set) var model: ApiResponseModel?
    private(set) var serverErrorModel: ServerDefaultResponseModel?
    private(set) var serverResponseHeader: [AnyHashable : Any]?    // 서버쪽 response header 저장
    
    init(_ builder: ApiResponse.Builder) {
        self.statusCode = builder.statusCode
        self.code = builder.code
        self.message = builder.message
        self.model = builder.model
        self.serverErrorModel = builder.serverErrorModel
        self.serverResponseHeader = builder.serverResponseHeader
    }
    
    struct Builder {
        
        private(set) var statusCode: Int
        private(set) var code: Int?
        private(set) var message: String?
        private(set) var model: ApiResponseModel?
        private(set) var serverErrorModel: ServerDefaultResponseModel?
        private(set) var serverResponseHeader: [NSObject:AnyObject]?
        
        init (statusCode: Int) {
            self.statusCode = statusCode
        }
        
        func setModel(model: ApiResponseModel?) -> Builder {
            var builder = self
            builder.model = model
            return builder
        }
        
        func setCode(code: Int) -> Builder {
            var builder = self
            builder.code = code
            return builder
        }
        
        func setMessage(message: String) -> Builder {
            var builder = self
            builder.message = message
            return builder
        }
        
        func setServerErrorModel(serverErrorModel: ServerDefaultResponseModel) -> Builder {
            var builder = self
            builder.serverErrorModel = serverErrorModel
            return builder
        }
        
        func setServerResponseHeader(serverResponseHeader: [AnyHashable : Any]?) -> Builder {
            var builder = self
            builder.serverResponseHeader = serverResponseHeader as! [NSObject : AnyObject]
            return builder
        }
    }
    
}

