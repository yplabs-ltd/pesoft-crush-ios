//
//  DConstraintsBuilder.swift
//  Dobby
//
//  Created by ryan on 9/16/15.
//  Copyright (c) 2015 while1.io. All rights reserved.
//

import Foundation

public struct DConstraintsBuilder {
    private var views: [String: AnyObject] = [:]
    private var metrics: [String: AnyObject] = [:]
    private(set) public var constraints: [NSLayoutConstraint] = []
    
    public init() {
        
    }
    
    public func addView(view: AnyObject, name: String) -> DConstraintsBuilder {
        if let view = view as? UIView {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        var const = self
        const.views[name] = view
        return const
    }
    
    // translatesAutoresizingMaskIntoConstraints 변경없이 VFS에서 viewname 만 필요한 경우가 있음
    public func addOnlyViewName(view: AnyObject, name: String) -> DConstraintsBuilder {
        var const = self
        const.views[name] = view
        return const
    }
    
    public func addMetricValue(value: AnyObject, name: String) -> DConstraintsBuilder {
        var const = self
        const.metrics[name] = value
        return const
    }
    
    public func addVFS(vfs: String, options: NSLayoutFormatOptions) -> DConstraintsBuilder {
        var const = self
        let c = NSLayoutConstraint.constraints(withVisualFormat: vfs, options: options, metrics: metrics, views: views)
        const.constraints = const.constraints + c
        return const
    }
    
    public func addVFS(vfsArray: String...) -> DConstraintsBuilder {
        var const = self
        for vfs in vfsArray {
            const = const.addVFS(vfs: vfs, options: NSLayoutFormatOptions(rawValue: 0))
        }
        return const
    }
    
    
    // vfs 로 안되는 부분은 NSLayoutConstraint 를 직접 사용해야함 (center 정렬이 vfs 로 안됨)
    public static func centerH(view: UIView, superview: UIView) -> NSLayoutConstraint {
        view.translatesAutoresizingMaskIntoConstraints = false
        let const =ㅊNSLayoutConstraint(item: view, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: superview, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        return const
    }
    
    public static func centerV(view: UIView, superview: UIView) -> NSLayoutConstraint {
        view.translatesAutoresizingMaskIntoConstraints = false
        let const = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: superview, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        return const
    }
    
    public static func fillView(view: UIView) -> [NSLayoutConstraint] {
        let consts = DConstraintsBuilder()
            .addView(view: view, name: "view")
            .addVFS(vfsArray:
                "H:|[view]|",
                "V:|[view]|"
            ).constraints
        return consts
    }
    
    public static func constraintsForView(view: UIView, size: CGSize) -> [NSLayoutConstraint] {
        let consts = DConstraintsBuilder()
            .addView(view: view, name: "view")
            .addVFS(vfsArray: "H:[view(\(size.width))]", "V:[view(\(size.height))]")
            .constraints
        return consts
    }
}
