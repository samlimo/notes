//
//  NoteDefaults.swift
//  Notes
//
//  Created by Samiul Hoque Limo on 7/30/18.
//  Copyright © 2018 Samiul Hoque Limo. All rights reserved.
//

import Foundation

func write(note: Notes) {
    let preferences = UserDefaults.standard
    
    let titleLevel = note.title
    let vLevelKey = "title"
    preferences.set(titleLevel, forKey: titleLevelKey)
    
    let detailsLevel = note.details
    let detailsLevelKey = "details"
    preferences.set(detailsLevel, forKey: detailsLevelKey)
    
    preferences.synchronize()
}
