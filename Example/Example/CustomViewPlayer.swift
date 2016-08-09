//
//  CustomViewPlayer.swift
//  Example
//
//  Created by Mackenzie Boudreau on 2016-08-09.
//  Copyright © 2016 Mackenzie Boudreau. All rights reserved.
//

import UIKit
import AVFoundation

@IBDesignable class CustomViewPlayer: UIView
{
    
    // MARK: - Private class variables
    private var url: NSURL!
    private var cvPlayer = AVPlayer()
    private var cvPlayerLayer: AVPlayerLayer!
    
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    init (url: String, frame: CGRect)
    {
        super.init(frame: frame)
        
        setupConstraints()
        
        if let tempUrl = NSURL(string: url) {
            self.url = tempUrl
            self.backgroundColor = UIColor.blackColor()
            createPlayer()
        }
    }
    
    private func createPlayer()
    {
        cvPlayerLayer = AVPlayerLayer(player: self.cvPlayer)
        self.layer.insertSublayer(cvPlayerLayer, atIndex: 0)
    }

    private func setupConstraints()
    {
        // todo: setup the constraints for menu, buttons, etc
    }
}
