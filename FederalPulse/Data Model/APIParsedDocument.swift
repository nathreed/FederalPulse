//
//  APIParsedDocument.swift
//  FederalPulse
//
//  Created by Nathan Reed on 1/18/21.
//

import Foundation

//Used for decoding document objects directly from the FR API response
//As well as providing conversion facilities to save favorite/backlog status
class APIParsedDocument: Document, Decodable, CustomStringConvertible {
    private var _favorite: Bool
    private var _backlog: Bool
    
    var title: String
    var abstract: String
    var agencies: String
    var docID: String
    var textURL: URL?
    
    var favorite: Bool {
        get {
            //Try to find a doc with our ID, if there is none then return our cached value
            if let doc = CoreDataStoredDocument.searchByDocID(id: self.docID) {
                return doc.favorite
            } else {
                //If it was true, we would have a document created to hold that
                //Since no such document exists, we know it must be false
                return false
            }
        }
        set {
            self._favorite = newValue
            //Find a document by ID of the doc we are trying to update
            //If one doesn't exist, only create one if we are setting the new value to TRUE
            if let doc = CoreDataStoredDocument.searchByDocID(id: self.docID) {
                //Found existing doc, update its favorite
                doc.favorite = newValue
            } else if newValue == true {
                //Only if newValue is true do we bother creating a new doc
                do {
                    let doc = try CoreDataStoredDocument(document: self)
                    doc.favorite = true
                } catch {
                    print("Unable to initialize CoreDataStoredDocument from APIParsedDocument! favorites")
                }
                
            }
        }
    }
    var backlog: Bool {
        get {
            //Try to find a doc with our ID, if there is none then return our cached value
            if let doc = CoreDataStoredDocument.searchByDocID(id: self.docID) {
                return doc.backlog
            } else {
                return false
            }
        }
        set {
            self._backlog = newValue
            //Find a document by ID of the doc we are trying to update
            //If one doesn't exist, only create one if we are setting the new value to TRUE
            if let doc = CoreDataStoredDocument.searchByDocID(id: self.docID) {
                //Found existing doc, update its favorite
                doc.backlog = newValue
            } else if newValue == true {
                //Only if newValue is true do we bother creating a new doc
                do {
                    let doc = try CoreDataStoredDocument(document: self)
                    doc.backlog = true
                } catch {
                    print("Unable to initialize CoreDataStoredDocument from APIParsedDocument! favorites")
                }
                
            }
        }
    }
    
    // MARK: - Codable stuff
    
    private enum CodingKeys: String, CodingKey {
        case abstract
        case document_number
        case html_url
        case title
        case agency_names
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        //self.abstract = try container.decode(String.self, forKey: .abstract)
        self.abstract = try container.decodeIfPresent(String.self, forKey: .abstract) ?? "(no abstract)"
        self.docID = try container.decode(String.self, forKey: .document_number)
        //Create an agencies string by decoding the array, string representation, except without the brackets
        let agencyArr = try container.decode([String].self, forKey: .agency_names)
        self.agencies = agencyArr.joined(separator: ", ")
        //Similar approach for the URL - just decode the string first
        let urlText = try container.decode(String.self, forKey: .html_url)
        self.textURL = URL(string: urlText)
        
        self._favorite = false
        self._backlog = false
    }
    
    var description: String {
        get {
            return self.title
        }
    }
    
    
}
