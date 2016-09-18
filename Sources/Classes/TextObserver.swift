//
//  TextObserver.swift
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

// MARK: - TextObserver

final public class TextObserver {
    fileprivate let maxLength: Int
    fileprivate let actionHandler: ((Int) -> ())
    fileprivate var textFieldObserver: NSObjectProtocol?
    fileprivate var textViewObserver: NSObjectProtocol?
    
    public init(maxLength: Int, actionHandler: @escaping ((Int) -> ())) {
        self.maxLength = maxLength
        self.actionHandler = actionHandler
    }
    
    deinit {        
        if let textFieldObserver = textFieldObserver {
            NotificationCenter.default.removeObserver(textFieldObserver)
        }
        
        if let textViewObserver = textViewObserver {
            NotificationCenter.default.removeObserver(textViewObserver)
        }
    }
    
    // MARK: - UITextField
    
    public func observe(_ object: UITextField) {
        textFieldObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.UITextFieldTextDidChange,
            object: object,
            queue: OperationQueue.main) { [weak self] (notification) -> Void in
                guard let _self = self else { return }
                guard let textField = notification.object as? UITextField else { return }
                guard let text = textField.text else { return }
                
                let textLenght = text.length
                if textLenght > _self.maxLength && nil == textField.markedTextRange {
                    textField.text = text.substring(toIndex: _self.maxLength)
                }
                
                _self.actionHandler(_self.maxLength - (textField.text ?? "").length)
            }
    }
    
    // MARK: - UITextView
    
    public func observe(_ object: UITextView) {
        textViewObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.UITextViewTextDidChange,
            object: object,
            queue: OperationQueue.main) { [weak self] (notification) -> Void in
                guard let _self = self else { return }
                guard let textView = notification.object as? UITextView else { return }
                guard let text = textView.text else { return }
                
                let textLenght = text.length
                if textLenght > _self.maxLength && nil == textView.markedTextRange {
                    textView.text = text.substring(toIndex: _self.maxLength)
                }
                
                _self.actionHandler(_self.maxLength - (textView.text ?? "").length)
                textView.scrollCursorToVisible()
            }
    }
    
}
