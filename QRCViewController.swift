	//
//  QRCViewController.swift
//  edX
//
//  Created by Puneeth Kumar  on 10/11/16.
//  Copyright © 2016 edX. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

class QRCViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    
    @IBOutlet weak var lblQRCodeResult: UILabel!
    
    var objCaptureSession:AVCaptureSession?
    var objCaptureVideoPreviewLayer:AVCaptureVideoPreviewLayer?
    var viewQRCodeFrame:UIView?
    
//    var environment: RouterEnvironment?
    lazy var environment = Environment()
    
    
//    static func environmentForQuiz(env : RouterEnvironment) {
//        environment = env
//    }

    struct Environment {
        let analytics = OEXRouter.sharedRouter().environment.analytics
        let config = OEXRouter.sharedRouter().environment.config
        let interface = OEXRouter.sharedRouter().environment.interface
        let networkManager = OEXRouter.sharedRouter().environment.networkManager
        let session = OEXRouter.sharedRouter().environment.session
        let userProfileManager = OEXRouter.sharedRouter().environment.dataManager.userProfileManager
        weak var router = OEXRouter.sharedRouter()
    }
//    static func environmentForQuiz(env : RouterEnvironment) {
//        environment=env }
//    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.configureVideoCapture()
        self.addVideoPreviewLayer()
        self.initializeQRView()
    }


    func configureVideoCapture() {
        //Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        let objCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error:NSError?
        
        let objCaptureDeviceInput: AnyObject!
        
        do {
            //Get an instance of the AVCaptureDeviceInput class using the previous device object.
            objCaptureDeviceInput = try AVCaptureDeviceInput(device: objCaptureDevice) as AVCaptureDeviceInput
        } catch let error1 as NSError {
            error = error1
            objCaptureDeviceInput = nil
            //If any error occurs, just print it out and don't continue any more.
            print(error)
            return
        }
        
        if (error != nil) {
            let alertview:UIAlertView = UIAlertView(title: "Device Error", message: "Device not supported for this Application", delegate: nil, cancelButtonTitle: "Ok Done")
            alertview.show()
            return
        }
        
        //Initialize the objCaptureSession object.
        objCaptureSession = AVCaptureSession()
        //Set the input device on the objCaptureSession.
        objCaptureSession?.addInput(objCaptureDeviceInput as! AVCaptureInput)
        
        //Initialize a AVCaptureMetadataOutput object and set it as the output device to the objCaptureSession.
        let objCaptureMetadataOutput = AVCaptureMetadataOutput()
        objCaptureSession?.addOutput(objCaptureMetadataOutput)
        
        //Set delegate and use the default dispatch queue to execute the call back
        objCaptureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
//        objCaptureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        //Detect the QR Code
        objCaptureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
    }
    
    
    func addVideoPreviewLayer() {
        //Initialize the objCaptureVideoPreviewLayer and add it as a sublayer to the viewPreview view's layer.
        objCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: objCaptureSession)
        objCaptureVideoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        objCaptureVideoPreviewLayer?.frame = view.layer.bounds
        self.view.layer.addSublayer(objCaptureVideoPreviewLayer!)
        
        //Start video capture
        objCaptureSession?.startRunning()
        
        //Move the lblQRCodeResult to the top view
        self.view.bringSubviewToFront(lblQRCodeResult)
    }
    
    
    func initializeQRView() {
        
        //Initialize QR Code Frame(viewQRCode) to highlight the QR Code
        viewQRCodeFrame = UIView()
        
        viewQRCodeFrame?.layer.borderColor = UIColor.greenColor().CGColor
        viewQRCodeFrame?.layer.borderWidth = 5
        
        self.view.addSubview(viewQRCodeFrame!)
        //Move the viewQRCodeFrame subview to the topview
        self.view.bringSubviewToFront(viewQRCodeFrame!)
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        //Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            viewQRCodeFrame?.frame = CGRect.zero
            lblQRCodeResult.text = "No QR Code text detected"
            return
        }
        
        //Get the metadata object.
        let objMetadataMachineReadableCodeObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        //Check if the type of objMetadataMachineReadableCodeObject is AVMetadataObjectTypeQRCode type.
        if objMetadataMachineReadableCodeObject.type == AVMetadataObjectTypeQRCode {
            //If the found metadata is equal to the QR Code metadata then update the status label's text and set the bounds.
            let objQRCode = objCaptureVideoPreviewLayer?.transformedMetadataObjectForMetadataObject(objMetadataMachineReadableCodeObject)
            
            viewQRCodeFrame?.frame = objQRCode!.bounds;
            
            if objMetadataMachineReadableCodeObject.stringValue != nil {
                lblQRCodeResult.text = objMetadataMachineReadableCodeObject.stringValue

                var pointsArr = lblQRCodeResult.text!.componentsSeparatedByString(",")
                
                print("PointsArr = ",pointsArr[0],pointsArr[1])
                
                let courseID: String? = pointsArr[0]
                let BlockID: CourseBlockID? = "block-v1:ASMx+IoT101+2016_T1+type@problem+block@af1b24a0fac947659f976477b43d6ea8"//pointsArr[1]
                
                
//                environment.router?.showCoursewareForCourseWithID(courseID!, blockID: BlockID, fromController: self)
//                environment.router?.showContainerForBlockWithID(BlockID, type: CourseBlockDisplayType.Outline, parentID: nil, courseID: courseID!, fromController: self)
                
//                environment.router?.showCourseForScanID(courseID!, blockID: BlockID, type : CourseBlockDisplayType.Outline, fromController: self)
                environment.router?.showContainerForBlockWithID(BlockID, type:CourseBlockDisplayType.Outline, parentID: "block-v1:ASMx+IoT101+2016_T1+type@vertical+block@125e9907f8fb4a33b60a3125b5799b78", courseID: courseID!, fromController:self)
                
                objCaptureSession?.stopRunning()
            }
            
        }
        
    }

}
    
    
    
    
    //enum CourseHTMLBlockSubkind {
    //    case Base
    //    case Problem
    //}
    //
    //enum CourseBlockDisplayType {
    //    case Unknown
    //    case Outline
    //    case Unit
    //    case Video
    //    case HTML(CourseHTMLBlockSubkind)
    //    case Discussion(DiscussionModel)
    //
    //    var isUnknown : Bool {
    //        switch self {
    //        case Unknown: return true
    //        default: return false
    //        }
    //    }
    //}
    //
    //extension CourseBlock {
    //
    //    var displayType : CourseBlockDisplayType {
    //        switch self.type {
    //        case .Unknown(_), .HTML: return multiDevice ? .HTML(.Base) : .Unknown
    //        case .Problem: return multiDevice ? .HTML(.Problem) : .Unknown
    //        case .Course: return .Outline
    //        case .Chapter: return .Outline
    //        case .Section: return .Outline
    //        case .Unit: return .Unit
    //        case let .Video(summary): return (summary.onlyOnWeb || summary.isYoutubeVideo) ? .Unknown : .Video
    //        case let .Discussion(discussionModel): return .Discussion(discussionModel)
    //        }
    //    }
    //}

    

    
