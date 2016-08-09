//
//  ViewController.swift
//  Example
//
//  Created by Mackenzie Boudreau on 8/9/16.
//  Copyright © 2016 Mackenzie Boudreau. All rights reserved.
//

/* Got set up with code from http://binarymosaic.com/custom-video-player-for-ios-with-avfoundation/ */

import UIKit
import AVFoundation

class ViewController: UIViewController {

    let player = AVPlayer()
    var previewLayer: AVPlayerLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        // Set up player
        let url = NSURL(string: "https://content.jwplatform.com/manifests/vM7nH0Kl.m3u8")
        let playerItem = AVPlayerItem(URL: url!)
        player.replaceCurrentItemWithPlayerItem(playerItem)
        
        // Set up preview layer
        previewLayer = AVPlayerLayer(player: player)
        view.layer.insertSublayer(previewLayer!, atIndex: 0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        player.play()
    }
    
    override func viewWillLayoutSubviews() {
        previewLayer?.frame.size.height = self.view.bounds.height / 3
        previewLayer?.frame.size.width = self.view.bounds.width
    }


}

