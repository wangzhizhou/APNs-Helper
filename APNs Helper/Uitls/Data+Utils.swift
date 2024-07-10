//
//  Data+Utils.swift
//  APNs Helper
//
//  Created by joker on 2023/4/5.
//

import Foundation

extension Data {

//    var toArray<T>: [T]  where T:Decodable {
//        if let configs = try? JSONDecoder().decode([T].self, from: self) {
//            return configs
//        } else {
//            return []
//        }
//    }
    
    var toUTF8String: String { String(decoding: self, as: UTF8.self) }
}
