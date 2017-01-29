//
//  SoundController.swift
//  Example
//
//  Created by Lucas Coelho on 1/28/17.
//  Copyright © 2017 NSHint. All rights reserved.
//

import UIKit
import AVFoundation

class SoundController: NSObject {
    
    var songs = ["1","2","3", "4"]
    var didFinishPlayingSong: (()->())?
    
    var didStartPlaying: (()->())?
    var didStopPlaying: (()->())?
    
    var currentIndex = 0 {
        didSet {
            if currentIndex == songs.count {
                currentIndex = 0
            }
        }
    }
    
    var orderToPlaySongs = [0, 1, 2]
    var prefix = "Rihanna"
    var player: AVAudioPlayer?
    
    func playOriginal() {
        didStartPlaying?()
        orderToPlaySongs = getCorrectOrder()
        currentIndex = 0
        playNextSegment()
    }
    
    func playMyOrder(order: [Int]) -> Bool {
        didStartPlaying?()
        orderToPlaySongs = order
        currentIndex = 0
        playNextSegment()
        
        return order == getCorrectOrder()
    }
    
    func getCorrectOrder() -> [Int] {
        var correctOrder = [Int]()
        for i in 0..<songs.count {
            correctOrder.append(i)
        }
        return correctOrder
    }
    
    func stop() {
        didStopPlaying?()
        player?.stop()
    }
    
    func playNextSegment() {
        print("\(prefix)\(songs[orderToPlaySongs[currentIndex]])")
        guard let audioPath = Bundle.main.path(forResource: "\(prefix)\(songs[orderToPlaySongs[currentIndex]])", ofType: "mp3"),
            let url = URL(string: audioPath) else {
                print("error didn't find song")
            return
        }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.delegate = self
        player?.prepareToPlay()
        player?.play()
    }
}
extension SoundController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            currentIndex += 1
            if currentIndex == 0 {
                player.stop()
                didFinishPlayingSong?()
                didStopPlaying?()
                return
            }
        }

        playNextSegment()
    }

}
