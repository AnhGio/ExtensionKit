//
//  UIControl+Vendor.swift
//  ExtensionKit
//
//  Created by Moch Xiao on 1/5/16.
//  Copyright © @2016 Moch Xiao (https://github.com/cuzv).
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import SnapKit

// MARK: - SegmentedToggleControl

public class SegmentedToggleControl: UIControl {
    private let items: [String]
    private var buttons: [UIButton] = []
    private let normalTextColor: UIColor
    private let selectedTextColor: UIColor
    private var font: UIFont!
    private var currentSelectedIndex = 0
    private var animated: Bool = true
    
    public var selectedSegmentIndex: Int {
        get { return self.currentSelectedIndex }
        set {
            self.animated = false
            let index = newValue >= self.items.count ? self.items.count - 1 : newValue
            self.hanleClickAction(self.buttons[index])
            self.animated = true
        }
    }
    
    let lineView: UIView = {
        let view = UIView()
        return view
    }()
    
    public init(items: [String], normalTextColor: UIColor = UIColor.blackColor(), selectedTextColor: UIColor = UIColor.tintColor) {
        if items.count < 2 {
            fatalError("items.count can not less 2.")
        }
        
        self.items = items
        self.normalTextColor = normalTextColor
        self.selectedTextColor = selectedTextColor
        super.init(frame: CGRectZero)
        setup()
    }
    
    override private init(frame: CGRect) {
        fatalError("Use init(actionHandler:) instead.")
    }
    
    private init() {
        fatalError("Use init(actionHandler:) instead.")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func intrinsicContentSize() -> CGSize {
        // Calculate text size
        let str = self.items.reduce("") { (str1, str2) -> String in
            return "\(str1)\(str2)"
        }
        if let font = self.font {
            var size = str.sizeWithFont(font)
            size.width += CGFloat(self.items.count * 12)
            size.height = size.height >= 44 ? size.height : 44
            return size
        } else {
            return CGSizeMake(60, 44)
        }
    }
}

public extension SegmentedToggleControl {
    private func setup() {
        var lastButton: UIButton!
        let count = self.items.count
        for i in 0 ..< count {
            // Make button
            let button = UIButton(type: .System)
            button.tag = i
            button.addTarget(self, action: "hanleClickAction:", forControlEvents: .TouchUpInside)
            button.title = self.items[i]
            button.setTitleColor(normalTextColor, forState: .Normal)
            button.setTitleColor(selectedTextColor, forState: .Selected)
            button.tintColor = UIColor.whiteColor()
            self.addSubview(button)
            
            // Set position
            button.snp_makeConstraints(closure: { (make) -> Void in
                make.top.equalTo(self)
                make.bottom.equalTo(self)
                if let lastButton = lastButton {
                    make.left.equalTo(lastButton.snp_right)
                    make.width.equalTo(lastButton.snp_width)
                } else {
                    make.left.equalTo(self)
                }
                
                if i == count - 1 {
                    make.right.equalTo(self)
                }
            })
            
            lastButton = button
            
            self.buttons.append(button)
        }
        
        self.font = lastButton.titleLabel?.font
        
        if let firstButton = self.buttons.first {
            firstButton.selected = true
            
            self.addSubview(lineView)
            lineView.backgroundColor = self.selectedTextColor
            lineView.snp_makeConstraints { (make) -> Void in
                make.width.equalTo(self.lineViewWidthForIndex(0))
                make.height.equalTo(1)
                make.centerX.equalTo(firstButton)
                make.bottom.equalTo(self)
            }
        }
    }
    
    internal func hanleClickAction(sender: UIButton) {
        // toggle selected button
        buttons.forEach { (button) -> () in
            button.selected = false
        }
        sender.selected = true
        
        // Move lineView
        if let index = buttons.indexOf(sender) {
            lineView.snp_remakeConstraints(closure: { (make) -> Void in
                make.width.equalTo(self.lineViewWidthForIndex(index))
                make.height.equalTo(1)
                make.bottom.equalTo(self)
                let currentButton = buttons[index]
                make.centerX.equalTo(currentButton)
            })
            
            let duration: NSTimeInterval = self.animated ? fabs(Double(currentSelectedIndex - index)) * 0.1 : 0
            if duration <= 0 {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            } else {
                UIView.animateWithDuration(duration, animations: { () -> Void in
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                })
            }
        }
        currentSelectedIndex = sender.tag
        
        // Send action
        self.sendActionsForControlEvents(.ValueChanged)
    }
    
    private func lineViewWidthForIndex(index: Int) -> CGFloat {
        return self.items[index].sizeWithFont(self.font).width
    }
}