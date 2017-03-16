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
    fileprivate var originalOrder: [Int] = [] // correct order 0,1,2, ...
    fileprivate var currentOrder: [Int] = [] // indices of pieces in current order
    
    fileprivate var longPressGesture: UILongPressGestureRecognizer!
    var listOfPieces: [Piece]! // list of pieces
    
    var shouldShowBadge = false
    
    var prefix: String! {
        didSet {
            soundController.prefix = prefix
        }
    }
    var pieces: [String]! {
        didSet {
            soundController.songs = pieces
            listOfPieces = repository.songs[currentSong].pieces
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
    
    /**
     switch to next exercise e.g. next song
     */
    func getNextSong() {
        let song = repository.songs[currentSong]
        prefix = song.prefix
        var songs = [String]()
        for i in 0..<song.pieces.count {
            songs.append(String(i+1))
        }
        self.pieces = songs
    }
    
    /*
     initialize the random order of pieces
     */
    func setupSegments() {
        originalOrder = []
        for i in 0..<pieces.count {
            originalOrder.append(i)
        }
        
        currentOrder = originalOrder.shuffled()
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
        if soundController.playMyOrder(order: currentOrder) { // if order is correct plays the song ang goes to next level
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
        } else { // order is incorrect, so show alert view
            SCLAlertView().showError("Uh oh!", subTitle: "Try again")
            showCorrectPositionBadges()
            //BUG: to debug I would leave this line here, but it shouldn't:
//            collectionView.reloadData()
        }
    }
    
    func showCorrectPositionBadges() {
        
        // if you want the bug not to be visible commnet the following lines
        shouldShowBadge = true
        collectionView.reloadData()
    }
    
    func showSuccessAlert() {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("OK") { [weak self] in
            //          self?.soundController.playOriginal()
            self?.shouldShowBadge = false // hide badges
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
        return currentOrder.count
    }
    
    /*
     called everytime  play puzzle is pressed
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! TextCollectionViewCell
        
        
        // BUG: after calling collectionView.reloadData() this method gets called and the order of the pieces are being displayed incorrectly
        let index: Int = currentOrder[indexPath.item]
        if cell.noteView.piece == nil {
            let piece = listOfPieces[index]
            cell.setupPieceView(piece: piece)
        }
        
        cell.badge.isHidden = !shouldShowBadge
        
        if soundController.getCorrectOrder()[indexPath.item] == currentOrder[indexPath.item] {
            cell.badge.image = #imageLiteral(resourceName: "correct.png")
        } else {
            cell.badge.image = #imageLiteral(resourceName: "non_correct.png")
        }
        print("cellForItemAt")
        return cell
    }
    
    
    /*
     This method is called every time a piece is reordered
     */
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        
        swap(&listOfPieces[sourceIndexPath.item],&listOfPieces[destinationIndexPath.item])
        let temp = currentOrder.remove(at: sourceIndexPath.item)
        currentOrder.insert(temp, at: destinationIndexPath.item)
        
        
        for cell in collectionView.visibleCells {
            if let cell = cell as? TextCollectionViewCell {
                cell.badge.isHidden = true
            }
        }
//        if let cell1 = collectionView.cellForItem(at: sourceIndexPath) as? TextCollectionViewCell,
//            let cell2 = collectionView.cellForItem(at:destinationIndexPath) as? TextCollectionViewCell {
//            cell1.badge.isHidden = true
//            cell2.badge.isHidden = true
//        }
        

    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        // This method is called every time the user tries to move a cell
        print("canMoveItemAt")
        return true
    }
}

extension SecondViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        let sourceIndex = originalIndexPath.item
        let destIndex = proposedIndexPath.item
        (currentOrder[sourceIndex], currentOrder[destIndex]) = (currentOrder[destIndex], currentOrder[sourceIndex])
        (listOfPieces[sourceIndex], listOfPieces[destIndex]) = (listOfPieces[destIndex], listOfPieces[sourceIndex])
        
        return proposedIndexPath
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
