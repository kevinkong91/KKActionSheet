//
//  KKActionSheet
//
//  Created by Kevin Kong on 12/9/15.
//  Copyright © 2015 Kevin Kong. All rights reserved.
//
//  Inspired by and modeled after Coloors UI

import Foundation
import UIKit

class KKActionSheet: UIViewController {

    // Blur View
    var blurView: UIVisualEffectView!
    var iconView: UIImageView!
    var defaultIconName:String = "default"
    
    var actionSheetView: UIView!
    var titleLabel: UILabel!
    var closeButton: UIButton!
    var noticeLabel: UILabel!
    var selectionContainerView: UIView!
    var doneButton:UIButton!
    
    let padding:CGFloat = 10
    
    var viewWidth:CGFloat!
    var viewHeight:CGFloat!
    
    var actionSheetHeight:CGFloat = 250
    
    var defaultColor:UIColor = UIColor(red:0.2, green:0.6, blue:0.73, alpha:1)      // Light Blue - Boston Blue
    var darkTextColor:UIColor = UIColor(red:0.12, green:0.35, blue:0.48, alpha:1)   // Navy Blue - Blumine
    var lightTextColor:UIColor = UIColor(red:0.2, green:0.6, blue:0.73, alpha:1).colorWithAlphaComponent(0.6)      // Light Blue - Boston Blue

    var closeButtonColor:UIColor = UIColor(red:1, green:0.44, blue:0.43, alpha:1)   // Pastel Red
    
    var actionEnabled:Bool = false
    
    var buttonTitleColor:UIColor = UIColor(red:0.12, green:0.35, blue:0.48, alpha:1)   // Navy Blue - Blumine
    var cancelButtonTitleColor:UIColor = UIColor(red:0.12, green:0.35, blue:0.48, alpha:1).colorWithAlphaComponent(0.6)
    var buttonColor:UIColor = UIColor(red:0.12, green:0.35, blue:0.48, alpha:1)
    var cancelButtonColor: UIColor = UIColor(red:0.12, green:0.35, blue:0.48, alpha:1).colorWithAlphaComponent(0.7)
    
    
    var titleFont:String = "HelveticaNeue-Bold"
    var textFont:String = "HelveticaNeue"
    var buttonFont:String = "HelveticaNeue-Bold"
    
    var titleSize:CGFloat = 14
    var textSize:CGFloat = 13
    var buttonSize:CGFloat = 12
    var cancelButtonSize:CGFloat = 10
    
    enum ActionType {
        case Close, Cancel
    }
    
    var closeAction:(()->Void)?
    var cancelAction:(()->Void)?
    var isAlertOpen:Bool = false
    
    weak var rootViewController: UIViewController!
    
    
    // Allow alerts to be closed/renamed in a chainable manner
    class ActionSheetResponder {
        let actionSheet: KKActionSheet
        
        init(actionSheet: KKActionSheet) {
            self.actionSheet = actionSheet
        }
        
        func addAction(action: ()->Void) {
            self.actionSheet.addAction(action)
        }
        
        func addCancelAction(action: ()->Void) {
            self.actionSheet.addCancelAction(action)
        }
        
        @objc func close() {
            self.actionSheet.closeView(false)
        }
    }

    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let size = self.screenSize()
        self.viewWidth = size.width
        self.viewHeight = size.height
        
        
        // TOP - Blur View
        
        if self.blurView != nil {
            self.blurView.frame = CGRectMake(0, 0, viewWidth, viewHeight)
        }
        
        if self.iconView != nil {
            self.iconView.frame.size = CGSizeMake(100, 100)
            self.iconView.center = CGPointMake(viewWidth / 2, (viewHeight - actionSheetHeight) / 2)
        }
        
        
        
        // BOTTOM - Action Sheet
        
        var yPos:CGFloat = 0
        
        if self.actionSheetView != nil {
            self.actionSheetView.frame = CGRectMake(0, self.view.frame.height - self.actionSheetHeight, self.view.frame.width, self.actionSheetHeight)
        }
        
        if self.titleLabel != nil {
            self.titleLabel.frame = CGRectMake(0, padding * 2, self.view.frame.width, 12)
            yPos += (padding * 4 + self.titleLabel.frame.height)
        }
        
        if self.closeButton != nil {
            self.closeButton.frame = CGRectMake(15, 15, 15, 15)
        }
        
        if self.noticeLabel != nil {
            self.noticeLabel.frame = CGRectMake(10, yPos, view.frame.width - 20, 18)
            yPos += self.noticeLabel.frame.height
        }
        
