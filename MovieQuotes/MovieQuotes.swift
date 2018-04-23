//
//  MovieQuotes.swift
//  MovieQuotes
//
//  Created by CSSE Department on 4/17/18.
//  Copyright © 2018 CSSE Department. All rights reserved.
//

import UIKit
import Firebase
class MovieQuote: NSObject{//all new
    var id: String?
    var quote: String
    var movie: String
    var created: Date!
    let quoteKey = "quote"
    let movieKey = "movie"
    let createdKey = "created"
    
    init(quote: String, movie: String){
        self.quote = quote
        self.movie = movie
        self.created = Date()
        }
    
    init(documentSnapshot: DocumentSnapshot){
        self.id = documentSnapshot.documentID
        let data = documentSnapshot.data()!
        self.quote = data[quoteKey] as! String
        self.movie = data[movieKey] as! String
        if(data[createdKey] != nil){
            self.created = data[createdKey] as! Date
        }
    }

var data: [String: Any]{
    return [quoteKey: self.quote,
            movieKey: self.movie,
            createdKey: self.createdKey]
}
