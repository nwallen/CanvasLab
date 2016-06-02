//
//  Common.swift
//  test
//
//  Created by Timothy Lee on 10/21/14.
//  Copyright (c) 2014 Timothy Lee. All rights reserved.
//

import Foundation
import UIKit

func CGAffineTransformMakeDegreeRotation(rotation: CGFloat) -> CGAffineTransform {
    return CGAffineTransformMakeRotation(rotation * CGFloat(M_PI / 180))
}

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

func convertValue(value: CGFloat, r1Min: CGFloat, r1Max: CGFloat, r2Min: CGFloat, r2Max: CGFloat) -> CGFloat {
    var ratio = (r2Max - r2Min) / (r1Max - r1Min)
    return value * ratio + r2Min - r1Min * ratio
}

// https://medium.com/@ttikitu/swift-extensions-can-add-stored-properties-92db66bce6cd#.49kf15dd1

func associatedObject<ValueType: AnyObject>(
    base: AnyObject,
    key: UnsafePointer<UInt8>,
    initialiser: () -> ValueType)
    -> ValueType {
        if let associated = objc_getAssociatedObject(base, key)
            as? ValueType { return associated }
        let associated = initialiser()
        objc_setAssociatedObject(base, key, associated,
            .OBJC_ASSOCIATION_RETAIN)
        return associated
}

func associateObject<ValueType: AnyObject>(
    base: AnyObject,
    key: UnsafePointer<UInt8>,
    value: ValueType) {
        objc_setAssociatedObject(base, key, value,
            .OBJC_ASSOCIATION_RETAIN)
}

// store original coordinates in any UIView

class OriginalCoordinates {
    var center: CGPoint!
    var size: CGSize!
}

private var orginalCoordinatesKey: UInt8 = 0

extension UIView {
    var originalCoordinates: OriginalCoordinates {
        get {
            return associatedObject(self, key: &orginalCoordinatesKey)
                { return OriginalCoordinates() }
        }
        set { associateObject(self, key: &orginalCoordinatesKey, value: newValue) }
    }
}

