//
//  EvaluationCardsViewModel.swift
//  DateApp
//
//  Created by ryan on 1/12/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import Foundation

class EvaluationCardsViewModel: DViewModel<ProfileModel> {
    
    func pass() {
        guard let _ = model else {
            return 
        }
        model = nil
        requestUpdate()
    }
    
    override func reload() {
        let responseViewModel = ApiResponseViewModelBuilder<ProfileModel>(successHandlerWithDefaultError: { (evaluationCardsModel) -> Void in
            _app.evaluationCardsViewModel.model = evaluationCardsModel
        }).viewModel
        print("EvaluationCardsViewModel reload")
        let _ = _app.api.cardListEvaluate(apiResponseViewModel: responseViewModel, loadingViewModel: nil)
    }
    
    var dirtyFlag = false
    
    func requestUpdate() {
        reload()
    }
}
