//
//  ShopViewController.swift
//  DateApp
//
//  Created by ryan on 1/16/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import UIKit
import StoreKit

class ShopViewController: UITableViewController {

    @IBOutlet weak var heartCountLabel: UILabel!
    @IBOutlet weak var remainTimeLabel: UILabel!
    
    var confirmSegue: DSegue?
    var isPromotion: Bool = false
    var checkTimer: Timer!
    var expiredDttm: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkRemainTime()
        adjustPointModels()
        title = "버찌 충전"
        remainTimeLabel.textColor = UIColor(rgba: "#f2503b")
        tableView.tableFooterView = UIView(frame: CGRect.zero)   // 내용없는 셀 표시 안함
        
        // 보유 버찌 확인
        _app.sessionViewModel.bind (view: self) { [weak self] (model, oldModel) -> () in
            self?.fillHeaderCountLabelText()
        }
        fillHeaderCountLabelText()
        updateRemainTimeFromCurrent()
        if !SKPaymentQueue.canMakePayments() {
            alert(message: "앱 내 결제가 비활성화 상태입니다.")
        }
    }

    deinit {
        print(#function, "\(self)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "버찌 충전"
        _app.ga.trackingViewName(viewName: .shop)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func adjustPointModels() {
        let normalPointsModelSet:Set<PointModel.Identifier> = [PointModel.Identifier.Point30, PointModel.Identifier.Point80, PointModel.Identifier.Point150, PointModel.Identifier.Point300, PointModel.Identifier.Point600]
        let eventPointsModelSet:Set<PointModel.Identifier> = [PointModel.Identifier.Point30Event, PointModel.Identifier.Point80, PointModel.Identifier.Point150Event, PointModel.Identifier.Point300, PointModel.Identifier.Point600Event]
        if isPromotion {
            let newModels = _app.pointsViewModel.model?.filter { eventPointsModelSet.contains($0.identifier) }
            if let m = newModels {
                _app.pointsViewModel.model?.removeAll()
                _app.pointsViewModel.model? = m
            }
            
        }else {
            let newModels = _app.pointsViewModel.model?.filter { normalPointsModelSet.contains($0.identifier) }
            if let m = newModels {
                _app.pointsViewModel.model?.removeAll()
                _app.pointsViewModel.model? = m
            }
        }
    }
    
    func updateRemainTimeFromCurrent() {
        if checkTimer != nil {
            checkTimer.invalidate()
            checkTimer = nil
        }
        
        checkTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.checkRemainTime), userInfo: nil, repeats: true)
    }
    
    @objc func checkRemainTime() {
        isPromotion = false
        if let d = expiredDttm {
            
            let exp = Date(timeInterval: 259200, since: d)
            let interval = Date().timeIntervalSince(exp)
            if let elapse = String.stringDayHourMinFromTimeInterval(interval: interval, expireDate: exp) , elapse.length > 0 {
                self.remainTimeLabel.text = elapse
                isPromotion = true
            }else {
                if checkTimer != nil {
                    checkTimer.invalidate()
                }
                
                tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = super.tableView(tableView, heightForRowAt: indexPath)
        if indexPath.row == 0 {
            height = 0
            if isPromotion {
                if let d = expiredDttm {
                    let exp = Date(timeInterval: 259200, since: d)
                    let interval = Date().timeIntervalSince(exp)
                    if let elapse = String.stringDayHourMinFromTimeInterval(interval: interval, expireDate: d) , elapse.length > 0 {
                        height = 38
                    }
                }
            }
        }
        if indexPath.row == 2 {
            return (isPromotion ? 165 : 145) * 3 + 50
        }
        return height
    }
}

extension ShopViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 96, height: isPromotion ? 166 : 145)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _app.pointsViewModel.model?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let pointsModel = _app.pointsViewModel.model else {
            return UICollectionViewCell()
        }
        guard indexPath.item < pointsModel.count else {
            return UICollectionViewCell()
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! ShopGoodsCollectionCell
        cell.isEventMode = isPromotion
        cell.pointModel = pointsModel[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let pointModel = _app.pointsViewModel.model?[indexPath.item] else {
            return
        }
        
        confirmSegue = segueForConfirm(pointModel: pointModel)
        confirmSegue?.perform()
    }
}

extension ShopViewController {
    func fillHeaderCountLabelText() {
        if let member = _app.sessionViewModel.model, let point = member.point {
            heartCountLabel.text = "\(point)버찌 보유중"
        }
    }
    
    func paymentForProduct(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        _app.loadingViewModel.model?.add()
        
    }
    
    private func sendAdbrixLog(pointModel: PointModel) {
        if let priceString = pointModel.priceString, let price = Double(priceString.replacingOccurrences(of: "US$", with: "")) {
            
            AdBrix.purchase(pointModel.identifier.rawValue,
                            price: price,
                            currency: AdBrix.currencyName(UInt(AdBrixCurrencyType.USD.rawValue)),
                            paymentMethod: AdBrix.paymentMethod(UInt(AdbrixPaymentMethod.AdBrixPaymentMobilePayment.rawValue)))
        }
    }
    
    private func segueForConfirm(pointModel: PointModel) -> DSegue? {
        
        let segue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "ConfirmPopupController") as! ConfirmPopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: 172.0)
            })
            destination.line1 = ("버찌를 \(pointModel.pointCount)개 충전합니다", .Title)
            let bonusCount = self!.isPromotion ? pointModel.promotionCount : pointModel.bonusCount
            destination.line2 = ("보너스 +\(bonusCount)", .Normal)
            if let priceString = pointModel.priceString {
                destination.line3 = (priceString, .Red)
            }
            
            
            destination.submitHandler = { (popup: UIViewController) -> Void in
                self?.sendAdbrixLog(pointModel: pointModel)
                popup.dismiss(animated:true, completion: { () -> Void in
                    // 구매요청
                    self?.paymentForProduct(product: pointModel.product)
                })
            }
            return (destination, style)
        })
        return segue
    }
}