        if self.selectionContainerView != nil {
            self.selectionContainerView.frame = CGRectMake(0, yPos, view.frame.width, 150)
        }
        
        if self.doneButton != nil {
            self.doneButton.frame = CGRectMake(0, self.actionSheetView.frame.height - 44, self.view.frame.width, 44)
        }
        
        
    }

    
    
    func display(viewController: UIViewController, selectionView: UIView, title: String, text: String?=nil, buttonText: String?=nil, color: UIColor?=nil, iconImage: UIImage?=nil) -> ActionSheetResponder {
        
        self.rootViewController = viewController//.view.window!.rootViewController
        self.rootViewController.addChildViewController(self)
        self.rootViewController.view.addSubview(view)
        
        
        if self.blurView == nil {
            
            // Create black blur
            let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            self.blurView = UIVisualEffectView(effect: darkBlur)
            
            // Tap gesture
            let tapGesture = UITapGestureRecognizer(target:self, action: "cancelButtonTap")
            self.blurView.addGestureRecognizer(tapGesture)
            
            
            self.view.addSubview(blurView)
        }
        
        if self.iconView == nil {
            
            self.iconView = UIImageView()
            iconView.image = UIImage(named:defaultIconName)
            iconView.tintColor = UIColor.whiteColor()
            iconView.alpha = 0
            
            self.view.addSubview(iconView)
            
            iconView.fadeIn()
        }
        
        
        let sz = self.screenSize()
        self.viewWidth = sz.width
        self.viewHeight = sz.height
        
        self.view.frame.size = sz
        
        // Container for the entire alert modal contents
        self.actionSheetView = UIView()
        self.actionSheetView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.actionSheetView!)
        
        
        
        // Title
        self.titleLabel = UILabel()
        titleLabel.text = title.uppercaseString
        titleLabel.textColor = self.darkTextColor
        titleLabel.font = UIFont.systemFontOfSize(self.titleSize)
        //titleLabel.font = UIFont(name: self.titleFont, size: self.titleSize)
        titleLabel.textAlignment = .Center
        self.actionSheetView.addSubview(titleLabel)
        
        
        // Close Button
        self.closeButton = UIButton()
        closeButton.setImage(UIImage(named: "x-mark")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        closeButton.tintColor = self.closeButtonColor
        closeButton.addTarget(self, action: "cancelButtonTap", forControlEvents: .TouchUpInside)
        closeButton.alpha = 0
        
        
        // Notice Label
        self.noticeLabel = UILabel()
        noticeLabel.textColor = self.lightTextColor
        noticeLabel.textAlignment = .Center
        noticeLabel.font = UIFont.systemFontOfSize(self.textSize)
        //noticeLabel.font = UIFont(name: self.textFont, size: self.textSize)
        noticeLabel.numberOfLines = 2
        noticeLabel.alpha = 0
        
        if let text = text {
            noticeLabel.text = text
            actionSheetView.addSubview(noticeLabel)
            
            
            noticeLabel.fadeIn()
        }
        
        
        // Container for selections
        self.selectionContainerView = selectionView
        actionSheetView.addSubview(selectionContainerView)
        
        
        // Done Button
        self.doneButton = UIButton()
        //self.transformActionButton("Cancel", titleColor: cancelButtonTitleColor, font: UIFont(name: buttonFont, size: cancelButtonSize)!, backgroundColor: cancelButtonColor)
        doneButton.addTarget(self, action: "cancelButtonTap", forControlEvents: .TouchUpInside)
        actionSheetView.addSubview(doneButton)
        
        
        
        
        // Animate it in
        
        // Hide Nav/Tab Bars
        self.navigationController?.navigationBar.hidden = true
        self.tabBarController?.tabBar.hidden = true
        
        // Fade In
        self.view.fadeIn(0.3, delay: 0, completion: nil)
        
        // Push in
        
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.5, options: [.CurveEaseInOut], animations: { () -> Void in
            
            self.actionSheetView.frame.origin.y -= self.actionSheetHeight
            
            
            }, completion: nil)
        
        
        
        isAlertOpen = true
        return ActionSheetResponder(actionSheet: self)
    }
    
    
    func addBlurIcon(name: String) {
        if let image = UIImage(named:name) as UIImage? {
            self.iconView.image = image
        }
    }
    
    func addAction(action: ()->Void) {
        self.closeAction = action
    }
    
    func addCancelAction(action: ()->Void) {
        self.cancelAction = action
    }
    
    func showNotification(text: String, size: CGFloat?=nil) {
        
        
        self.noticeLabel.text = text.uppercaseString
        if let size = size {
            noticeLabel.font = UIFont.systemFontOfSize(size)
            //noticeLabel.font = UIFont(name: textFont, size: size)
        }
        self.actionSheetView.addSubview(noticeLabel)
        
        
        // Show label briefly
        self.noticeLabel.fadeIn(0.3, delay: 1.5, completion: { done in
            self.noticeLabel.fadeOut(0.3, delay: 4, completion: { done in
                self.noticeLabel.removeFromSuperview()
            })
        })
    }
    
    func showCloseButton() {
        // Add X button
        self.actionSheetView.addSubview(closeButton)
        self.closeButton.fadeIn(0.2, delay: 0, completion: nil)
    }
    
    func enableAction() {
        
        // action status
        self.actionEnabled = true
        
        // Button UI
        self.toggleButton()
        
        // Button actions
        self.doneButton.removeTarget(self, action: "cancelButtonTap", forControlEvents: .TouchUpInside)
        self.doneButton.addTarget(self, action: "buttonTap", forControlEvents: .TouchUpInside)
        
        showCloseButton()
    }
    
    func disableAction() {
        
        // action status
        self.actionEnabled = false
        
        // Button UI
        self.toggleButton()
        
        // Button actions
        self.doneButton.removeTarget(self, action: "buttonTap", forControlEvents: .TouchUpInside)
        self.doneButton.addTarget(self, action: "cancelButtonTap", forControlEvents: .TouchUpInside)
        
        // Remove X button
        self.closeButton.fadeOut(0.2, delay: 0, completion: { (finished) -> Void in
            self.closeButton.removeFromSuperview()
        })
    }
    
    // Toggle between Cancel/Continue
    func toggleButton() {
        
        if self.actionEnabled == true {
            //UIFont(name: buttonFont, size: buttonSize)!
            self.transformActionButton("Continue", titleColor: buttonTitleColor, font: UIFont.systemFontOfSize(self.buttonSize), backgroundColor: buttonColor)
            
        } else {
            //UIFont(name: buttonFont, size: cancelButtonSize)!
            self.transformActionButton("Cancel", titleColor: cancelButtonTitleColor, font: UIFont.systemFontOfSize(self.cancelButtonSize), backgroundColor: cancelButtonColor)
            
        }
    }
    
    func transformActionButton(title: String, titleColor: UIColor, font: UIFont, backgroundColor: UIColor) {
        
        self.doneButton.setTitle(title.uppercaseString, forState: .Normal)
        self.doneButton.setTitleColor(titleColor, forState: .Normal)
        //self.doneButton.titleLabel!.font = font
        self.doneButton.backgroundColor = backgroundColor
        
    }
    
    
    func buttonTap() {
        closeView(true, source: .Close);
    }
    
    func cancelButtonTap() {
        closeView(true, source: .Cancel);
    }
    
    func closeView(withCallback:Bool, source:ActionType = .Close) {
        
        self.view.fadeOut(0.2, delay: 0, completion: { finished in
            
            // Show Nav/Tab Bars
            self.navigationController?.navigationBar.hidden = false
            self.tabBarController?.tabBar.hidden = false
            

            // Callback
            if withCallback {
                if let action = self.closeAction where source == .Close {
                    action()
                }
                else if let action = self.cancelAction where source == .Cancel {
                    action()
                }
            }
            self.removeView()
        })
        
        UIView.animateWithDuration(0.2, animations: {
            
            // Push Out
            self.actionSheetView.frame.origin.y = self.view.frame.height
            
            }, completion: nil)
    }
    
    func removeView() {
        isAlertOpen = false
        self.removeFromParentViewController()
        self.view.removeFromSuperview()
    }
    
    

    private func screenSize() -> CGSize {
        let screenSize = UIScreen.mainScreen().bounds.size
        if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) && UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation) {
            return CGSizeMake(screenSize.height, screenSize.width)
        }
        return screenSize
    }

        


}


//
// EXTENSIONS
//


extension UIView {
    
    // Fade in
    
    func fadeIn(duration: NSTimeInterval = 0.2, delay: NSTimeInterval = 0.0, completion: ((Bool) -> Void)? = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.alpha = 1.0
            }, completion: completion)  }
    
    // Fade out
    
    func fadeOut(duration: NSTimeInterval = 0.2, delay: NSTimeInterval = 0.0, completion: ((Bool) -> Void)? = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.alpha = 0.0
            }, completion: completion)
    }
}
