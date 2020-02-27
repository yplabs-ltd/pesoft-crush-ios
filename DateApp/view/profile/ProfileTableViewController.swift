//
//  ProfileTableViewController.swift
//  DateApp
//
//  Created by ryan on 12/14/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {

    var onClickRecordVoice: (() -> Void)?
    var onClickPlayVoice: (() -> Void)?
    
    @IBOutlet weak var profileMessageCell: ProfileMessageCell!
    @IBOutlet weak var collectionView: UICollectionView!
    let cellForCheckSize = NowNearKeywordTableViewCell()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // viewmodel
        _app.profileViewModel.bind (view: self) { [weak self] (model, oldModel) -> () in
            
            if let reviewMessage = model?.reviewMessage , model?.status != .Normal {
                self?.profileMessageCell.message = reviewMessage
            } else if let status = model?.status {
                self?.profileMessageCell.message = String.stringForMemberStatus(status: status)
            }
            
            // 프로필 사진 갱신
            self?.collectionView.reloadData()
            self?.tableView.reloadData()
        }
    }
    
    deinit {
        print(#function, "\(self)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = super.tableView(tableView, heightForRowAt: indexPath)
        if indexPath.row == 0 {
            height = profileMessageCell.messageLabel.frame.size.height + 30
        } else if indexPath.row == 2 {
            height = cellForCheckSize.getViewHeight( _app.profileViewModel.getProfileKeywordList(type: .HobbyType), isFold: true) + cellForCheckSize.getViewHeight( _app.profileViewModel.getProfileKeywordList(type: .CharmingType), isFold: true) + cellForCheckSize.getViewHeight( _app.profileViewModel.getProfileKeywordList(type: .FavoriteType), isFold: true) + 10 * 74
        }

        return height
    }
}

extension ProfileTableViewController: ApiReloadable {
    func reloadApi() {
        
        let responseViewModel = DViewModel<ApiResponse>(self, { (model, oldModel) -> () in
            guard let apiResponse = model, let profileModel = apiResponse.model as? ProfileModel else {
                return
            }
            _app.profileViewModel.originalModel = profileModel
        })
        
       let _ =  _app.api.profileEdit(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
    
    }
}


extension ProfileTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let alertController = UIAlertController(title: nil, message: "사진", preferredStyle: .actionSheet)
        
        // for ipad
        if let cell = collectionView.cellForItem(at: indexPath) {
            alertController.popoverPresentationController?.sourceView = cell
            alertController.popoverPresentationController?.sourceRect = cell.bounds
        }
        
        // 선택한 이미지가 첫번째 이미지가 아니고 이미지가 있다면
        if 0 < indexPath.getProfileImageIndex() && indexPath.getProfileImageIndex() < (_app.profileViewModel.model?.imageInfoList.count)! {
            let selected = _app.profileViewModel.model?.imageInfoList[indexPath.getProfileImageIndex()]
            if selected?.image != nil {
                alertController.addAction(UIAlertAction(title: "메인사진으로 바꾸기", style: .default) { (action) -> Void in
                    self.setMainProfileImage(selectedImageIndex: indexPath.getProfileImageIndex())
                    })
            }
        }
        
        // 이미지를 제거 할 수 있다.
        if indexPath.getProfileImageIndex() < (_app.profileViewModel.model?.imageInfoList.count)! {
            let selected = _app.profileViewModel.model?.imageInfoList[indexPath.getProfileImageIndex()]
            if selected?.image != nil {
                alertController.addAction(UIAlertAction(title: "선택사진 삭제", style: .default) { (action) -> Void in
                    self.removeProfileImage(selectedImageIndex: indexPath.getProfileImageIndex())
                    })
            }
        }
        