//                environment.router?.showCoursewareForCourseWithID("course-v1:ASMx+IoT101+2016_T1", fromController: self)
    
    //                environment.router?.showCourseForScanID("course-v1:ASMx+IoT101+2016_T1", fromController: self)
    
    
    //                let courseIDInfo : String = ""
    //
    //                environment.router?.showCoursewareForCourseWithID(courseIDInfo, fromController: self)
    
    
    //                environment.router?.showContainerForBlockWithID("af1b24a0fac947659f976477b43d6ea8", type: CourseBlockDisplayType.HTML(problem), parentID: nil, courseID: "course-v1:ASM+CS101+2016_T1", fromController: self)
    
    //                if let url = URL(string: objMetadataMachineReadableCodeObject.stringValue),
    //                    UIApplication.sharedApplication().canOpenURL(url){
    //
    //                    UIApplication.sharedApplication().openURL(url)
    //                }
    
    
    
    //                var vc:QuizViewController?
    //                vc.scanurl=objMetadataMachineReadableCodeObject.stringValue as! AVMetadataMachineReadableCodeObject
    //                self.navigationController?.pushViewController(vc!, animated: true)
    
    
    //                self.environment.router?.showContainerForBlockWithID(block.blockID, type:block.displayType, parentID: parent, courseID: courseQuerier.courseID, fromController:self)
    
    
    
    //                let storyBoard : UIStoryboard = UIStoryboard(name: "Storyboard", bundle:nil)
    //
    //                let vc = storyBoard.instantiateViewControllerWithIdentifier("quizVC") as! QuizViewController
    //                vc.scanUrl = objMetadataMachineReadableCodeObject.stringValue
    //
    //                // If you want to push to new ViewController then use this
    //                self.navigationController?.pushViewController(vc, animated:false)
    
    //                [loginController dismissViewControllerAnimated:YES completion:nil];
