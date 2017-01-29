//
//  PieceView.swift
//  Example
//
//  Created by Lucas Coelho on 1/29/17.
//  Copyright © 2017 NSHint. All rights reserved.
//

import UIKit

class PieceView: UIView {

    var piece: Piece!
    
    override func draw(_ rect: CGRect) {
        
        let height: CGFloat = 3
        for note in piece.notes {
            let xOrigin = rect.size.width * note.initialTime
            let width = rect.size.width * note.finalTime - xOrigin
            let yOrigin = rect.size.height - (rect.size.height * note.pitch)
            let noteView = UIView(frame: CGRect(x: xOrigin, y: yOrigin, width: width, height: height))
            noteView.backgroundColor = .white
            addSubview(noteView)
        }
    }
}
