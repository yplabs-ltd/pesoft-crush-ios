//
//  ViewModelBuilders.swift
//  DateApp
//
//  Created by ryan on 1/2/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import Foundation

struct LoadingViewModelBuilder {
    
    private(set) var viewModel: DViewModel<LoadingModel>
    
    init(superview: UIView) {
        
        let indi = ActivityIndicatorViewBuilder(centerAtView: superview, style: .gray).indicatorView
        viewModel = DViewModel<LoadingModel>(LoadingModel(), _app.delegate, { (model, oldModel) -> () in
            if model?.loading == true {
                indi.startAnimating()
            } else {
                indi.stopAnimating()
            }
        })
    }
}

struct ApiResponseViewModelBuilder <M> {
    
    private(set) var viewModel: DViewModel<ApiResponse>
    
    init(successHandler: @escaping (_ model: M) -> Void) {
        
        self.init(errorHandler: nil, successHandler: successHandler)
    }
    
    init(successOrErrorHandler: @escaping () -> Void) {
        
        self.init(errorHandler: { (statusCode, serverError) -> ()  in
            successOrErrorHandler()
            }) { (M) -> () in
                successOrErrorHandler()
        }
    }
    
    // 기본 popup 오류 처리
    init(successHandlerWithDefaultError successHandler: @escaping (_ model: M) -> Void) {
        
        self.init(errorHandler: { (statusCode, serverError) -> ()  in
            let title = serverError?.title ?? ""
            let msg = serverError?.description ?? ""
            //alert(title, message: msg)
            }, successHandler: successHandler)
    }
    
    init(errorHandler: ((_ statusCode: Int, _ serverError: ServerDefaultResponseModel?) -> Void)?, successHandler: @escaping (_ model: M) -> Void) {
        
        viewModel = DViewModel<ApiResponse>(_app.delegate, { (model, oldModel) -> () in
            guard let apiResponse = model else {
                return
            }
            
            if let model = apiResponse.model as? M {
                successHandler(model)
            } else {
                errorHandler?(apiResponse.statusCode, apiResponse.serverErrorModel)
            }
        })
    }
}
