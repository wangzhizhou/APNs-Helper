//
//  FileProviderPushPayload.swift
//  APNs Helper
//
//  Created by joker on 2023/5/19.
//

import Foundation
import FileProvider

struct FileProviderPushPayload: Codable {
    let containerID: String = NSFileProviderItemIdentifier.workingSet.rawValue
    let domain: String
    
    enum CodingKeys: String, CodingKey {
        case domain
        case containerID = "container-identifier"
    }
}
