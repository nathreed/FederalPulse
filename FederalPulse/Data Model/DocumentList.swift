//
//  DocumentList.swift
//  FederalPulse
//
//  Created by Nathan Reed on 1/18/21.
//

import Foundation

enum DocumentListState {
    case loading
    case ready
}

//A model for representing a list of documents from the FR API.
//Can be configured to provide documents from store (favorites/backlog) or API (FR browse)
//Basically: The proper subclass of this model should be inited with the VC and a callback should be registered for when loading is done
//The VC should display a loading indicator until the callback is called, at which point it should reload the table view data from the documents property
class DocumentList {
    //Documents list: privately gettable/settable, only publicly gettable
    var _documents = [Document]()
    public var documents: [Document] {
        get {
            return _documents
        }
    }
    
    //Again, private setter, public getter for state
    //Default value for state is loading
    var _state: DocumentListState = .loading
    public var state: DocumentListState {
        get {
            return _state
        }
    }
    
    var loadingDoneCallback: (() -> Void)?
    
    public func registerLoadingDoneCallback(callback: @escaping () -> Void) {
        self.loadingDoneCallback = callback
    }
    
    //Refresh the underlying data (whether that's from the API or the data store) and cause the loading callback to be called when done loading
    public func refresh() {
        
    }
    
}
