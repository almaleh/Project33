//
//  Whistle.swift
//  Project33
//
//  Created by Besher on 2018-01-20.
//  Copyright © 2018 Besher. All rights reserved.
//

import UIKit
import CloudKit

class Whistle: NSObject {
    var recordID: CKRecordID!
    var genre: String!
    var comments: String!
    var audio: URL!
}
