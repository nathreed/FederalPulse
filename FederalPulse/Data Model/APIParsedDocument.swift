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
    var title: String
    var abstract: String
    var agencies: String
    var docID: String
    var textURL: URL?
    
    var favorite: Bool {
        didSet {
            if self.storedDoc == nil {
                //Initialize a stored document with ourselves
                //This will grab the new value of favorite in the process
                do {
                    self.storedDoc = try CoreDataStoredDocument(document: self)
                } catch {
                    print("Unable to initialize CoreDataStoredDocument from APIParsedDocument!")
                }
            } else {
                //Just update the favorite property on the stored doc
                self.storedDoc?.favorite = self.favorite
            }
        }
    }
    var backlog: Bool {
        didSet {
            if self.storedDoc == nil {
                //Initialize a stored document with ourselves
                do {
                    self.storedDoc = try CoreDataStoredDocument(document: self)
                } catch {
                    print("Unable to initialize CoreDataStoredDocument from APIParsedDocument!")
                }
            } else {
                //Just update the backlog property on the stored doc
                self.storedDoc?.backlog = self.backlog
            }
        }
    }
    
    //This will be the "backing" CoreDataStoredDocument - it will be populated when the favorite/backlog status is changed
    var storedDoc: CoreDataStoredDocument?
    
    // MARK: - Codable stuff
    
    private enum CodingKeys: String, CodingKey {
        case abstract
        case document_number
        case raw_text_url
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
        self.agencies = agencyArr.joined(separator: ",")
        //Similar approach for the URL - just decode the string first
        let urlText = try container.decode(String.self, forKey: .raw_text_url)
        self.textURL = URL(string: urlText)
        
        self.favorite = false
        self.backlog = false
    }
    
    var description: String {
        get {
            return self.title
        }
    }
    
    
}
