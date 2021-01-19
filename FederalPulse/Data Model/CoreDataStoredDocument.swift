//
//  CoreDataStoredDocument.swift
//  FederalPulse
//
//  Created by Nathan Reed on 1/18/21.
//

import Foundation
import CoreData

class CoreDataStoredDocument: Document {
    let title: String
    let abstract: String
    let agencies: String
    let docID: String
    let textURL: URL?
    var favorite: Bool {
        didSet {
            self.backingFPDoc.favorite = self.favorite
            do {
                try AppDelegate.cdContext.save()
            } catch {
                print("Unable to save context with new favorite value")
            }
            //Check if we need to delete this object (if both favorite and backlog are false)
            if !favorite && !backlog {
                delete()
            }
        }
    }
    
    var backlog: Bool {
        didSet {
            self.backingFPDoc.backlog = self.backlog
            do {
                try AppDelegate.cdContext.save()
            } catch {
                print("Unable to save context with new backlog value")
            }
            
            if !favorite && !backlog {
                delete()
            }
        }
    }
    
    var backingFPDoc: FPDocument
    
    init(fpDocument: FPDocument) {
        self.title = fpDocument.title ?? "(no title)"
        self.abstract = fpDocument.abstract ?? "(no abstract)"
        self.agencies = fpDocument.agencies ?? "(no agencies)"
        self.docID = fpDocument.frDocID ?? "(no document ID)"
        self.textURL = fpDocument.textURL
        self.favorite = fpDocument.favorite
        self.backlog = fpDocument.backlog
        
        self.backingFPDoc = fpDocument
    }
    
    
    //This is used to create and initially save a new stored document from another Document
    //Used by the conversion from APIParsedDocument
    convenience init(document: Document) throws {
        let context = AppDelegate.cdContext
        if let entity = NSEntityDescription.entity(forEntityName: "FPDocument", in: context) {
            let fpDoc = NSManagedObject(entity: entity, insertInto: context) as! FPDocument
            fpDoc.title = document.title
            fpDoc.abstract = document.abstract
            fpDoc.agencies = document.agencies
            fpDoc.frDocID = document.docID
            fpDoc.textURL = document.textURL
            fpDoc.favorite = document.favorite
            fpDoc.backlog = document.backlog
            do {
                try context.save()
            } catch {
                print("Unable to save context with newly added item!")
            }
            self.init(fpDocument: fpDoc)
        } else {
            //Throw an error because we have to get out of here
            //The entity didn't work
            throw NSError(domain: "com.martianpancake.federalpulse.ErrorDomain", code: 1, userInfo: nil)
        }
        
    }
    
    //Delete document entirely - when it's no longer part of the backlog or part of the favorites
    private func delete() {
        let context = AppDelegate.cdContext
        context.delete(self.backingFPDoc)
        do {
            try context.save()
        } catch {
            print("unable to delete document object!")
        }
    }
    
}
