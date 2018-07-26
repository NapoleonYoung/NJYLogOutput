//
//  NJYLogDisplayWindow.swift
//  RemoteApp
//
//  Created by 尚轩瑕 on 2018/6/16.
//  Copyright © 2018年 hisense. All rights reserved.
//

import UIKit

class NJYLog {
    var timeBirth:TimeInterval
    var log:NSString
    init() {
        timeBirth = 0
        log = ""
    }

    class func logWith(text:NSString)->NJYLog {
        let log = NJYLog.init()
        log.timeBirth = Date.timeIntervalSinceReferenceDate

        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "HH:mm:ss"
        let dateStr = dateFormatter.string(from: Date.init())
        log.log = NSString.init(format: "%@ : %@", dateStr, text)
        return log
    }
}

class NJYLogDisplayWindow: UIWindow {
    static let shareInstance = NJYLogDisplayWindow.init(frame: CGRect(x:0,y:0,width:UIScreen.main.bounds.size.width, height:UIScreen.main.bounds.size.height))

    private var textView = UITextView()
    private var logs = NSMutableArray()

    /// 打印日志
    class func printLog(with log:NSString) {
        DispatchQueue.main.async {
            shareInstance.printLog(newLog: log)
        }
    }

    class func clearLog(with log:NSString) {
        DispatchQueue.main.async {
            shareInstance.clearLogs()
        }
    }

    private override init(frame: CGRect) {
        super.init(frame: frame)
        self.rootViewController = UIViewController()
        self.windowLevel = UIWindowLevelAlert
        self.backgroundColor = UIColor.init(red: 1.0, green: 0.5, blue: 0.5, alpha: 0.2)
        self.isUserInteractionEnabled = false

        self.textView.frame = self.bounds
        self.textView.font = UIFont.systemFont(ofSize: 12.0)
        self.textView.backgroundColor = UIColor.clear
        self.textView.scrollsToTop = false
        self.addSubview(self.textView)
    }

    private func printLog(newLog: NSString) {
        guard newLog.length > 0 else {
            return
        }

        synchronized(lock: self) {
            let logStr = NSString(format: "%@\n", newLog)
            let logModel = NJYLog.logWith(text: logStr)

            self.logs.add(logModel)
            refreshLogDisplay()
        }
    }

    private func synchronized(lock:AnyObject, closure:()->()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }

    /// 刷新log
    private func refreshLogDisplay() {
        let attributeStr = NSMutableAttributedString.init()
        let currentTimeBirth = Date.timeIntervalSinceReferenceDate
        for log in self.logs {
            let newLog = log as! NJYLog
            let logStr = NSMutableAttributedString.init(string:newLog.log as String)
            let logColor = (currentTimeBirth - newLog.timeBirth) > 0.1 ? UIColor.white : UIColor.blue
            logStr.addAttribute(NSAttributedStringKey.foregroundColor, value: logColor, range: NSMakeRange(0, logStr.length))
            attributeStr.append(logStr)
        }

        self.textView.attributedText = attributeStr

        if attributeStr.length > 0 {
            let bottomRange = NSMakeRange(attributeStr.length - 1, 1)
            self.textView.scrollRangeToVisible(bottomRange)
        }
        
    }

    private func clearLogs() {
        self.textView.attributedText = nil
        self.logs.removeAllObjects()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
