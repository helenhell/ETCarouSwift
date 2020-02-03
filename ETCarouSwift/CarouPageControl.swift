//
//  CarouPageControl.swift
//  ETCarouSwift
//
//  Created by Elena Slovushch on 31/01/2020.
//  Copyright © 2020 ElenaSlovushch. All rights reserved.
//

import UIKit

class CarouPageControl: UIPageControl {
    
    var dotSize:CarouDotSize = .small

    init(frame: CGRect, imagesCount:Int, currentPage:Int) {
        
        super.init(frame: frame)
        self.numberOfPages = imagesCount-2
        self.currentPage = currentPage
        self.currentPageIndicatorTintColor = UIColor.black
        self.pageIndicatorTintColor = UIColor.white
        //self.frame.size = sizeThatFits(CGSize(width: 300, height: 200))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setDotSize(_ size:CarouDotSize){
        let targetSize = size.rawValue
        self.transform = CGAffineTransform(scaleX: targetSize, y: targetSize)
        self.dotSize = size
    }

}


public enum CarouDotSize:CGFloat{
    
    case small=1, medium, large
}
