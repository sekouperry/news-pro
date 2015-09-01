//
//  ISAlertView.swift
//

import Foundation
import UIKit

public enum ISAlertViewStyle {
    case OpenSafari
}
public enum ISActionType {
	case None, Selector, Closure
}
public class ISButton: UIButton {
	var actionType = ISActionType.None
	var target:AnyObject!
	var selector:Selector!
	var action:(()->Void)!
	
	
    public init() {
        super.init(frame: CGRectZero)
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override public init(frame:CGRect) {
        super.init(frame:frame)
    }
}

public class ISAlertViewResponder {
    let alertview: ISAlertView
    
    public init(alertview: ISAlertView) {
		self.alertview = alertview
	}
	
    public func setTitle(title: String) {
		self.alertview.labelTitle.text = title
	}
	
    public func setSubTitle(subTitle: String) {
		self.alertview.viewText.text = subTitle
	}
	
    public func close() {
		self.alertview.hideView()
	}
}

let kCircleHeightBackground: CGFloat = 62.0

public class ISAlertView: UIViewController {
    let kDefaultShadowOpacity: CGFloat = 0.7
    let kCircleTopPosition: CGFloat = -12.0
    let kCircleBackgroundTopPosition: CGFloat = -15.0
	let kCircleHeight: CGFloat = 56.0
    let kCircleIconHeight: CGFloat = 56.0
	let kTitleTop:CGFloat = 24.0
	let kTitleHeight:CGFloat = 40.0
    let kWindowWidth: CGFloat = 240.0
    var kWindowHeight: CGFloat = 178.0
	var kTextHeight: CGFloat = 90.0
	
   
    let kDefaultFont = "HelveticaNeue"
	let kButtonFont = "HelveticaNeue-Bold"
    
    var viewColor = UIColor()
    var pressBrightnessFactor = 0.85
    var baseView = UIView()
    var labelTitle = UILabel()
    var viewText = UITextView()
    var contentView = UIView()
    var circleBG = UIView(frame:CGRect(x:0, y:0, width:kCircleHeightBackground, height:kCircleHeightBackground))
	var circleView = UIView()
    var circleIconImageView = UIImageView()
    var durationTimer: NSTimer!
	private var inputs = [UITextField]()
	private var buttons = [ISButton]()
	
    required public init(coder aDecoder: NSCoder) {
        fatalError("Error")
    }
    
    required public init() {
        super.init(nibName:nil, bundle:nil)
        
        view.frame = UIScreen.mainScreen().bounds
        view.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        view.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:kDefaultShadowOpacity)
        view.addSubview(baseView)
        
        baseView.frame = view.frame
        baseView.addSubview(contentView)
        
        contentView.backgroundColor = UIColor(white:1, alpha:1)
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 0.5
        contentView.addSubview(labelTitle)
        contentView.addSubview(viewText)
        
        circleBG.backgroundColor = UIColor.whiteColor()
        circleBG.layer.cornerRadius = circleBG.frame.size.height / 2
        baseView.addSubview(circleBG)
        circleBG.addSubview(circleView)
        circleView.addSubview(circleIconImageView)
        var x = (kCircleHeightBackground - kCircleHeight) / 2
        circleView.frame = CGRect(x:x, y:x, width:kCircleHeight, height:kCircleHeight)
        circleView.layer.cornerRadius = circleView.frame.size.height / 2
        x = (kCircleHeight - kCircleIconHeight) / 2
        circleIconImageView.frame = CGRect(x:x, y:x, width:kCircleIconHeight, height:kCircleIconHeight)
        
        labelTitle.numberOfLines = 1
        labelTitle.textAlignment = .Center
        labelTitle.font = UIFont(name: kDefaultFont, size:20)
        labelTitle.frame = CGRect(x:12, y:kTitleTop, width: kWindowWidth - 24, height:kTitleHeight)
       
        viewText.editable = false
        viewText.textAlignment = .Center
        viewText.textContainerInset = UIEdgeInsetsZero
        viewText.textContainer.lineFragmentPadding = 0;
        viewText.font = UIFont(name: kDefaultFont, size:14)
        
