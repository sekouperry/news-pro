//
//  ISInAppBrowser.swift
//  SwiftInAppBrowswer
//
//  Created by Istvan Szabo on 2014. 12. 28..
//  Copyright (c) 2014. Istvan Szabo. All rights reserved.
//

import UIKit
import MessageUI
import Social

class ISInAppBrowser: UIViewController, UIWebViewDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet var webView: UIWebView!
    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var forwardButton: UIBarButtonItem!
    @IBOutlet weak var progressBar: UIProgressView!
    
    
    var webTitle: String!
    var sidebar: ISFrostedSidebar!
    var webViewLoads:Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.progressBar.hidden = true
        
        
        let url = NSURL(string:webTitle)
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
        
        sidebar = ISFrostedSidebar(itemImages: [
            UIImage(named: "Safari")!,
            UIImage(named: "Facebook")!,
            UIImage(named: "Twitter")!,
            UIImage(named: "SendMail")!,
            UIImage(named: "Dismiss")!],
            colors: [
                UIColor(red: 240/255, green: 159/255, blue: 254/255, alpha: 0.1),
                UIColor(red: 240/255, green: 159/255, blue: 254/255, alpha: 0.1),
                UIColor(red: 255/255, green: 137/255, blue: 167/255, alpha: 0.1),
                UIColor(red: 126/255, green: 242/255, blue: 195/255, alpha: 0.1),
                UIColor(red: 119/255, green: 152/255, blue: 255/255, alpha: 0.1)],
            selectedItemIndices: NSIndexSet(index: 0))
        
        sidebar.isSingleSelect = true
        sidebar.actionForIndex = [
            0: {self.sidebar.dismissAnimated(true, completion: { finished in self.openSafari()}) },
            1: {self.sidebar.dismissAnimated(true, completion: { finished in self.facebookComposer()}) },
            2: {self.sidebar.dismissAnimated(true, completion: { finished in self.twitterComposer()}) },
            3: {self.sidebar.dismissAnimated(true, completion: { finished in self.sendEmail()}) },
            4: {self.sidebar.dismissAnimated(true, completion: { finished in println("Dismiss")}) },]
    }

    
    @IBAction func openFrosted(sender: AnyObject) {
        self.sidebar.showInViewController(self, animated: true)
    }
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func back(sender: AnyObject) {
        webView.goBack()
    }
    
    @IBAction func forw(sender: AnyObject) {
        webView.goForward()
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true);
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("updateStatusBar"), userInfo: nil, repeats: false);
    }
    
    func updateStatusBar() {
       UIApplication.sharedApplication().statusBarHidden=true;
    }
    
    func openSafari() {
        let alert = ISAlertView()
         alert.addButton("Open Safari") {
            println("Open Safari")
            UIApplication.sharedApplication().openURL(NSURL(string:self.webTitle)!);
        }
        alert.showOpenSafari(("Open existing browser"), subTitle:("Please choose") )
    }
    
    func facebookComposer(){
        var controller: SLComposeViewController =
        SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        controller.setInitialText("InAppBrowser")
        controller.addImage(nil)
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func twitterComposer(){
        var controller: SLComposeViewController =
        SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        controller.setInitialText("InAppBrowser")
        controller.addImage(nil)
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        
       activity.startAnimating()
       self.backButton.enabled = self.webView.canGoBack
       self.forwardButton.enabled = self.webView.canGoForward
        if webViewLoads == 0 { self.startLoadingProgressBar() }
        webViewLoads++
        
    }
    
       
    func webViewDidFinishLoad(webView: UIWebView) {
       activity.stopAnimating()
        self.backButton.enabled = self.webView.canGoBack
        self.forwardButton.enabled = self.webView.canGoForward
        webViewLoads--
        if webViewLoads == 0 {
            self.stopLoadingProgressBar()
        }
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        webViewLoads--
    }
    
    var timer:NSTimer!
    var isLoading:Bool!
    
    func startLoadingProgressBar() {
        self.progressBar.hidden = false
        self.progressBar.progress = 0
        isLoading = true
        timer = NSTimer.scheduledTimerWithTimeInterval(0.016667, target: self, selector: "timerCallback", userInfo: nil, repeats: true)
    }
    
    func stopLoadingProgressBar() {
        isLoading = false
    }
    
    func timerCallback() {
        if (isLoading == true) {
            self.progressBar.progress += 0.01
            if self.progressBar.progress > 0.95 { self.progressBar.progress = 0.95 }
        } else {
            if self.progressBar.progress >= 1 {
                timer.invalidate()
                self.progressBar.hidden = true
            } else { self.progressBar.progress += 0.05 }
        }
    }
    
    func sendEmail(){
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["dev@mactech.hu"])     //Customize, add your mail
        mailComposerVC.setSubject("Sending you an in InAppBrowser e-mail...")
        mailComposerVC.setMessageBody("Sending e-mail in InAppBrowser is not so bad!", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

