//
//  CarouView.swift
//  ETCarouSwift
//
//  Created by Elena Slovushch on 31/01/2020.
//  Copyright © 2020 ElenaSlovushch. All rights reserved.
//

import UIKit

@objc public protocol CarouViewDelegate:NSObjectProtocol{
    
    @objc optional func carouViewDidChangeImage(_ carouView:CarouView, index currentImageIndex:Int)
    @objc optional func carouView(_ carouView:CarouView, didTapImageAt index:Int)
}

let CAROUCELL = "caroucell"

public class CarouView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public weak var delegate:CarouViewDelegate?
    
    private var images:[UIImage]!
    
    private var pageControl:CarouPageControl!
    private var collectionView:CarouCollectionView!
    
    private var currentImageIndex:Int!
    private var timeInterval:Double = 2
    
    private var timer:Timer!
    private var width:CGFloat!
    private var autoScrollEnabled = true
    private var scrollDirection:CarouDirection = .rightToLeft
    
    public var autoRideEnabled:Bool{
        get {
            self.autoScrollEnabled
        }
        set{
            if newValue{
                
                if !self.autoScrollEnabled{
                   self.timer = Timer.scheduledTimer(timeInterval: self.timeInterval, target: self, selector: #selector(timedOut(sender:)), userInfo: nil, repeats: true)
                }
                
            }else{
                self.timer.invalidate()
            }
            self.autoScrollEnabled = newValue
        }
    }
    
    public var dotColor:UIColor{
        get {
            return self.pageControl.pageIndicatorTintColor ?? UIColor.white
        }
        set {
            self.pageControl.pageIndicatorTintColor = newValue
        }
    }
    
    public var currentDotColor:UIColor{
        get {
            return self.pageControl.currentPageIndicatorTintColor ?? UIColor.black
        }
        set {
            self.pageControl.currentPageIndicatorTintColor = newValue
        }
    }
    
    public var carouIndex:Int{
        get {
            return self.visibleImageIndex()
        }
    }
    
    public var dotSize:CarouDotSize{
        get{
            return self.pageControl.dotSize
        }
        set{
            self.pageControl.setDotSize(newValue)
        }
    }
    
    public var showTime:Double{
        get{
            return self.timeInterval
        }
        set {
            guard newValue > 0 else { return }
            self.timeInterval = newValue
            self.timer.invalidate()
            if self.autoScrollEnabled{
                self.timer = Timer.scheduledTimer(timeInterval: self.timeInterval, target: self, selector: #selector(timedOut(sender:)), userInfo: nil, repeats: true)
            }
        }
    }
    
    public init(frame: CGRect, imageSet:[UIImage], rideDirection:CarouDirection = .rightToLeft) {
        super.init(frame: frame)
        
        
        self.images = imageSet
        self.width = frame.width
        
        guard self.images.count > 0 else {
            
            let image = UIImage(color: UIColor.systemBlue, size: frame.size)
            let imageView = UIImageView(image: image)
            imageView.frame = self.bounds
            self.addSubview(imageView)
            return
        }
        
        guard self.images.count > 1 else {
            let imageView = UIImageView(image: self.images[0])
            imageView.frame = self.bounds
            self.addSubview(imageView)
            return
            
        }
        
        self.scrollDirection = rideDirection
        var contentOffsetX = frame.width
        
        if self.scrollDirection == .rightToLeft{
            
            self.currentImageIndex = 1
            
        }else{
            
            self.images = self.images.reversed()
            
            self.currentImageIndex = self.images.count
            
            contentOffsetX = CGFloat(self.images.count)*frame.width
        }
        
        let firstImage = self.images.first!
        let lastImage = self.images.last!
        self.images.append(firstImage)
        self.images.insert(lastImage, at: 0)
        
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: self.frame.width, height: self.frame.height)
        
        
        self.collectionView = CarouCollectionView(frame: self.bounds, collectionViewLayout: layout, imagesCount: self.images!.count, contentOffsetX:contentOffsetX)
        self.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let pageControlFrame = CGRect(x: self.width/2-self.width*0.375, y: frame.height*0.8, width: self.width*0.75, height:frame.height*0.25)
        self.pageControl = CarouPageControl(frame: pageControlFrame, imagesCount: self.images.count, currentPage: self.currentImageIndex-1)
        self.pageControl.addTarget(self, action: #selector(self.pageControlTapped(sender:)), for: .touchDown)
        self.pageControl.addTarget(self, action: #selector(self.pageControlUntapped(sender:)), for: .touchUpInside)
        self.addSubview(self.pageControl)
        
        if self.autoScrollEnabled{
            self.timer = Timer.scheduledTimer(timeInterval: self.timeInterval, target: self, selector: #selector(timedOut(sender:)), userInfo: nil, repeats: true)
        }
    }
     
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
        self.timer.invalidate()
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CAROUCELL, for: indexPath)
        let imageView = UIImageView(image: self.images[indexPath.row])
        imageView.frame = CGRect(origin: CGPoint.zero, size: cell.frame.size)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        cell.addSubview(imageView)
        cell.backgroundColor = UIColor.purple
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let delegate = self.delegate else { return }
        guard delegate.responds(to: #selector(self.delegate?.carouView(_:didTapImageAt:))) else { return }
        delegate.carouView?(self, didTapImageAt: self.visibleImageIndex())
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        self.timer.invalidate()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let contentOffset = CGPoint(x:scrollView.contentOffset.x, y:0)
        let width = scrollView.frame.size.width//scrollView.bounds.size.width
        let index = Int(contentOffset.x/width)
        var currentPage = index-1
        if index == self.images.count-1{
           scrollView.setContentOffset(CGPoint(x: width, y: 0), animated: false)
           currentPage = 0
        }else if index == 0{
            let offsetX = scrollView.contentSize.width-width*2//width * CGFloat(self.images.count-2)
            self.collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
            currentPage = 5
        }
        self.pageControl.currentPage = currentPage
        self.currentImageIndex = index
        
        if self.autoScrollEnabled{
            self.timer = Timer.scheduledTimer(timeInterval: self.timeInterval, target: self, selector: #selector(timedOut(sender:)), userInfo: nil, repeats: true)
        }
        
        guard let delegate = self.delegate else { return }
        guard delegate.responds(to: #selector(self.delegate?.carouViewDidChangeImage(_:index:))) else { return }
        delegate.carouViewDidChangeImage!(self, index: self.visibleImageIndex())
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard let delegate = self.delegate else { return }
        guard delegate.responds(to: #selector(self.delegate?.carouViewDidChangeImage(_:index:))) else { return }
        delegate.carouViewDidChangeImage!(self, index: self.visibleImageIndex())
    }
    
    @objc private func pageControlTapped(sender:UIPageControl){
        self.timer.invalidate()
    }
    
    @objc private func pageControlUntapped(sender:UIPageControl){
        //print("CURRENT PAGE \(sender.currentPage)")
        self.currentImageIndex = sender.currentPage+1
        let offsetX = CGFloat(sender.currentPage+1)*self.frame.size.width
        self.collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        if self.autoScrollEnabled{
            self.timer = Timer.scheduledTimer(timeInterval: self.timeInterval, target: self, selector: #selector(timedOut(sender:)), userInfo: nil, repeats: true)
        }
    }
    
    @objc private func timedOut(sender:Timer){
        
        var nextPage:Int!
        
        if self.scrollDirection == .rightToLeft{
            
            nextPage = self.currentImageIndex
            
            if currentImageIndex == 0{
                self.collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                nextPage = 0
                
            }
            if currentImageIndex == self.images.count-1{
                self.collectionView.setContentOffset(CGPoint(x: self.frame.width, y: 0), animated: false)
                self.currentImageIndex = 1
                nextPage = 1
            }
            
            if currentImageIndex < self.images.count-1 {
                self.currentImageIndex += 1
                let offsetX = CGFloat(self.currentImageIndex)*self.frame.width
                self.collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
                if self.currentImageIndex == self.images.count-1{
                    nextPage = 0
                }
            }
            
        }else{
            
            nextPage = self.currentImageIndex - 2
            
            if currentImageIndex == self.images.count-1{
                nextPage = self.images.count-3
                let offsetX = CGFloat(self.images.count-1)*self.frame.width
                self.collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
            }
            
            if self.currentImageIndex == 0{
                self.currentImageIndex = self.images.count-2
                nextPage = self.currentImageIndex - 2
                let offsetX = CGFloat(self.images.count-2)*self.frame.width
                self.collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
            }
            
            if currentImageIndex > 0 {
                self.currentImageIndex -= 1
                let offsetX = CGFloat(self.currentImageIndex)*self.frame.width
                self.collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
                if self.currentImageIndex == 0{
                    nextPage = self.images.count-3
                }
            }
        }
        self.pageControl.currentPage = nextPage!
    }
    
    private func updateContentOffset(_ offsetX:CGFloat, forView:UICollectionView, completion:()->Void){
        forView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        completion()
    }
    
    private func visibleImageIndex()->Int{
        if self.scrollDirection == .rightToLeft{
            if self.currentImageIndex == 0{
                return self.images.count-3
            }else if self.currentImageIndex == self.images.count-1{
                return 0
            }
            return self.currentImageIndex-1
        }else{
            if self.currentImageIndex == self.images.count-2 || self.currentImageIndex == 0{
                return 0
            }else if self.currentImageIndex == 1 || self.currentImageIndex == self.images.count-1{
                return self.images.count-3
            }
            return self.images.count-2-self.currentImageIndex
        }
    }
}


public enum CarouDirection{
    case leftToRight, rightToLeft
}


extension UIImage {
  
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
