//
//  Favorites.swift
//  FederalPulse
//
//  Created by Nathan Reed on 1/18/21.
//

import Foundation
import CoreData

class Favorites: DocumentList, DocumentListBlockingRefresh {
    
    private var blockingRefreshUsed = false
    
    //This is the only function we need to override
    //This will load items from core data, create Documents with them, and populate the Documents list
    override func refresh() {
        if !blockingRefreshUsed {
            privateRefresh()
        } else {
            fatalError("non-blocking refresh used on favorites after blocking refresh used!")
        }
        
    }
    
    private func privateRefresh() {
        self._state = .loading
        //Run the BacklogFetchRequest
        let context = AppDelegate.cdContext
        let fetchRequest = AppDelegate.persistentContainer.managedObjectModel.fetchRequestTemplate(forName: "FavoritesFetchRequest") as! NSFetchRequest<FPDocument>
        do {
            let results = try context.fetch(fetchRequest)
            //Create an array of CoreDataStoredDocuments and set the documents list accordingly
            let docs: [CoreDataStoredDocument] = results.map { (fpDoc) -> CoreDataStoredDocument in
                return CoreDataStoredDocument(fpDocument: fpDoc)
            }
            self._documents = docs
            self._state = .ready
            self.loadingDoneCallback?()
            
        } catch {
            print("Unable to get results for backlog when fetching data")
        }
    }
    
    func blockingRefresh() {
        //Register a callback closure that will signal the semaphore and then we block until the callback closure is called
        let sem = DispatchSemaphore(value: 0)
        self.registerLoadingDoneCallback {
            sem.signal()
        }
        self.privateRefresh()
        sem.wait()
    }
}
