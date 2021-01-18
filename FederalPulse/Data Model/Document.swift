//
//  Document.swift
//  FederalPulse
//
//  Created by Nathan Reed on 1/18/21.
//

import Foundation

protocol Document {
    var title: String { get }
    var abstract: String { get }
    var agencies: String { get }
    var docID: String { get }
    var textURL: URL? { get }
    var favorite: Bool {get set}
    var backlog: Bool {get set}
}
