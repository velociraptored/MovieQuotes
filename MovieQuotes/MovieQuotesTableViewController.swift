//
//  MovieQuotesTableViewController.swift
//  MovieQuotes
//
//  Created by CSSE Department on 3/29/18.
//  Copyright © 2018 CSSE Department. All rights reserved.
//

import UIKit
import CoreData
import Firebase//

class MovieQuotesTableViewController: UITableViewController {
    var quoteRef: CollectionReference!//
    var quotesListener: ListenerRegistration//
    
    let movieQuoteCellIdentifier = "MovieQuoteCell"
    let noMovieQuotesCellIdentifier = "NoMovieQuotesCell"
    var movieQuotes = [MovieQuote]()
    
    var context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showAddDialog))
        navigationItem.leftBarButtonItem = self.editButtonItem
        quotesRef = Firestore.firestore().collecction("quotes")//
        
    }
    
    func save(){
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    override func viewWillDisappear(_ animated: Bool) {//
        super.viewWillDisappear(animated)//
        quotesListener.remove()//
    }//
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //tableview.reloadData()//
       //quotesListener = quoteRef.addSnapshotListener({(querySnapshot,error)})
        quotesListener = quotesRef.order(by: "created", decending: true).limit(to: 50).addSnapshotListener({ (querySnapshot , error) in//
            guard let snapshot = querySnapshot else {//
                print("error fetching quotes, error: \(error?.localizedDescription)")//
            }//
        })//
        snapshot.documentChanges.forEach{(docChange) in//
            if(docChange.type == .added){//
                print("new quote: \(docChange.document.data())")//
                self.quoteAdded(docChange.document)//
            } else if(docChange.type == .modified){//
                print("mod quote: \(docChange.document.data())")//
                self.quoteUpdated(docChange.document)//
            } else {//
                    print("deleted quote: \(docChange.document.data())")//
                    self.quoteRemoved(docChange.document)//
            }//
            self.movieQuotes.sord(by: {(mq1, mq2) -> Bool in//
                return mq1.created > mq2.created//
            })//
            self.tableView.reloadData()//
        }//
        self.updateMovieQuoteArray()
    }
    
    func quoteAdded(_ document: DocumentSnapshot){//
        let newMovieQuote = MovieQuote(documentSnapshot: document)//
        moveQuotes.append(newMovieQuote)//
    }//
    func quoteUpdated(_ document: DocumentSnapshot){//
        let modifiedMovieQuote = MovieQuote(documentSnapshot: document)
        
        for movieQuote in movieQuotes{//
            if(movieQuote.id == modifiedMovieQuote.id){//
                movieQuote.quote = modifiedMovieQuote.quote//
                movieQuote.movie = modifiedMovieQuote.movie//
                break//
            }//
        }//
    }//
    func quoteRemoved(_ document: DocumentSnapshot){//
        for i in 0..<movieQuotes.count{//createa
            if movieQuotes[i].id == document.documentID{
                movieQuotes.remove(at: i)
                break
            }
        }//
    }//
    
    func updateMovieQuoteArray(){
        let request: NSFetchRequest<MovieQuote> = MovieQuote.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "created", ascending: false)]
        do{
            movieQuotes = (try context.fetch(request))
        } catch {
            fatalError("bad\(error)")
        }
    }
    
    @objc func showAddDialog(){
        let alertController = UIAlertController(title: "Create a new movie quote",
                                                message: "",
                                                preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Quote"
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Move Title"
        }
        
       
        let cancelAction = UIAlertAction(title: "cancel",
                                         style: UIAlertActionStyle.cancel,
                                         handler:nil)
        
        let createQuoteAction = UIAlertAction(title: "Create quote",
                                         style: UIAlertActionStyle.default) {
                                            (action) in
                                            let newMovieQuote = MovieQuote(context:self.context)
                                            let quoteTextField = alertController.textFields![0]
                                            let movieTextField = alertController.textFields![1]
                                            newMovieQuote.quote = quoteTextField.text!
                                            newMovieQuote.movie = movieTextField.text!
                                            newMovieQuote.created = Date();
                                            self.save()
                                            self.updateMovieQuoteArray()
                                            //print("quoteTextField = \(quote)
                                           // self.movieQuotes.insert(MovieQuote(quote: quoteTextField.text!, movie: movieTextField.text!), at: 0)
                                           // let newMovieQuote = MovieQuote(context: )
                                           /* if (self.movieQuotes.count == 1){//
                                                self.tableView.reloadData()//
                                            } else {//
                                                self.tableView.insertRows(at: [IndexPath(row: 0, section:0)], with: UITableViewRowAnimation.top)//
                                            }*/ //
                                            self.quoteRef.addDocument(data: movieQuote.data)//
                                            
        }
            alertController.addAction(cancelAction)
        alertController.addAction(createQuoteAction)
        present(alertController,
                animated: true,
                completion: nil)
         self.tableView.reloadData()
        
    }


    override func setEditing(_ editing: Bool, animated: Bool) {
        if movieQuotes.count == 0 {
            super.setEditing(false, animated: animated)
        } else {
            super.setEditing(editing, animated: animated)
        }
    }
    
    /*

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }*/

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return max(movieQuotes.count, 1)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        // Configure the cell...
        
        
        if( movieQuotes.count == 0){
            cell = tableView.dequeueReusableCell(withIdentifier: noMovieQuotesCellIdentifier, for: indexPath)
        } else{
            cell = tableView.dequeueReusableCell(withIdentifier: "MovieQuoteCell", for: indexPath)

            cell.textLabel?.text = movieQuotes[indexPath.row].quote;
            cell.detailTextLabel?.text = movieQuotes[indexPath.row].movie;
        }
        return cell
        
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
    
        return movieQuotes.count > 0;
    }
    


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(movieQuotes[indexPath.row])
            save()
            updateMovieQuoteArray()
            // Delete the row from the data source
            //movieQuotes.remove(at: indexPath.row)
           /* if movieQuotes.count == 0{//
                tableView.reloadData()//
                self.setEditing(false, animated: true)//
            } else {//
                tableView.deleteRows(at: [indexPath], with: .fade)//
            }*///
            let movieQuoteToDelete = movieQuotes[indexPath.row]//
            quoteRef.document(movieQuoteToDelete.id!).delete()//
        }
    }
   

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "ShowDetailSague" {
            if let indexPath = tableView.indexPathForSelectedRow {
                (segue.destination as! MovieQuoteDetailViewController).movieQuote =
                    //movieQuotes[indexPath.row] // not right movieQuote?
                quoteRef.document(movieQuotes[indexPath.row].id!
            }
        }
        
    }
    

   

}
