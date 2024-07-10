//
//  FileProviderItem.swift
//  FileProviderExtension
//
//  Created by joker on 2023/5/17.
//

import FileProvider
import UniformTypeIdentifiers

class FileProviderItem: NSObject, NSFileProviderItem {

    // implement an initializer to create an item from your extension's backing model
    // implement the accessors to return the values from your extension's backing model

    private let identifier: NSFileProviderItemIdentifier

    init(identifier: NSFileProviderItemIdentifier) {
        self.identifier = identifier
    }

    var itemIdentifier: NSFileProviderItemIdentifier {
        return identifier
    }

    var parentItemIdentifier: NSFileProviderItemIdentifier {
        return .rootContainer
    }

    var capabilities: NSFileProviderItemCapabilities {
        return [.allowsReading, .allowsWriting, .allowsRenaming, .allowsReparenting, .allowsTrashing, .allowsDeleting]
    }

    var itemVersion: NSFileProviderItemVersion {
        NSFileProviderItemVersion(contentVersion: Data("a content version".utf8), metadataVersion: Data("a metadata version".utf8))
    }

    var filename: String {
        return identifier.rawValue
    }

    var contentType: UTType {
        return identifier == NSFileProviderItemIdentifier.rootContainer ? .folder : .plainText
    }
}
