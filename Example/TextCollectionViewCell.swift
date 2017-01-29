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
    
    func setupPieceView(piece: Piece) {
        backgroundColor = .clear
        contentView.backgroundColor = Colors.second
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true

        noteView.piece = piece
    }
}
