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
            if let doc = self.storedDoc {
                return doc.favorite
            } else {
                return _favorite
            }
        }
        set {
            self._favorite = newValue
            if self.storedDoc == nil || self.storedDoc!.backingDocDeleted {
                //First try to search by doc ID to see if there's an existing CD doc for us
                if let doc = CoreDataStoredDocument.searchByDocID(id: self.docID) {
                    //We found an existing doc, make it our stored doc and update its favorite
                    self.storedDoc = doc
                    self.storedDoc?.favorite = newValue
                } else {
                    //Initialize a stored document with ourselves
                    //This will grab the new value of favorite in the process
                    do {
                        self.storedDoc = try CoreDataStoredDocument(document: self)
                    } catch {
                        print("Unable to initialize CoreDataStoredDocument from APIParsedDocument! favorites")
                    }
                }
                
            } else {
                //Just update the favorite property on the stored doc
                self.storedDoc?.favorite = newValue
            }
        }
    }
    var backlog: Bool {
        get {
            print("backlog getter!")
            if let doc = self.storedDoc {
                //Check if the doc was deleted
                if(doc.backingDocDeleted) {
                    print("returning stale info for backlog")
                }
                return doc.backlog
            } else {
                return _backlog
            }
        }
        set {
            print("backlog setter!")
            self._backlog = newValue
            if self.storedDoc == nil || self.storedDoc!.backingDocDeleted {
                if let doc = CoreDataStoredDocument.searchByDocID(id: self.docID) {
                    //We found an existing doc, make it our stored doc and update its favorite
                    self.storedDoc = doc
                    self.storedDoc?.backlog = newValue
                    print("BACKLOG SETTER - FOUND CD STORED DOC BY ID!")
                } else {
                    //Initialize a stored document with ourselves
                    //This will grab the new value of favorite in the process
                    do {
                        self.storedDoc = try CoreDataStoredDocument(document: self)
                    } catch {
                        print("Unable to initialize CoreDataStoredDocument from APIParsedDocument! backlog")
                    }
                    print("BACKLOG SETTER - CREATED NEW CD STORED DOC!")
                }
            } else {
                //Just update the backlog property on the stored doc
                self.storedDoc?.backlog = newValue
                print("BACKLOG SETTER - SET BACKLOG on STORED DOC!")
            }
        }
    }
    
    //This will be the "backing" CoreDataStoredDocument - it will be populated when the favorite/backlog status is changed
    var storedDoc: CoreDataStoredDocument?
    
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
