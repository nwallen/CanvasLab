 //
//  CanvasViewController.swift
//  CanvasLab
//
//  Created by Nicholas Wallen on 6/1/16.
//  Copyright © 2016 Nicholas Wallen. All rights reserved.
//

import UIKit
 
class CanvasViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var trayView: UIView!
    @IBOutlet weak var trayArrow: UIImageView!
    
    @IBOutlet var faces: [UIImageView]!
    
    var trayOriginalCenter: CGPoint!
    var trayDownOffset: CGFloat!
    var trayUp: CGPoint!
    var trayDown: CGPoint!
   
    
    var newlyCreatedFace: UIImageView!
    var newlyCreatedFaceOriginalCenter: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trayDownOffset = 160
        trayUp = trayView.center
        trayDown = CGPoint(x: trayView.center.x ,y: trayView.center.y + trayDownOffset)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didPanTray(sender: AnyObject) {
        var translation = sender.translationInView(view)
        var velocity = sender.velocityInView(view)
        
        if sender.state == UIGestureRecognizerState.Began {
            trayOriginalCenter = trayView.center
        } else if sender.state == UIGestureRecognizerState.Changed {
            
            var translationAmount = translation.y
            if trayOriginalCenter.y + translation.y <= trayUp.y {
                translationAmount *= 0.1
            }
         
            trayView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + translationAmount)
            
            let rotation = convertValue(trayView.center.y, r1Min: trayDown.y, r1Max: trayUp.y, r2Min: 180, r2Max: 0)

            trayArrow.transform = CGAffineTransformMakeRotation(rotation * CGFloat(M_PI/180))
            
        } else if sender.state == UIGestureRecognizerState.Ended {
            if velocity.y > 0 {
                UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 20, options: [], animations: { () -> Void in
                        self.trayView.center = self.trayDown
                        self.trayArrow.transform = CGAffineTransformMakeRotation(180 * CGFloat(M_PI/180))
                    }, completion: nil)
                
            }else {
                UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: [], animations: { () -> Void in
                    self.trayView.center = self.trayUp
                    self.trayArrow.transform = CGAffineTransformMakeRotation(0 * CGFloat(M_PI/180))
                }, completion: nil)
            }
        }
    }
    
    
    @IBAction func didPanFace(sender: AnyObject) {
        
        var translation = sender.translationInView(view)
        
        if sender.state == UIGestureRecognizerState.Began {
            
            var imageView = sender.view as! UIImageView
            newlyCreatedFace = UIImageView(image: imageView.image)
            view.addSubview(newlyCreatedFace)
            newlyCreatedFace.center = imageView.center
            newlyCreatedFace.center.y += trayView.frame.origin.y
            newlyCreatedFace.originalCoordinates.center = imageView.center
    
            newlyCreatedFaceOriginalCenter = newlyCreatedFace.center
            
            UIView.animateWithDuration(0.2){
                self.newlyCreatedFace.transform = CGAffineTransformMakeScale(1.3, 1.3)
            }
            
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "onCustomPan:")
            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "onCustomPinch:")
            let rotateGestureRecognizer = UIRotationGestureRecognizer(target: self, action: "onCustomRotate:")
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onCustomTap:")
            tapGestureRecognizer.numberOfTapsRequired = 2
            pinchGestureRecognizer.delegate = self
            
            newlyCreatedFace.userInteractionEnabled = true
            newlyCreatedFace.addGestureRecognizer(panGestureRecognizer)
            newlyCreatedFace.addGestureRecognizer(pinchGestureRecognizer)
            newlyCreatedFace.addGestureRecognizer(rotateGestureRecognizer)
            newlyCreatedFace.addGestureRecognizer(tapGestureRecognizer)
            
        } else if sender.state == UIGestureRecognizerState.Changed {
            
            newlyCreatedFace.center = CGPoint(x: newlyCreatedFaceOriginalCenter.x + translation.x, y: newlyCreatedFaceOriginalCenter.y + translation.y)
            
        } else if sender.state == UIGestureRecognizerState.Ended {
            UIView.animateWithDuration(0.2){
                self.newlyCreatedFace.transform = CGAffineTransformMakeScale(1, 1)
            }
            snapFaceToTray(newlyCreatedFace)
        }
            
    }
    
    func onCustomTap(sender: UITapGestureRecognizer) {
        newlyCreatedFace = sender.view as! UIImageView
        newlyCreatedFace.removeFromSuperview()
    }
    
    func onCustomRotate(sender: UIRotationGestureRecognizer) {
        let rotation = sender.rotation
        
        if sender.state == UIGestureRecognizerState.Began {
            newlyCreatedFace = sender.view as! UIImageView
            newlyCreatedFaceOriginalCenter = newlyCreatedFace.center
        } else if sender.state == UIGestureRecognizerState.Changed {
            newlyCreatedFace.transform = CGAffineTransformRotate(newlyCreatedFace.transform, rotation)
            sender.rotation = 0
        } else if sender.state == UIGestureRecognizerState.Ended {
            
        }
    }
    
    func snapFaceToTray(faceView: UIImageView) {
        if faceView.center.y > trayView.frame.origin.y{
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                faceView.center =  CGPoint(x: faceView.originalCoordinates.center.x + self.trayView.frame.origin.x, y: faceView.originalCoordinates.center.y + self.trayView.frame.origin.y)
                    faceView.transform = CGAffineTransformMakeScale(1, 1)
                }, completion: { (Bool) -> Void in
                    faceView.removeFromSuperview()
            })
            
        }
    }
    
    func onCustomPan(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(view)
        
        if sender.state == UIGestureRecognizerState.Began {
            newlyCreatedFace = sender.view as! UIImageView
            newlyCreatedFaceOriginalCenter = newlyCreatedFace.center
        } else if sender.state == UIGestureRecognizerState.Changed {
            newlyCreatedFace.center = CGPoint(x: newlyCreatedFaceOriginalCenter.x + translation.x, y: newlyCreatedFaceOriginalCenter.y + translation.y)
        } else if sender.state == UIGestureRecognizerState.Ended {
            snapFaceToTray(newlyCreatedFace)
        }
    }
    
    func onCustomPinch(sender: UIPinchGestureRecognizer) {
        let scale = sender.scale
        
        if sender.state == UIGestureRecognizerState.Began {
            newlyCreatedFace = sender.view as! UIImageView
            newlyCreatedFaceOriginalCenter = newlyCreatedFace.center
        } else if sender.state == UIGestureRecognizerState.Changed {
            newlyCreatedFace.transform = CGAffineTransformScale(newlyCreatedFace.transform, scale, scale)
            sender.scale = 1
        } else if sender.state == UIGestureRecognizerState.Ended {
           
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        return true
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
