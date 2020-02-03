//
//  ViewController.swift
//  ETCarouSwiftDemo
//
//  Created by Elena Slovushch on 01/02/2020.
//  Copyright © 2020 ElenaSlovushch. All rights reserved.
//

import UIKit
import ETCarouSwift

class ViewController: UIViewController{
    
    var carouView:CarouView!
    
    let images = [UIImage(named: "1")!,
                  UIImage(named: "2")!,
                  UIImage(named: "3")!,
                  UIImage(named: "4")!,
                  UIImage(named: "5")!]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let frame = CGRect(x: self.view.frame.width*0.05, y: self.view.frame.height*0.2, width: self.view.frame.width*0.9, height: self.view.frame.height*0.4)
        
        self.carouView = CarouView(frame: frame, imageSet: self.images, rideDirection: .rightToLeft)
        self.carouView.delegate = self
        self.carouView.showTime = 2
        self.carouView.dotColor = UIColor.gray
        self.carouView.currentDotColor = UIColor.systemBlue
        self.carouView.dotSize = .medium
        self.carouView.layer.borderColor = UIColor.darkGray.cgColor
        self.carouView.layer.borderWidth = 2
        self.view.addSubview(self.carouView)
    }
}

//MARK: - CAROU VIEW DELEGATE
extension ViewController:CarouViewDelegate{
    
    func carouViewDidChangeImage(_ carouView: CarouView, index currentImageIndex: Int) {
        
        print(self.images[currentImageIndex].description)
    }
    
    func carouView(_ carouView: CarouView, didTapImageAt index: Int) {
        
        if index > 0{
            carouView.autoRideEnabled = !carouView.autoRideEnabled
        }
    }
}
