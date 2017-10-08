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
    @IBOutlet weak var videoPlayer: EVSVideoPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoPlayer.setVideoURL("https://content.jwplatform.com/manifests/vM7nH0Kl.m3u8")
        videoPlayer.setVideoTitle("Intergalactics Space Adventure Trailer (2018)");
    }

}

