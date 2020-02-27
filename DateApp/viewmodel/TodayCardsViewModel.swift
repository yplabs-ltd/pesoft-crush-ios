//
//  TodayCardsViewModel.swift
//  DateApp
//
//  Created by ryan on 1/1/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import Foundation

final class TodayCardsViewModel: DViewModel<[CardModel]> {
    
    // 이전 expiredTime 과 바뀌었으면 true (UI 를 바뀌었을때만 그리고 싶음)
    func expiredTimeChangedOfIndex(index: Int) -> Bool {
        guard 0 < index else {
            return true
        }
        if let card = model?[index], let prevCard = model?[index - 1] , card.expiredDttm == prevCard.expiredDttm {
            return false
        }
        return true
    }
    
    override func reload() {
        let responseViewModel = ApiResponseViewModelBuilder<[CardModel]>(successHandlerWithDefaultError: { [weak self] (cardModels) -> Void in
            self?.model = cardModels
        }).viewModel
        let _ = _app.api.cardListTodayV2(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
    }
    
    func requestTodayRecommendCards() {
        let responseViewModel = ApiResponseViewModelBuilder<[CardModel]>(successHandlerWithDefaultError: { [weak self] (cardModels) -> Void in
            self?.model = cardModels
            }).viewModel
        let _ = _app.api.cardListToday(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
    }
    
    func more() {
        
        let responseViewModel = ApiResponseViewModelBuilder<[CardModel]>(successHandlerWithDefaultError: { [weak self] (cardModels) -> Void in
            if let oldCards = self?.model {
                // 신규 카드 리스트를 앞에 추가
                self?.model = cardModels + oldCards
            } else {
                self?.model = cardModels
            }
            }).viewModel
        let _ = _app.api.openMoreTodayList(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
    }
     
    func moreTopTen() {
        
        let responseViewModel = ApiResponseViewModelBuilder<[CardModel]>(successHandlerWithDefaultError: { [weak self] (cardModels) -> Void in
            if let oldCards = self?.model {
                // 신규 카드 리스트를 앞에 추가
                self?.model = cardModels + oldCards
            } else {
                self?.model = cardModels
            }
            }).viewModel
        let _ = _app.api.openTopTenTodayList(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
    }
    
    func moreLocation() {
        
        let responseViewModel = ApiResponseViewModelBuilder<[CardModel]>(successHandlerWithDefaultError: { [weak self] (cardModels) -> Void in
            if let oldCards = self?.model {
                // 신규 카드 리스트를 앞에 추가
                self?.model = cardModels + oldCards
            } else {
                self?.model = cardModels
            }
            }).viewModel
        let _ = _app.api.openMoreLocalTodayList(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
    }
    
    func cardModelFromUserId(userId: Int) -> CardModel? {
        let matched = model?.filter({ (cardModel) -> Bool in
            if userId == cardModel.id {
                return true
            }
            return false
        }).first
        if let matched = matched {
            return matched
        }
        return nil
    }
    
    
}
