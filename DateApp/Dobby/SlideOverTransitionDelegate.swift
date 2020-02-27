//
//  PresentModallyWithDirectionSegue.swift
//  Dobby
//
//  Created by ryan on 11/23/15.
//  Copyright © 2015 while1.io. All rights reserved.
//

import Foundation

// MARK: - 왼쪽에서 slide로 화면을 덮으면서 나타나는 transition delegate
final class LeftToRightSlideOverTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate, SizeHandlerHasableTransitionDelgate, PresentationControllerPositionDelegate, AnimatedTransitioningPositionDelegate {
    
    // presentationview 의 size 를 정의 합니다.
    var sizeHandler: ((_ parentSize: CGSize) -> CGSize)?
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = PresentationController(presentedViewController: presented, presenting: presenting)
        presentationController.sizeHandler = self.sizeHandler
        presentationController.positionDelegate = self
        return presentationController
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = AnimatedTransitioning()
        animationController.isPresentation = true
        animationController.positionDelegate = self
        return animationController
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = AnimatedTransitioning()
        animationController.isPresentation = false
        animationController.positionDelegate = self
        return animationController
    }
    
    func positionForPresentedView(containerRect: CGRect, presentedRect: CGRect) -> CGPoint {
        return CGPoint(x: 0, y: 0)
    }
    
    func boundaryForPresentedView(containerRect: CGRect, presentedRect: CGRect) -> CGRect {
        let leftBoundary: CGFloat = -presentedRect.width
        let boundary = CGRect(x: leftBoundary, y: 0, width: presentedRect.width - leftBoundary, height: presentedRect.height)
        return boundary
    }
    
    // MAKR: - AnimatedTransitioningPositionDelegate 요청 함수들 구현
    func initialUpperViewPosition(finalFrameForUpper: CGRect) -> CGPoint {
        // 애니메이션 되기전에 시작 포인트 결정 (좌측 화면밖에서 시작하자)
        var point = finalFrameForUpper.origin
        point.x = -finalFrameForUpper.size.width
        return point
    }
}


// MARK: - 오른쪽에서 slide로 화면을 덮으면서 나타나는 transition delegate
final class RightToLeftSlideOverTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate, SizeHandlerHasableTransitionDelgate, PresentationControllerPositionDelegate, AnimatedTransitioningPositionDelegate {
    
    // presentationview 의 size 를 정의 합니다.
    var sizeHandler: ((_ parentSize: CGSize) -> CGSize)?
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = PresentationController(presentedViewController: presented, presenting: presenting)
        presentationController.sizeHandler = self.sizeHandler
        presentationController.positionDelegate = self
        return presentationController
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = AnimatedTransitioning()
        animationController.isPresentation = true
        animationController.positionDelegate = self
        return animationController
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = AnimatedTransitioning()
        animationController.isPresentation = false
        animationController.positionDelegate = self
        return animationController
    }
    
    
    func positionForPresentedView(containerRect: CGRect, presentedRect: CGRect) -> CGPoint {
        return CGPoint(x: containerRect.size.width - presentedRect.size.width, y: 0)
    }
    
    func boundaryForPresentedView(containerRect: CGRect, presentedRect: CGRect) -> CGRect {
        let boundary = presentedRect
        return boundary
    }
    
    func initialUpperViewPosition(finalFrameForUpper: CGRect) -> CGPoint {
        // 애니메이션 되기전에 시작 포인트 결정 (좌측 화면밖에서 시작하자)
        var point = finalFrameForUpper.origin
        point.x += finalFrameForUpper.size.width
        return point
    }
}



class PresentationController: UIPresentationController, UIAdaptivePresentationControllerDelegate {
    var chromeView: UIView = UIView()   // 배경을 반투명하게 가리는 검정 배경
    var positionDelegate: PresentationControllerPositionDelegate?
    var sizeHandler: ((_ parentSize: CGSize) -> CGSize)?

    override init(presentedViewController: UIViewController,
                  presenting presentingViewController: UIViewController?) {
    
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        chromeView.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
        chromeView.alpha = 0.0
        chromeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PresentationController.chromeViewTapped) ))
        
    }
    
    // TODO: svp
    @objc func chromeViewTapped(gesture: UIGestureRecognizer) {
        if(gesture.state == UIGestureRecognizerState.ended) {
            presentingViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    override func size(forChildContentContainer container: UIContentContainer,
                       withParentContainerSize parentSize: CGSize) -> CGSize {
        // 기본적으로는 화면의 33% 할당, sizeHandler 지정되면 handler 에서 지정한 size 로 설정
        if let handler = self.sizeHandler {
            return handler(parentSize)
        }
        let width = parentSize.width / 3.0
        return CGSize(width: width, height: parentSize.height)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        var presentedViewFrame = CGRect.zero
        if let containerBounds = containerView?.bounds {
            presentedViewFrame.size = self.size(forChildContentContainer:self.presentedViewController, withParentContainerSize: containerBounds.size)
            if let positionDelegate = self.positionDelegate {
                presentedViewFrame.origin = positionDelegate.positionForPresentedView(containerRect: containerBounds, presentedRect: presentedViewFrame)
            }
        }
        return presentedViewFrame
    }
    
    override func presentationTransitionWillBegin() {
        if let containerView = self.containerView {
            chromeView.frame = containerView.bounds
            chromeView.alpha = 0.0
            containerView.insertSubview(chromeView, at: 0)
            if let coordinator = presentedViewController.transitionCoordinator {
                coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
                    self.chromeView.alpha = 1.0
                    }, completion: nil)
            } else {
                self.chromeView.alpha = 1.0
            }
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
                self.chromeView.alpha = 0.0
                }, completion: nil)
        } else {
            self.chromeView.alpha = 0.0
        }
    }
    
    override func containerViewWillLayoutSubviews() {
        if let bounds = containerView?.bounds {
            chromeView.frame = bounds
        }
        presentedView?.frame = self.frameOfPresentedViewInContainerView
    }
    
    override var shouldPresentInFullscreen: Bool {
        return true
    }
    
    override var adaptivePresentationStyle: UIModalPresentationStyle {
        return UIModalPresentationStyle.fullScreen
    }
}


final class AnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    var isPresentation = false
    var positionDelegate: AnimatedTransitioningPositionDelegate?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)   // 밑에 깔리는 vc
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)   // 나타날 vc
        let containerView = transitionContext.containerView
        
        if let upperVC = self.isPresentation ? toVC : fromVC {
            let upperView = upperVC.view
            if self.isPresentation {
                containerView.addSubview(upperView!)
            }
            let finalFrameForUpperVC = transitionContext.finalFrame(for: upperVC)
            var initialFrameForUpperVC = finalFrameForUpperVC
            if let positionDelegate = self.positionDelegate {
                initialFrameForUpperVC.origin = positionDelegate.initialUpperViewPosition(finalFrameForUpper: finalFrameForUpperVC)
            }
            
            let initialFrameForUpper = isPresentation ? initialFrameForUpperVC : finalFrameForUpperVC
            let finalFrameForUpper = isPresentation ? finalFrameForUpperVC : initialFrameForUpperVC
            
            upperView?.frame = initialFrameForUpper
            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                delay: 0,
                usingSpringWithDamping: 300.0,
                initialSpringVelocity: 5.0,
                options: UIViewAnimationOptions.allowUserInteraction,
                animations: { () -> Void in
                    upperView?.frame = finalFrameForUpper
                },
                completion: { (value: Bool) -> Void in
                    if !self.isPresentation {
                        upperView?.removeFromSuperview()
                    }
                    transitionContext.completeTransition(true)
            })
        }
    }
}
