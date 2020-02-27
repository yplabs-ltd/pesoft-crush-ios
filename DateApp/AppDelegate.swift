//
//  AppDelegate.swift
//  DateApp
//
//  Created by ryan on 12/12/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit
import CoreData
import StoreKit
import UserNotifications
import AdSupport

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate{

    var window: UIWindow?
    var isForeground: Bool = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        registerAdbrix()
        
        #if DEBUG
        _app.log.setup(level: .debug, showLogIdentifier: true, showFunctionName: true, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, showDate: true, writeToFile: "/tmp/XCGLogger.log", fileLevel: .debug)
        #endif
        
        let userInfo = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification]
        if let ui = userInfo {
            
            let time = DispatchTime.now() + Double(Int64(2.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time) {
                self.handleRemoteNotification(userInfo: ui as? [AnyHashable : Any])
            }
        }
    
        // sendbird 초기화
        _app.sendBird.initialize()
        
        // OnseSignal 초기화
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: _app.config.onsignalAppId,
                                        handleNotificationReceived: {
                                            (notification) in
                                            print("Received Notification - \(notification?.payload.notificationID)")
                                            
                                            //if let additionalData = notification.payload.additionalData, actionSelected = additionalData["actionSelected"] as? String {
                                            if let additionalData = notification?.payload.additionalData {
                                                
                                                // type: chat 이외에는 상단 배너 노티 보여줌
                                                /*
                                                 if let type = additionalData["type"] as? String {
                                                 if let top = UIViewController.topViewController {
                                                 
                                                 var bannerNoti = true
                                                 if type == "chat" {
                                                 let systemMessage = _app.sendBird.containsSystemMsg(message)
                                                 if systemMessage {
                                                 // 시스템 메세지는 noti 하지 않음
                                                 bannerNoti = false
                                                 }
                                                 }
                                                 if bannerNoti {
                                                 AZNotification.showNotificationWithTitle(message, controller: top, notificationType: .Message, shouldShowNotificationUnderNavigationBar: false)
                                                 }
                                                 }
                                                 }
                                                 */
                                                
                                                if let type = additionalData["type"] as? String {
                                                    switch type {
                                                    case "likefavor":   // 좋아요 받음
                                                        _app.historiesViewModel.reload()
                                                    case "chat":
                                                        // chennelViewmodel갱신
                                                        _app.talkChannelsViewModel.reload()
                                                    case "profile":
                                                        // 프로필 심사 update
                                                        //_app.sessionViewModel.reloadMemberInfo()
                                                        let responseViewModel = ApiResponseViewModelBuilder<MemberModel>(successHandler: { [weak self] (memberModel) -> Void in
                                                            _app.sessionViewModel.model = memberModel
                                                            if let loginPoint = memberModel.loginPoint, loginPoint > 0 {
                                                                _app.sessionViewModel.pointAlert = true
                                                            }}).viewModel
                                                        let _ = _app.api.myInfo(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
                                                        self.moveToTabView(type: "voicereply")
                                                        self.moveToTabView(type: type)
                                                    default:
                                                        break
                                                    }
                                                }
                                            }
            },handleNotificationAction:nil,
              settings: onesignalInitSettings)
        

        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;

        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })

        let abc = OneSignal.getPermissionSubscriptionState()
        
        // ga 초기화
        _app.ga.initialize()
        
        // facebook sdk
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions:launchOptions)
        
        // 포인트 지급 알림 (한번)
        _app.sessionViewModel.bind (view: self) { (model, oldModel) -> () in
            guard let loginPoint = _app.sessionViewModel.model?.loginPoint, _app.sessionViewModel.pointAlert && 0 < loginPoint else {
                return
            }
            _app.sessionViewModel.pointAlert = false
            //alert(message: "\(loginPoint)버찌가 무료 지급되었습니다", message: "하루에 한번 로그인시마다 \(loginPoint)버찌가 지급됩니다")
            guard let p = _app.sessionViewModel.model?.loggedDayCount else {
                return
            }
            LoginPointView().show(loggedPoint: p)
        }
        
        // loadingViewModel setting
        let indicatorView = MainLoadingIndicatorView()
        _app.loadingViewModel.bind (view: self) { [weak self] (model, oldModel) -> () in
            guard let superview = self?.window?.rootViewController?.view else {
                return
            }
            if model?.loading == true {
                if indicatorView.superview != superview {
                    if indicatorView.superview != nil {
                        indicatorView.removeFromSuperview()
                    }
                    indicatorView.center = superview.center
                    superview.addSubview(indicatorView)
                    superview.addConstraints(DConstraintsBuilder.constraintsForView(view: indicatorView, size: CGSize(width: getScreenSize().width, height: getScreenSize().height)))
                    superview.addConstraints([
                        DConstraintsBuilder.centerH(view: indicatorView, superview: superview),
                        DConstraintsBuilder.centerV(view: indicatorView, superview: superview)
                        ])
                }
                if let _ = getTopViewController() as? InitializeViewController {
                    indicatorView.stopAnimating()
                }else {
                    indicatorView.startAnimating()
                }
            } else {
                indicatorView.stopAnimating()
            }
        }
        
        // 매 초마다 호출
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(AppDelegate.everySecond), userInfo: nil, repeats: true)
        
        // 매 분마다 호출
        Timer.scheduledTimer(timeInterval: 60 * 10, target: self, selector: #selector(AppDelegate.everyMinute), userInfo: nil, repeats: true)
        
        // 인앱결제 transaction observer 등록
        SKPaymentQueue.default().add(self)
        
        // productIdentifiers 조회
        if SKPaymentQueue.canMakePayments() {
            let productIdentifiers: Set<String> = ["point030", "point080", "point150", "point300", "point600", "point030_event", "point030_event", "point150_event", "point600_event"]
            let request = SKProductsRequest(productIdentifiers: productIdentifiers)
            request.delegate = self
            request.start()
        }
        
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        guard isForeground == false else {
            return
        }
        let userInfo = response.notification.request.content.userInfo
        
        print("Recived: \(userInfo)")

        if let aps = userInfo["custom"] as? NSDictionary {
            print("################ : UserInfo")
            print(userInfo)
            
            print(UIApplication.shared.applicationState)
            
            print("################ : aps")
            print(aps)
            
            if let alert = aps["a"] as? NSDictionary {
                guard let type = alert["type"] as? String else {
                    return
                }
                
                moveToTabView(type: type)
            }
        }
    }
    
    func moveToTabView(type: String) {
        dismissView() { () -> Void in
            DispatchQueue.main.async {
                if let root = self.window!.rootViewController as? UINavigationController {
                    if let topVC = root.childViewControllers.first as? TopViewController {
                        if type == "likefavor" {
                            topVC.moveToNotice()
                        } else if type == "profile" {
                            _app.userDefault.isShowedPromotionPopup = false
                            topVC.moveToStory()
                            topVC.moveToToday()
                        } else if type == "voicereply" {
                            topVC.moveToStory()
                        } else if type == "evaluate" {
                            topVC.moveToEvaluate()
                        }
                    }
                }
            }
        }
    }
    
    func registerAdbrix() {
        updateADID()
        
        IgaworksCore.igaworksCore(withAppKey: "394326299", andHashKey: "c924d2d6a2714be5")
        IgaworksCore.setLogLevel(IgaworksCoreLogTrace)
    }
    
    func updateADID() {
        let adid = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        let isEnable = ASIdentifierManager.shared().isAdvertisingTrackingEnabled
        
        IgaworksCore.setAppleAdvertisingIdentifier(adid, isAppleAdvertisingTrackingEnabled: isEnable)
    }
    
    func handleRemoteNotification(userInfo: [AnyHashable : Any]?) {
        if let aps = userInfo?["custom"] as? NSDictionary {
            print("################ : UserInfo")
            print(userInfo)
            
            print(UIApplication.shared.applicationState)
            
            print("################ : aps")
            print(aps)
            
            if let alert = aps["a"] as? NSDictionary {
                guard let type = alert["type"] as? String else {
                    return
                }
                
                dismissView() { () -> Void in
                    DispatchQueue.main.async {
                        if let root = self.window!.rootViewController as? UINavigationController {
                            if let topVC = root.childViewControllers.first as? TopViewController {
                                if type == "likefavor" {
                                    topVC.moveToNotice()
                                } else if type == "profile" {
                                    topVC.moveToToday()
                                } else if type == "voicereply" {
                                    topVC.moveToStory()
                                } else if type == "evaluate" {
                                    topVC.moveToEvaluate()
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        _app.log.debug(#function)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        _app.log.debug(#function)
        isForeground = false
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        _app.log.debug(#function)
        
        if _app.sessionViewModel.logined {
            // 로그인 정보 갱신
            _app.sessionViewModel.reloadMemberInfo()
            
            // today 리스트 reload
            _app.todayCardsViewModel.reload()
            
            // 평가 reload
            _app.evaluationCardsViewModel.reload()
            
            _app.userVoiceOneViewModel.reload()
            
            // 소식 reload
            _app.historiesViewModel.reload()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        FBSDKAppEvents.activateApp()
        isForeground = true
        _app.log.debug(#function)
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any?) -> Bool {
        _app.log.debug("url: \(url), sourceApplication: \(sourceApplication)")
        
        return FBSDKApplicationDelegate.sharedInstance().application(application,
                                                                     open: url,
                                                                     sourceApplication: sourceApplication,
                                                                     annotation: annotation)
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        _app.log.debug("url: \(url), url: \(url)")
        return true
    }
    
    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.iflet.DateApp" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "DateApp", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendPathComponent("SingleViewCoreData.sqlite")
        
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: nil, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            
            //dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}


extension AppDelegate: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { (transaction) -> () in
            
            _app.log.debug(#function)
            
            //let payment = transaction.payment
            //guard let product = _app.pointsViewModel.getPointModelByProductIdentifier(payment.productIdentifier) else {
            //    return
            //}
            
            switch transaction.transactionState {
            case .purchasing:
                _app.log.debug("paymentQueue: Purchasing")
                break
            case .deferred:
                _app.log.debug("paymentQueue: Deferred")
                break
            case .purchased:
                _app.log.debug("paymentQueue: Purchased")
                // 구매완료, 포인트 지급
                if let receiptURL = Bundle.main.appStoreReceiptURL {
                    
                    do {
                        let receipt = try Data(contentsOf: receiptURL)
                        let responseViewModel = ApiResponseViewModelBuilder<PointValueModel>(successHandlerWithDefaultError: { (response) -> Void in
                            
                            // reload memberinfo
                            _app.sessionViewModel.reloadMemberInfo()
                            
                            SKPaymentQueue.default().finishTransaction(transaction)
                        }).viewModel
                        
                        // 영수증을 이용한 보상 지급 요청
                        let _ = _app.api.pointPaymentIos(receipt: receipt, apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
                        _app.loadingViewModel.model?.del()
                    }catch {
                        _app.loadingViewModel.model?.del()
                    }
                }
                
                
            case .failed:
                _app.log.debug("paymentQueue: Failed")
                // 구매실패
                SKPaymentQueue.default().finishTransaction(transaction)
                _app.loadingViewModel.model?.del()
                alert(message: "구매가 중단됐습니다.")
                
            case .restored:
                _app.log.debug("paymentQueue: Restored")
                break
            default:()
            }
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: NSError) {
        _app.log.debug(#function)
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        _app.log.debug(#function)
    }
}

extension AppDelegate: SKProductsRequestDelegate {
    
    // iap items
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        let products = response.products
        
        var pointsModel:[PointModel] = []
        products.forEach { (product) -> () in
            pointsModel.append(PointModel(product: product))
        }
        // productid 기준으로 정렬
        
        
        pointsModel.sort(by: { (p1, p2) -> Bool in
            return p1.identifier.pointValue() < p2.identifier.pointValue()
        })
        
        _app.pointsViewModel.model = pointsModel
        
        let productList = response.invalidProductIdentifiers
        _app.log.debug("\(productList)")
    }
}

extension AppDelegate {
    func moveTopAfterLoginSuccess() {
        window?.rootViewController = UIViewController.viewControllerFromStoryboard(name: "Main", identifier: "TopContainer")
    }
    
    func moveLobby() {
        window?.rootViewController = UIViewController.viewControllerFromStoryboard(name: "Login", identifier: "LoginNavigationViewController")
    }
    
    func logout() {
        _app.sessionViewModel.removeSession()
        moveLobby()
    }
    
    @objc func everySecond() {
        _app.secondViewModel.model = Date()
    }
    
    @objc func everyMinute() {
        _app.minuteViewModel.model = Date()
    }
    
    func openEmailAppToMasterWithSubject(subject: String, body: String) {
        let email = _app.config.masterEmailAddress
        
        if let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed),
            let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)
        {
            let scheme = "mailto:\(email)?subject=\(subjectEncoded)&body=\(bodyEncoded)"
            if let url = URL(string: scheme) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    alert(message: "이메일 앱을 사용할 수 없습니다.")
                }
            }
        }
        
    }
    
    func openPrivacySetup() {
        let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
        if let url = settingsUrl {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func dismissView(completion: @escaping (()->Void)) {
        dismissViewController()
        dismissVC() {
            [weak self] in
            guard let _ = self else {
                return
            }
            
            completion()
        }
    }
    
    func dismissViewController() {
//        if let root = self.window!.rootViewController as? UINavigationController {
//            let viewControllers = root.viewControllers
//            if let rootVC = viewControllers.first as? RootViewController {
//                rootVC.dismiss(animated:false, completion: nil)
//            }
//        }
        self.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
    func dismissVC(completion: @escaping (()->Void)) {
        if let root = self.window!.rootViewController as? UINavigationController {
            root.popToRootViewController(animated: false, completion: {
                completion()
            })
        }
    }
}

extension UINavigationController {
    
    func pushViewController(viewController: UIViewController,
                            animated: Bool, completion: @escaping (() -> Void) ) {
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
    
    func popToRootViewController(animated: Bool, completion: @escaping (() -> Void)) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popToRootViewController(animated: animated)
        CATransaction.commit()
    }
    
}
