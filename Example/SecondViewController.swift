//
//  SecondViewController.swift
//  Example
//
//  Created by Wojtek on 14/07/2015.
//  Copyright © 2015 NSHint. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    let repository = SongsRepository()
    var currentSong = 0
    
    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var originalOrder: [Int] = []
    fileprivate var myOrder: [Int] = []
    
    fileprivate var longPressGesture: UILongPressGestureRecognizer!
    
    var shouldShowBadge = false
    
    var prefix: String! {
        didSet {
            soundController.prefix = prefix
        }
    }
    var pieces: [String]! {
        didSet {
            soundController.songs = pieces
        }
    }

    var soundController = SoundController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getNextSong()
        
        setupSegments()
        setupCollectionView()
        
        soundController.didStartPlaying = { [weak self] in
            self?.collectionView.isUserInteractionEnabled = false
        }
        
        soundController.didStopPlaying = { [weak self] in
            self?.collectionView.isUserInteractionEnabled = true
        }
    //    soundController.playOriginal()
    }
    
    func getNextSong() {
        let song = repository.songs[currentSong]
        prefix = song.prefix
        var songs = [String]()
        for i in 0..<song.pieces.count {
            songs.append(String(i+1))
        }
        self.pieces = songs
    }
    
    func setupSegments() {
        originalOrder = []
        for i in 0..<pieces.count {
            originalOrder.append(i)
        }
        
        myOrder = originalOrder.shuffled()
    }
    
    func setupCollectionView() {
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(SecondViewController.handleLongGesture(_:)))
        longPressGesture.minimumPressDuration = 0
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        stopSong()
        switch(gesture.state) {
            
        case .began:
            guard let selectedIndexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    @IBAction func playOriginal() {
        soundController.playOriginal()
        soundController.didFinishPlayingSong = nil
    }
    
    @IBAction func playInMyOrder() {
        if soundController.playMyOrder(order: myOrder) {
            soundController.didFinishPlayingSong = { [weak self] in
                if self?.currentSong == self!.repository.songs.count - 1 {
                    self?.currentSong = 0
                } else {
                    self?.currentSong += 1
                }
                
                self?.showSuccessAlert()
                
                self?.getNextSong()
                self?.setupSegments()
                self?.collectionView.reloadData()
            }
        } else {
            SCLAlertView().showError("Uh oh!", subTitle: "Try again")
        }
    }
    
    func showSuccessAlert() {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("OK") { [weak self] in
            //          self?.soundController.playOriginal()
            self?.shouldShowBadge = false
            self?.soundController.didFinishPlayingSong = nil
        }
        alertView.showSuccess("Good job!!", subTitle: "You advanced one level")
    }
    
    @IBAction func stopSong() {
        soundController.stop()
    }
}

extension SecondViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myOrder.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! TextCollectionViewCell
        
        let index = myOrder[indexPath.item]
        if cell.noteView.piece == nil {
             cell.setupPieceView(piece: repository.songs[currentSong].pieces[index])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let temp = myOrder.remove(at: sourceIndexPath.item)
        myOrder.insert(temp, at: destinationIndexPath.item)
    }
    
}

extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}


struct Colors {
    static let first = UIColor(red: 172/255, green: 33/255, blue: 127/255, alpha: 1)
    static let second = UIColor(red: 120/255, green: 63/255, blue: 163/255, alpha: 1)
    static let background = UIColor(red: 150/255, green: 100/255, blue: 188/255, alpha: 1)
}
