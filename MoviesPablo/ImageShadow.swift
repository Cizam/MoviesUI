//
//  ImageShadow.swift
//  MoviesPablo
//
//  Created by Cesar Zamora on 10/2/16.
//  Copyright © 2016 movil6. All rights reserved.
//

import UIKit

class ImageShadow: UIImageView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.6
        layer.shadowOffset = CGSize(width: 3, height: 3)
    }

}
