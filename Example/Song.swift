//
//  Song.swift
//  Example
//
//  Created by Lucas Coelho on 1/29/17.
//  Copyright © 2017 NSHint. All rights reserved.
//

import UIKit

struct Song {
    var prefix: String!
    var pieces = [Piece]()
}

struct Piece {
    var notes = [Note]()
}

struct Note {
    var initialTime: CGFloat!
    var finalTime: CGFloat!
    var pitch: CGFloat!
}

extension Song {
    init(json: JSON) {
        prefix = json["name"].stringValue
        if let piecesJson = json["pieces"].array {
            for pieceJson in piecesJson {
                var piece = Piece()
                for note in pieceJson.arrayValue {
                    piece.notes.append(Note(json: note))
                }
                pieces.append(piece)
            }
        }
    }
}

extension Note {
    init(json: JSON) {
        if json.count == 3 {
            initialTime = CGFloat(json[0].floatValue)
            finalTime = CGFloat(json[1].floatValue)
            pitch = CGFloat(json[2].floatValue)
        }
    }
}
