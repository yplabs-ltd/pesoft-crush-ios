//
//  HistoriesViewModel.swift
//  DateApp
//
//  Created by ryan on 1/10/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import Foundation

class HistoriesViewModel: DViewModel<HistoriesModel> {
    
    var sectionCount: Int {
        return 6    // 무조건 5 section 이고 item 있고 없고에 따라 section header height 이 조정 됩니다.
    }
    
    var totalCardsCount: Int {
        return favorMatchCardsCount + likeMeCardsCount + iLikeCardsCount + favorMeHiddenCardsCount + ifavorCardsCount + historyCardsCount
    }
    var favorMatchCardsCount: Int {
        // 서로 호감이 있어요
        guard let cards = model?.favorMatchCards else {
            return 0
        }
        return cards.count
    }
    var likeMeCardsCount: Int {
        // 당신을 좋아해요
        if let cards = model?.likeMeCards {
            return cards.count
        }
        return 0
    }
    var favorMeHiddenCardsCount: Int {
        // 당신이 좋아해요
        guard let cards = model?.favorMeHiddenCards else {
            return 0
        }
        return cards.count
    }
    var iLikeCardsCount: Int {
        // 당신이 좋아해요
        guard let cards = model?.iLikeCards else {
            return 0
        }
        return cards.count
    }
    var favorMeCardsCount: Int {
        // 당신에게 호감이 있어요
        guard let cards = model?.favorMeCards else {
            return 0
        }
        return cards.count
    }
    
    var ifavorCardsCount: Int {
        // 당신이 호감을 표현했어요
        guard let cards = model?.ifavorCards else {
            return 0
        }
        return cards.count
    }
    
    var historyCardsCount: Int {
        // 지나간 인연
        guard let cards = model?.historyCards else {
            return 0
        }
        return cards.count
    }
    
    override func reload() {
        let responseViewModel = ApiResponseViewModelBuilder<HistoriesModel> (successHandler: { (model) -> Void in
            _app.historiesViewModel.model = model
        }).viewModel
        let _ = _app.api.cardListLikeFavor(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
    }
    
    // dirtyFlag 를 true 해둔 후 나중에 reload 하기위함
    var dirtyFlag = false
    
    func reloadIfDirty() {
        if dirtyFlag {
            dirtyFlag = false
            reload()
        }
    }
}