        alertController.addAction(UIAlertAction(title: "사진 앨범", style: .default) { (action) -> Void in
        
            guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) else {
                alert(message: "Device has no photo library")
                return
            }
            
            let picker = ProfileImagePickerController()
            picker.indexPath = indexPath
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(picker, animated: true, completion: nil)
            })
        
        alertController.addAction(UIAlertAction(title: "카메라", style: .default) { (action) -> Void in
            
            guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) else {
                alert(message: "Device has no camera")
                return
            }
            
            let picker = ProfileImagePickerController()
            picker.indexPath = indexPath
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = UIImagePickerControllerSourceType.camera
            self.present(picker, animated: true, completion: nil)
            })
        
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel) { (action) -> Void in
            ///
            })
        present(alertController, animated: true, completion: nil)
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.getProfileImageIndex() < 2 {
            // 처음 두개 디폴트 이미지는 필수 표시 해줌
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoRequiredCell", for: indexPath) as! ProfileRequiredPhotoCell
            if let profileModel = _app.profileViewModel.model , indexPath.getProfileImageIndex() < profileModel.imageInfoList.count {
                    cell.imageInfo = profileModel.imageInfoList[indexPath.getProfileImageIndex()]
            } else {
                cell.imageInfo = nil
            }
            return cell
        } else if indexPath.row == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileVoiceCell", for: indexPath) as! ProfileVoiceCell
            cell.onClickPlay = { [weak self] in
                guard let wself = self else { return }
                wself.onClickPlayVoice?()
            }
            
            cell.onClickRecord = { [weak self] in
                guard let wself = self else { return }
                wself.onClickRecordVoice?()
            }
            cell.voiceUrl = _app.profileViewModel.model?.voiceUrl
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! ProfilePhotoCell
            if let profileModel = _app.profileViewModel.model , indexPath.getProfileImageIndex() < profileModel.imageInfoList.count  {
                    cell.imageInfo = profileModel.imageInfoList[indexPath.getProfileImageIndex()]
            } else {
                cell.imageInfo = nil
            }
            return cell
        }
    }
}

extension ProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let picker = picker as? ProfileImagePickerController, let indexPath = picker.indexPath else {
            return
        }
        guard let chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage else {
            return
        }
        
        var imageInfo = ProfileModel.ImageInfo()
        imageInfo.imageId = nil   // new image 는 아이디가 nil
        imageInfo.image = chosenImage.imageForSize(targetSize: CGSize(width: 1024, height: 1024))
        
        // viewmodel 갱신
        var new: [ProfileModel.ImageInfo] = []
        if let old = _app.profileViewModel.model?.imageInfoList {
            for imageInfo in old {
                new.append(imageInfo)
            }
            if old.count <= indexPath.getProfileImageIndex() {
                new.append(imageInfo)
            } else {
                new[indexPath.getProfileImageIndex()] = imageInfo
            }
        }
        _app.profileViewModel.model?.imageInfoList = new
        _app.profileSubmitButtonShowViewModel.model = true
        
        picker.dismiss(animated:true, completion: nil)
    }
    
    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated:true, completion: nil)
    }
    
    func setMainProfileImage(selectedImageIndex: Int) {
        
        var new: [ProfileModel.ImageInfo] = []
        if let old = _app.profileViewModel.model?.imageInfoList {
            new.append(old[selectedImageIndex]) // 선택된거 처음으로 이동
            for (idx,imageInfo) in old.enumerated() {
                if selectedImageIndex != idx {
                    new.append(imageInfo)
                }
            }
        }
        _app.profileViewModel.model?.imageInfoList = new
        _app.profileSubmitButtonShowViewModel.model = true
    }
    
    func removeProfileImage(selectedImageIndex: Int) {
        
        var new: [ProfileModel.ImageInfo] = []
        if let old = _app.profileViewModel.model?.imageInfoList {
            for (idx,imageInfo) in old.enumerated() {
                if selectedImageIndex != idx {
                    new.append(imageInfo)
                }
            }
        }
        _app.profileViewModel.model?.imageInfoList = new
        _app.profileSubmitButtonShowViewModel.model = true
    }
}

