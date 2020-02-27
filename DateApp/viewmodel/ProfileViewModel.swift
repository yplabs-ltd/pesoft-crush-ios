//
//  ProfileViewModel.swift
//  DateApp
//
//  Created by ryan on 1/1/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import Foundation

class ProfileViewModel: DViewModel<ProfileModel> {
    
    // api 로 로드한 원본 model
    var originalModel: ProfileModel? {
        didSet {
            model = originalModel
        }
    }
    
    private let apiQueue = DOperationQueue(maxConcurrent: 1)
    
    func getProfileKeywordList(type: ProfileKeywordType) -> [CodeValueModel]? {
        switch type {
        case .HobbyType:
            return (model?.hobbyCode)
        case .CharmingType:
            return model?.gender == "F" ? (model?.charmFTypeCode) : (model?.charmMTypeCode)
        case .FavoriteType:
            return (model?.favoriteTypeCode)
        }
    }
    
    func mergeProfileKeywordList(type: ProfileKeywordType, datas: [String:CodeValueModel]) {
        let addMoreValue = CodeValueModel(code: "", value: "더보기")
        switch type {
        case .HobbyType:
            model?.hobbyCode.removeAll()
            for codeInfo in datas.values {
                model?.hobbyCode.append(codeInfo)
            }
            model?.hobbyCode.append(addMoreValue)
        case .CharmingType:
            if model?.gender == "F" {
                model?.charmFTypeCode.removeAll()
                for codeInfo in datas.values {
                    model?.charmFTypeCode.append(codeInfo)
                }
                model?.charmFTypeCode.append(addMoreValue)
            }else {
                model?.charmMTypeCode.removeAll()
                for codeInfo in datas.values {
                    model?.charmMTypeCode.append(codeInfo)
                }
                model?.charmMTypeCode.append(addMoreValue)
            }
        case .FavoriteType:
            model?.favoriteTypeCode.removeAll()
            for codeInfo in datas.values {
                model?.favoriteTypeCode.append(codeInfo)
            }
            model?.favoriteTypeCode.append(addMoreValue)
        }
    }
    
    func setModelWithImage(profileModel: ProfileModel) {
        var newProfileModel = profileModel
        let imageInfos = profileModel.imageInfoList.map { ( imageInfo) -> ProfileModel.ImageInfo in
            var newImageInfo = imageInfo
            newImageInfo.loadImage()
            return newImageInfo
        }
        newProfileModel.imageInfoList = imageInfos
        model = newProfileModel
    }
    
    func updateProfile(profileModel: ProfileModel, loadingViewModel: DViewModel<LoadingModel>?, completeHandler: @escaping (ProfileModel) -> ()) {
        
        let responseViewModel = ApiResponseViewModelBuilder<ProfileModel>(successHandlerWithDefaultError: { (newProfileModel) -> Void in
            // 갱신
            completeHandler(newProfileModel)
        }).viewModel
        _app.log.debug("parametersForUpdate: \(profileModel.parameters)")
        let _ = _app.api.profileUpdateForParametes(parametersForUpdate: profileModel.parameters, apiResponseViewModel: responseViewModel, loadingViewModel: loadingViewModel)
    }
    
    func uploadImages(loadingViewModel: DViewModel<LoadingModel>?, completeHandler: @escaping (ProfileModel) -> ()) {
        
        guard let profileModel = model else {
            return
        }
        
        var newProfileModel = profileModel
        
        // 이미지 위치 정렬 (공백 없게)
        newProfileModel.imageInfoList = newProfileModel.imageInfoList.filter({ (imageInfo) -> Bool in
            if imageInfo.image != nil {
                return true
            }
            return false
        })
        
        // ordering 세팅
        for (index, _) in newProfileModel.imageInfoList.enumerated() {
            newProfileModel.imageInfoList[index].ordering = index + 1
        }
        
        // 새로운 이미지 s3에 upload (imageId == nil인 것들)
        
        var willUpCount = 0
        var didUpCount = 0
        for (index, imageInfo) in newProfileModel.imageInfoList.enumerated() {
            
            guard imageInfo.imageId == nil else {
                continue
            }
            guard let image = imageInfo.image else {
                continue
            }
            guard let png = UIImagePNGRepresentation(image) else {
                continue
            }
            
            willUpCount += 1
            let s3uploadViewModel = DViewModel<ApiResponse>(self, { (model, oldModel) -> () in
                didUpCount += 1
                if willUpCount == didUpCount {
                    // 마지막 파일 s3 업로드 완료, completeHandler 호출, 이후 completeHandler 에서 profile update 요청 하자
                    completeHandler(newProfileModel)
                }
            })
            
            let s3InforViewModel = DViewModel<ApiResponse>(self, { (model, oldModel) -> () in
                guard let apiResponse = model, let s3 = apiResponse.model as? S3InformationModel else {
                    return
                }
                
                // 프로필 이미지 viewmodel 갱신
                var newImageInfo = imageInfo
                newImageInfo.urlPath = s3.uploadImagePath
                newProfileModel.imageInfoList[index] = newImageInfo
                
                let _ = _app.api.s3Upload(s3: s3, file: png, apiResponseViewModel: s3uploadViewModel, loadingViewModel: loadingViewModel)
            })
            let _ = _app.api.s3Information(apiResponseViewModel: s3InforViewModel, loadingViewModel: loadingViewModel)
        }
    }
}
