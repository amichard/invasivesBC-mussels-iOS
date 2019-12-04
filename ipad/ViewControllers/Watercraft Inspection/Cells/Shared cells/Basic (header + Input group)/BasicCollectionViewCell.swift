//
//  BasicCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-04.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class BasicCollectionViewCell: UICollectionViewCell, Theme {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var leadingMargin: NSLayoutConstraint!
    @IBOutlet weak var trailingMargin: NSLayoutConstraint!
    
    weak var inputGroup: UIView?
    
    var showBox = false
    var showDivider = true
    var extraPadding: CGFloat = 0
    var boxPadding: CGFloat = 8
    
    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }
    
    public func setup(title: String, input items: [InputItem], delegate: InputDelegate, boxed: Bool? = false, showDivider: Bool? = true, padding: CGFloat? = 0) {
        self.inputGroup?.removeFromSuperview()
        
        self.extraPadding = padding ?? 0
        self.showBox = boxed ?? false
        self.showDivider = showDivider ?? true
        style()
        
        self.titleLabel.text = title
        
        let inputGroup: InputGroupView = InputGroupView()
        self.inputGroup = inputGroup
        inputGroup.initialize(with: items, delegate: delegate, in: container)
    }
    
    private func style() {
        styleSectionTitle(label: titleLabel)
        styleBox()
        styleDivider()
    }
    
    private func styleBox() {
        if showBox {
            self.layer.cornerRadius = 3
            self.layer.borderWidth = 1
            self.layer.borderColor = UIColor(red:0.8, green:0.81, blue:0.82, alpha:1).cgColor
            self.leadingMargin.constant = boxPadding + extraPadding
            self.trailingMargin.constant = boxPadding + extraPadding
        } else {
            self.leadingMargin.constant = extraPadding
            self.trailingMargin.constant = extraPadding
            self.layer.borderWidth = 0
        }
    }
    
    private func styleDivider() {
        if showDivider {
            divider.alpha = 1
            styleDivider(view: divider)
        } else {
            divider.alpha = 0
        }
    }
    
}