        contentView.backgroundColor = UIColor(white:1, alpha:1)
        labelTitle.textColor = UIColor.blackColor()
        viewText.textColor = UIColor.blackColor()
        contentView.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var sz = UIScreen.mainScreen().bounds.size
        let sver = UIDevice.currentDevice().systemVersion as NSString
        let ver = sver.floatValue
        if ver < 8.0 {
           
            if UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation) {
                let ssz = sz
                sz = CGSize(width:ssz.height, height:ssz.width)
            }
        }
        // Set background frame
        view.frame.size = sz
        // Set frames
        var x = (sz.width - kWindowWidth) / 2
        var y = (sz.height - kWindowHeight -  (kCircleHeight / 8)) / 2
        contentView.frame = CGRect(x:x, y:y, width:kWindowWidth, height:kWindowHeight)
        y -= kCircleHeightBackground * 0.6
        x = (sz.width - kCircleHeightBackground) / 2
        circleBG.frame = CGRect(x:x, y:y+6, width:kCircleHeightBackground, height:kCircleHeightBackground)
        // Subtitle
        y = kTitleTop + kTitleHeight
        viewText.frame = CGRect(x:12, y:y, width: kWindowWidth - 24, height:kTextHeight)
        // Text fields
        y += kTextHeight + 14.0
        for txt in inputs {
            txt.frame = CGRect(x:12, y:y, width:kWindowWidth - 24, height:30)
            txt.layer.cornerRadius = 3
            y += 40
        }
        // Buttons
        for btn in buttons {
            btn.frame = CGRect(x:12, y:y, width:kWindowWidth - 24, height:35)
            btn.layer.cornerRadius = 3
            y += 45.0
        }
    }
    
    override public func touchesEnded(touches:Set<NSObject>, withEvent event:UIEvent) {
        if event.touchesForView(view)?.count > 0 {
            view.endEditing(true)
        }
    }
    
    public func addTextField(title:String?=nil)->UITextField {
        // Update view height
        kWindowHeight += 40.0
        // Add text field
        let txt = UITextField()
        txt.borderStyle = UITextBorderStyle.RoundedRect
        txt.font = UIFont(name:kDefaultFont, size: 14)
        txt.autocapitalizationType = UITextAutocapitalizationType.Words
        txt.clearButtonMode = UITextFieldViewMode.WhileEditing
        txt.layer.masksToBounds = true
        txt.layer.borderWidth = 1.0
        if title != nil {
            txt.placeholder = title!
        }
        contentView.addSubview(txt)
        inputs.append(txt)
        return txt
    }
    
    public func addButton(title:String, action:()->Void)->ISButton {
        let btn = addButton(title)
        btn.actionType = ISActionType.Closure
        btn.action = action
        btn.addTarget(self, action:Selector("buttonTapped:"), forControlEvents:.TouchUpInside)
        btn.addTarget(self, action:Selector("buttonTapDown:"), forControlEvents:.TouchDown | .TouchDragEnter)
        btn.addTarget(self, action:Selector("buttonRelease:"), forControlEvents:.TouchUpInside | .TouchUpOutside | .TouchCancel | .TouchDragOutside )
        return btn
    }
    
    public func addButton(title:String, target:AnyObject, selector:Selector)->ISButton {
        let btn = addButton(title)
        btn.actionType = ISActionType.Selector
        btn.target = target
        btn.selector = selector
        btn.addTarget(self, action:Selector("buttonTapped:"), forControlEvents:.TouchUpInside)
        btn.addTarget(self, action:Selector("buttonTapDown:"), forControlEvents:.TouchDown | .TouchDragEnter)
        btn.addTarget(self, action:Selector("buttonRelease:"), forControlEvents:.TouchUpInside | .TouchUpOutside | .TouchCancel | .TouchDragOutside )
        return btn
    }
    
    private func addButton(title:String)->ISButton {
        
        kWindowHeight += 45.0
        
        let btn = ISButton()
        btn.layer.masksToBounds = true
        btn.setTitle(title, forState: .Normal)
        btn.titleLabel?.font = UIFont(name:kButtonFont, size: 14)
        contentView.addSubview(btn)
        buttons.append(btn)
        return btn
    }
    
    func buttonTapped(btn:ISButton) {
        if btn.actionType == ISActionType.Closure {
            btn.action()
        } else if btn.actionType == ISActionType.Selector {
            let ctrl = UIControl()
            ctrl.sendAction(btn.selector, to:btn.target, forEvent:nil)
        } else {
            println("Unknow action type for button")
        }
        hideView()
    }
    
    
    func buttonTapDown(btn:ISButton) {
        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0
        btn.backgroundColor?.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        btn.backgroundColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    func buttonRelease(btn:ISButton) {
        btn.backgroundColor = viewColor
    }
    
   

    public func showOpenSafari(title: String, subTitle: String, closeButtonTitle:String?=nil, duration:NSTimeInterval=0.0) -> ISAlertViewResponder {
        return showTitle(title, subTitle: subTitle, duration: duration, completeText:closeButtonTitle, style: .OpenSafari)
    }
    
    
    public func showTitle(title: String, subTitle: String, style: ISAlertViewStyle, closeButtonTitle:String?=nil, duration:NSTimeInterval=0.0) -> ISAlertViewResponder {
        return showTitle(title, subTitle: subTitle, duration:duration, completeText:closeButtonTitle, style: style)
    }
    
   
    public func showTitle(title: String, subTitle: String, duration: NSTimeInterval?, completeText: String?, style: ISAlertViewStyle) -> ISAlertViewResponder {
        view.alpha = 0
        let rv = UIApplication.sharedApplication().keyWindow! as UIWindow
        rv.addSubview(view)
        view.frame = rv.bounds
        baseView.frame = rv.bounds
        
        // Alert colour/icon
        viewColor = UIColor()
        var iconImage: UIImage
        
        // Icon style
        switch style {
        case .OpenSafari:
            viewColor = UIColor(white:1, alpha:1)
            iconImage =  UIImage(named:"Safari")!
       
        }
        
        // Title
        if !title.isEmpty {
            self.labelTitle.text = title
        }
        
        // Subtitle
        if !subTitle.isEmpty {
            viewText.text = subTitle
            // Adjust text view size, if necessary
            let str = subTitle as NSString
            let attr = [NSFontAttributeName:viewText.font]
            let sz = CGSize(width: kWindowWidth - 24, height:90)
            let r = str.boundingRectWithSize(sz, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes:attr, context:nil)
            let ht = ceil(r.size.height)
            if ht < kTextHeight {
                kWindowHeight -= (kTextHeight - ht)
                kTextHeight = ht
            }
        }
        
        
        let txt = completeText != nil ? completeText! : "Cancel"
        addButton(txt, target:self, selector:Selector("hideView"))
        
       
        self.circleView.backgroundColor = viewColor
        self.circleIconImageView.image  = iconImage
        for txt in inputs {
            txt.layer.borderColor = viewColor.CGColor
        }
        for btn in buttons {
            btn.backgroundColor = viewColor
            if style == ISAlertViewStyle.OpenSafari {
                btn.setTitleColor(UIColor.blackColor(), forState:UIControlState.Normal)
            }
        }
        
        
        if duration > 0 {
            durationTimer?.invalidate()
            durationTimer = NSTimer.scheduledTimerWithTimeInterval(duration!, target: self, selector: Selector("hideView"), userInfo: nil, repeats: false)
        }
        
                self.baseView.frame.origin.y = -400
        UIView.animateWithDuration(0.2, animations: {
            self.baseView.center.y = rv.center.y + 15
            self.view.alpha = 1
            }, completion: { finished in
                UIView.animateWithDuration(0.2, animations: {
                    self.baseView.center = rv.center
                })
        })
       
        return ISAlertViewResponder(alertview: self)
    }
    
    
    public func hideView() {
        UIView.animateWithDuration(0.2, animations: {
            self.view.alpha = 0
            }, completion: { finished in
                self.view.removeFromSuperview()
        })
    }
    
   
    
}

