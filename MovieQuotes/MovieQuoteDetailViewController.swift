//
//  MovieQuoteDetailViewController.swift
//  MovieQuotes
//
//  Created by CSSE Department on 4/3/18.
//  Copyright © 2018 CSSE Department. All rights reserved.
//

import UIKit

class MovieQuoteDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                            target: self,
                                                            action: #selector(showEditDialog))
        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var movieLabel: UILabel!
    var movieQuote: MovieQuote?
    
    func save(){
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func updateView(){
        quoteLabel.text = movieQuote?.quote
        movieLabel.text = movieQuote?.movie
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
        
    }
    
    @objc func showEditDialog() {
        
        let alertController = UIAlertController(title: "Edit a new movie quote",
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
                                                let quoteTextField = alertController.textFields![0]
                                                let movieTextField = alertController.textFields![1]
                                                self.movieQuote?.quote = quoteTextField.text!
                                                self.movieQuote?.movie = movieTextField.text!
                                                self.save();
                                                self.updateView()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(createQuoteAction)
        present(alertController,
                animated: true,
                completion: nil)    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
