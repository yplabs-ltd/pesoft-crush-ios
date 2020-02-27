//
//  CommonContols.swift
//  DateApp
//
//  Created by ryan on 12/14/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit

struct ActivityIndicatorViewBuilder {
    private(set) var indicatorView: UIActivityIndicatorView
    
    init(centerAtView view: UIView, style: UIActivityIndicatorViewStyle) {
        // view 중앙에 indicator 생성
        indicatorView = UIActivityIndicatorView(activityIndicatorStyle: style)
        indicatorView.isUserInteractionEnabled = false
        view.addSubview(indicatorView)
        view.addConstraints([
            DConstraintsBuilder.centerH(view: indicatorView, superview: view),
            DConstraintsBuilder.centerV(view: indicatorView, superview: view)])
    }
}

struct LabelBuilder {
    private(set) var label: UILabel
    
    init(navigationBar: UINavigationBar, title: String) {
        
        class Label: UILabel {
            override func draw(_ rect: CGRect) {
                let paddingLeft: CGFloat = 10
                super.drawText(in: UIEdgeInsetsInsetRect(rect, UIEdgeInsets(top: 0, left: paddingLeft, bottom: 0, right: 0)))
            }
        }
        
        // navigationBar 기준으로 적당히 좌측 padding 줌
        let titleLabel = Label(frame: navigationBar.frame)
        titleLabel.text = title
        titleLabel.textColor = UIColor(rgba: "#ee5350")
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        label = titleLabel
    }
    
    init(badgeFrame frame: CGRect, text: String) {
        let label = UILabel(frame: frame)
        label.backgroundColor = UIColor(rgba: "#f2503b")
        label.text = text
        label.font = UIFont.systemFont(ofSize: 8.0)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.makeCircleStyle() // 둥글게 처리
        self.label = label
    }
}

struct AlertControllerBuilder {
    private(set) var alertController: UIAlertController
    
    // textfield 를 갖고 있는 입력받기 용 alert
    init(title: String, message: String?, textFieldPlaceholder: String?, defaultText: String?, handler: ((String?) -> ())?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = textFieldPlaceholder
            textField.text = defaultText
        })
        alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            // trim 된 입력값 넘겨준다.
            let trimmed = textField.text?.trim()
            handler?(trimmed)
        }))
        alert.addAction(UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel, handler: nil))
        alertController = alert
    }
}
