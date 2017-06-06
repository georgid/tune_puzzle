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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        piecesPackground.layer.borderWidth = 1.0
    }
    
    func setupPieceView(piece: Piece) {
        backgroundColor = .clear
        piecesPackground.backgroundColor = Colors.second
        piecesPackground.layer.cornerRadius = 10
        piecesPackground.layer.masksToBounds = true

        noteView.piece = piece
    }
    
    override var isSelected: Bool {
        didSet {
            piecesPackground.layer.borderColor = isSelected ? UIColor.red.cgColor : UIColor.clear.cgColor
            piecesPackground.layer.opacity = isSelected ? 1.0 : 0.8 
        }
    }
}
