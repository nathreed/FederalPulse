//
//  FRAPIDocumentList.swift
//  FederalPulse
//
//  Created by Nathan Reed on 1/18/21.
//

import Foundation

//This file provides everything needed for a DocumentList subclass that contains all documents of a specific type published on a specific day

enum FRAPIDocumentType: String {
    case rule = "RULE"
    case proposedRule = "PRORULE"
    case notice = "NOTICE"
    case presidentialDocument = "PRESDOCU"
}

struct FRAPIDocumentsResponse: Decodable {
    let count: Int
    let description: String
    let total_pages: Int
    let results: [APIParsedDocument]
}

struct FRAPIDocumentListConfiguration {
    let docType: FRAPIDocumentType
    let searchDate: Date
}

class FRAPIDocumentList: DocumentList {
    
    private var docType: FRAPIDocumentType?
    private var searchDate: Date?
    
    //MUST BE CALLED BEFORE REFRESH and ideally in viewDidLoad of the VC that has us
    public func setConfiguration(config: FRAPIDocumentListConfiguration) {
        self.docType = config.docType
        self.searchDate = config.searchDate
    }
    
    override func refresh() {
        self._state = .loading
        //Setup API call URL
        //First we need the date in the right format
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: self.searchDate!)
        
        
        let apiURL = "https://www.federalregister.gov/api/v1/documents.json?fields%5B%5D=abstract&fields%5B%5D=agency_names&fields%5B%5D=document_number&fields%5B%5D=raw_text_url&fields%5B%5D=title&per_page=500&order=newest&conditions%5Bpublication_date%5D%5Bis%5D=\(dateString)&conditions%5Btype%5D%5B%5D=\(self.docType!.rawValue)"
        
        //Fetch the responses
        //This will set the ready state and call the callback so we're done in this refresh method
        //Don't send duplicate requests when we are already loading
        if(self._state == .loading) {
            self.fetchResponses(urlString: apiURL)
        }
    }
    
    private func decodeResponses(from data: Data) {
        //Setup the decode: it's mostly going to be APIParsedDocuments however there is some outer stuff
        //this is handled by the struct above
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(FRAPIDocumentsResponse.self, from: data)
            //Grab the documents list from the result and make it our documents list
            //Then update the status and send the callback
            self._documents = result.results
            self._state = .ready
            self.loadingDoneCallback?()
        } catch {
            print("Error in decoding! \(error)")
        }
        
    }
    
    private func fetchResponses(urlString: String) {
        if let url = URL(string: urlString) {
            let task = URLSession(configuration: .default).dataTask(with: url) { (data, res, error) in
                guard let respData = data else {
                    print("ERROR fetching data!")
                    return
                }
                self.decodeResponses(from: respData)
            }
            task.resume()
            
        } else {
            //Failure in URL format?
            print("bad url format in fetchResponses!")
            self._state = .ready
            self.loadingDoneCallback?()
        }
    }
}
