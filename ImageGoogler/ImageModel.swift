//
//  ImageModel.swift
//  imageGoogler
//
//  Created by Radha Phani Krishna Sunkara on 26/10/18.
//  Copyright © 2018 Radha Phani Krishna Sunkara. All rights reserved.
//

import Foundation

/// Model object to keep image data
class ImageModel {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: NSNumber
    let title: String
    let isPublic: Bool
    
    init?(with dict:[String: Any]) {
        guard let idValue = dict["id"] as? String else { return nil }
        guard let ownerValue = dict["owner"] as? String else { return nil }
        guard let secretValue = dict["secret"] as? String else { return nil }
        guard let serverValue = dict["server"] as? String else { return nil }
        guard let farmValue = dict["farm"] as? NSNumber else { return nil }
        guard let titleValue = dict["title"] as? String else { return nil }
        guard let isPublicValue = dict["ispublic"] as? Bool else { return nil }
        
        id = idValue
        owner = ownerValue
        secret = secretValue
        server = serverValue
        farm = farmValue
        title = titleValue
        isPublic = isPublicValue
    }
}
