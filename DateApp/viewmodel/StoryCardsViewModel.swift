//
//  StoryCardsViewModel.swift
//  DateApp
//
//  Created by Yang Hyeon Gyu on 2017. 3. 5..
//  Copyright © 2017년 iflet.com. All rights reserved.
//

import Foundation

class StoryCardsViewModel: DViewModel<StoryCardsModel> {
    func pass() {
        guard let cardsModel = model , 0 < cardsModel.list.count else {
            return
        }
        var newCardsModel = cardsModel
        newCardsModel.list.remove(at: 0)
        model = newCardsModel
    }
    
    override func reload() {
        let responseViewModel = ApiResponseViewModelBuilder<StoryCardsModel>(successHandlerWithDefaultError: { (storyCardsViewModel) -> Void in
            _app.storyCardsViewModel.model = storyCardsViewModel
        }).viewModel
        let _ = _app.api.voiceListWithPerson(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
    }
    
    var dirtyFlag = false
    
    func reloadIfDirty() {
        if dirtyFlag {
            dirtyFlag = false
            reload()
        }
    }
}
