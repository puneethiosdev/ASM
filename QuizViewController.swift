//
//  QuizViewController.swift
//  edX
//
//  Created by Puneeth Kumar  on 11/11/16.
//  Copyright © 2016 edX. All rights reserved.
//

import UIKit

class QuizViewController: UIViewController {

    var scanUrl:String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let webV:UIWebView = UIWebView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height))
//        var string scanUrl
        webV.loadRequest(NSURLRequest(URL: NSURL(string:scanUrl!)!))
        self.view.addSubview(webV)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
