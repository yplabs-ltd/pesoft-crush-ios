//
//  ShopHistoryListViewController+Cell.swift
//  DateApp
//
//  Created by ryan on 1/16/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import UIKit

final class ShopHistoryCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var diffLabel: UILabel!
    @IBOutlet weak var accumulateLabel: UILabel!
    
    var model: PointLogModel? {
        didSet {
            dateLabel.text = model?.regDttmText
            contentLabel.text = model?.description
            diffLabel.text = "\(model?.pointDiff ?? 0)"
            accumulateLabel.text = "\(model?.adjustPoint ?? 0)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}


final class ShopHistoryHeaderView: UIView {
    
    let containerView = UIView()
    let dateLabel = UILabel()
    let contentLabel = UILabel()
    let diffLabel = UILabel()
    let accumulateLabel = UILabel()
    let line = UIView()
    
    init() {
        super.init(frame: CGRect.zero)
        
        backgroundColor = UIColor.white
        
        makeLabel(dateLabel, text: "날짜")
        makeLabel(contentLabel, text: "내역")
        makeLabel(diffLabel, text: "변화")
        makeLabel(accumulateLabel, text: "누적")
        
        containerView.addSubview(dateLabel)
        containerView.addSubview(contentLabel)
        containerView.addSubview(diffLabel)
        containerView.addSubview(accumulateLabel)
        
        addSubview(containerView)
        
        let consts = DConstraintsBuilder()
            .addView(view: dateLabel, name: "dateLabel")
            .addView(view: contentLabel, name: "contentLabel")
            .addView(view: diffLabel, name: "diffLabel")
            .addView(view: accumulateLabel, name: "accumulateLabel")
            .addVFS(
                vfsArray: "H:|[dateLabel(77)][contentLabel][diffLabel(77)][accumulateLabel(52)]|",
                "V:[dateLabel(21)]",
                "V:[contentLabel(21)]",
                "V:[diffLabel(21)]",
                "V:[accumulateLabel(21)]"
            )
            .constraints
        containerView.addConstraints(consts)
        containerView.addConstraint(DConstraintsBuilder.centerV(view: dateLabel, superview: containerView))
        containerView.addConstraint(DConstraintsBuilder.centerV(view: contentLabel, superview: containerView))
        containerView.addConstraint(DConstraintsBuilder.centerV(view: diffLabel, superview: containerView))
        containerView.addConstraint(DConstraintsBuilder.centerV(view: accumulateLabel, superview: containerView))
        
        addConstraints(DConstraintsBuilder.constraintsForView(view: containerView, size: CGSize(width: 343.0, height: 21.0)))
        addConstraint(DConstraintsBuilder.centerH(view: containerView, superview: self))
        addConstraint(DConstraintsBuilder.centerV(view: containerView, superview: self))
        
        // bottom line
        line.backgroundColor = UIColor(rgba: "#ecebea")
        addSubview(line)
        addConstraints(DConstraintsBuilder.constraintsForView(view: line, size: CGSize(width: 343.0, height: 1.0)))
        addConstraint(DConstraintsBuilder.centerH(view: line, superview: self))
        addConstraint(
            NSLayoutConstraint(
                item: line,
                attribute: NSLayoutAttribute.bottom,
                relatedBy: NSLayoutRelation.equal,
                toItem: self,
                attribute: NSLayoutAttribute.bottom,
                multiplier: 1,
                constant: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeLabel(_ label: UILabel, text: String) {
        label.text = text
        label.textColor = UIColor(rgba: "#f2503b")
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textAlignment = .center
    }
}
