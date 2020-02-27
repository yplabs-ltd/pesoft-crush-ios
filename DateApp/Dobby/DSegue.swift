import UIKit

public typealias SizeHandlerFunc = (_ parentSize: CGSize) -> CGSize

public enum DSegueStyle {
    case Show(animated: Bool)           // Push
    case ShowDetail(animated: Bool)     // 화면 전환
    case PresentModally // Modal
    case PresentModallyWithDirection(DSegueDirection, sizeHandler: SizeHandlerFunc)
    case PresentPopup(sizeHandler: SizeHandlerFunc)
    case PresentAsPopover
    case Embed(containerView: UIView?)
}

public enum DSegueDirection {
    case LeftToRight
    case RightToLeft
}

protocol PresentationControllerPositionDelegate {
    func positionForPresentedView(containerRect: CGRect, presentedRect: CGRect) -> CGPoint
}

protocol SizeHandlerHasableTransitionDelgate {
    var sizeHandler: ((_ parentSize: CGSize) -> CGSize)? { get set }
}

protocol AnimatedTransitioningPositionDelegate {
    // animation 시작 되기 전의 초기 위치를 결정해주세요. 해당 위치부터 presentation에 명시한 위치까지 애니메이션 됩니다.
    func initialUpperViewPosition(finalFrameForUpper: CGRect) -> CGPoint
}


public struct DSegue {
    
    public typealias DestinationStyleFunc = () -> (destination: UIViewController, style: DSegueStyle)?
    
    public unowned let source: UIViewController
    private let destinationFunc: DestinationStyleFunc
    weak var segue: UIStoryboardSegue?
    
    private var transitionDelegate: UIViewControllerTransitioningDelegate?
    
    public init(source: UIViewController, destination destinationFunc: @escaping DestinationStyleFunc) {
        self.source = source
        self.destinationFunc = destinationFunc
    }
    
    public mutating func perform() {
        performWithTarget(target: nil, sender: nil)
    }
    public mutating func performWithSender(sender: AnyObject?) {
        performWithTarget(target: nil, sender: sender)
    }
    public mutating func performWithTarget(target: UIViewController?, sender: AnyObject? = nil) {
        
        guard let tuple = destinationFunc() else {
            return
        }
        
        let destination = tuple.destination
        let style = tuple.style
        
        var segue: UIStoryboardSegue?
        
        // self.segue 를 만들어야 합니다.
        switch style {
        case .Show(let animated):
            
            segue = ShowSegue(identifier: nil, source: source, destination: destination)
            if let segue = segue as? ShowSegue {
                segue.animated = animated
            }
            
        case .ShowDetail(let animated):
            
            segue = ShowDetailSegue(identifier: nil, source: source, destination: destination)
            if let segue = segue as? ShowDetailSegue {
                segue.animated = animated
            }
            
        case .PresentModally:
            segue = PresentModallySegue(identifier: nil, source: source, destination: destination)
            
        case .PresentModallyWithDirection(let direction, let sizeHandler) :
            
            switch direction {
            case .LeftToRight:
                transitionDelegate = LeftToRightSlideOverTransitionDelegate()
            case .RightToLeft:
                transitionDelegate = RightToLeftSlideOverTransitionDelegate()
            }
            destination.modalPresentationStyle = .custom
            destination.transitioningDelegate = transitionDelegate
            if var transitioningDelegate = self.transitionDelegate as? SizeHandlerHasableTransitionDelgate {
                transitioningDelegate.sizeHandler = sizeHandler
            }
            
            segue = PresentModallySegue(identifier: nil, source: source, destination: destination)
            
        case .PresentPopup(let sizeHandler):    // popup 창 류
            
            // destination 에 transition delegate 세팅
            transitionDelegate = PopupTransitionDelegate()
            destination.modalPresentationStyle = .custom
            destination.transitioningDelegate = transitionDelegate
            if var transitioningDelegate = transitionDelegate as? SizeHandlerHasableTransitionDelgate {
                transitioningDelegate.sizeHandler = sizeHandler
            }
            
            segue = PresentModallySegue(identifier: nil, source: source, destination: destination)
            
        case .PresentAsPopover:
            
            segue = PresentAsPopoverSegue(identifier: nil, source: source, destination: destination)
            
        case .Embed(let containerView):
            segue = EmbedSegue(identifier: nil, source: source, destination: destination)
            if let segue = segue as? EmbedSegue {
                segue.containerView = containerView
            }
            break
        }
        self.segue = segue
        
        if let segue = segue {
            // prepareForSegue 호출 (sender 가 있으면 sender 로 없으면 source 로)
            if let target = target {
                target.prepare(for: segue, sender: sender)
            } else {
                source.prepare(for: segue, sender: sender)
            }
            segue.perform()
        }
    }
}

extension DSegue: Equatable {
}
public func ==(dsegue1: DSegue, dsegue2: DSegue) -> Bool {
    return dsegue1.segue == dsegue2.segue
}
public func ==(dsegue: DSegue, segue: UIStoryboardSegue) -> Bool {
    return dsegue.segue == segue
}
public func ==(segue: UIStoryboardSegue, dsegue: DSegue) -> Bool {
    return dsegue == segue  // 파라미터 순서 바뀌어도 똑같음
}

final class ShowSegue: UIStoryboardSegue {
    var animated: Bool = true
    override func perform() {
        if let navi = source.navigationController {
            navi.pushViewController(self.destination, animated: animated)
            // hack for swife back (when backbutton changed), back 버튼이 들어가면 swife 뒤로가기가 안되는 문제가 있어서 그것 해결
            // TODO: - xcode7 다시 확인해야함 - navi.interactivePopGestureRecognizer.delegate = navi as? UIGestureRecognizerDelegate
        }
    }
}

final class ShowDetailSegue: UIStoryboardSegue {
    var animated: Bool = true
    override func perform() {
        if let navi = source.navigationController {
            let cnt = navi.viewControllers.count
            var controllers = Array(navi.viewControllers[0..<(cnt-1)])
            controllers.append(destination)
            navi.setViewControllers(controllers, animated: animated)
        }
    }
}

final class PresentModallySegue: UIStoryboardSegue {
    override func perform() {
        source.present(destination, animated: true, completion: nil)
    }
}

final class PresentAsPopoverSegue: UIStoryboardSegue, UIPopoverPresentationControllerDelegate {
    override func perform() {
        destination.modalPresentationStyle = UIModalPresentationStyle.popover
        destination.preferredContentSize = CGSize(width: 100, height: 100)
        if let popoverVC = destination.popoverPresentationController {
            popoverVC.permittedArrowDirections = UIPopoverArrowDirection()
            popoverVC.delegate = self
            popoverVC.sourceView = source.view
            popoverVC.sourceRect = CGRect(x: 100.0, y: 100.0, width: 1, height: 1)
        }
        source.present(destination, animated: true, completion: nil)
    }
    
    // popoverVC.delegate
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}

final class EmbedSegue: UIStoryboardSegue {
    
    weak var containerView: UIView?
    
    override func perform() {
        
        // 기존에 존재하는 child 는 삭제
        containerView?.subviews.forEach({ (v) -> () in
            v.removeFromSuperview()
        })
        source.childViewControllers.forEach { (vc) -> () in
            vc.removeFromParentViewController()
        }
        
        source.addChildViewController(destination)
        containerView?.addSubview(destination.view)
        destination.didMove(toParentViewController: source)
        
        // fill
        containerView?.addConstraints(DConstraintsBuilder.fillView(view: destination.view))
    }
}

