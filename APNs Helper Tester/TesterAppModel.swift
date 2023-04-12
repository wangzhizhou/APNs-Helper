//
//  TesterAppModel.swift
//  APNs Helper Tester
//
//  Created by joker on 2022/11/30.
//

import UIKit

class TesterAppModel: ObservableObject {
    
    @Published
    var deviceToken: String = ""
    
    @Published
    var pushKitToken: String = ""
    
    @Published
    var showAlert: Bool = false
    
    var alertMessage: String = "" {
        didSet {
            showAlert = true
        }
    }
    
    func copyToPasteboard(content: String) {
        UIPasteboard.general.string = content
    }
}
