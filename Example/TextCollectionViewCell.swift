//
//  TextCollectionViewCell.swift
//  Example
//
//  Created by Wojtek on 14/07/2015.
//  Copyright © 2015 NSHint. All rights reserved.
//

import UIKit

class TextCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var noteView: PieceView!
    @IBOutlet weak var badge: UIImageView!
    @IBOutlet weak var piecesPackground: UIView!
    
    func setupPieceView(piece: Piece) {
        backgroundColor = .clear
        piecesPackground.backgroundColor = Colors.second
        piecesPackground.layer.cornerRadius = 10
        piecesPackground.layer.masksToBounds = true

        noteView.piece = piece
    }
}
