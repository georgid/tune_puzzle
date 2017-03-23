//
//  SongsRepository.swift
//  Example
//
//  Created by Lucas Coelho on 1/29/17.
//  Copyright © 2017 NSHint. All rights reserved.
//

import UIKit

class SongsRepository {
    
    var songs = [Song]()
    
    init() {
        self.getAllSongs()
    }
    
    func getAllSongs() {
        guard let path = Bundle.main.path(forResource: "Rihanna", ofType: "json"),
            let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
            let jsonResult = try? JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) else {
                print("errror on loading JSON")
                return
        }
        
        print("not errror")

        if let allSongsArray = JSON(jsonResult).array {
            for songJson in allSongsArray {
                songs.append(Song(json: songJson))
            }
        }
    }
}
