//
//  MyGenresViewController.swift
//  Project33
//
//  Created by Besher on 2018-01-20.
//  Copyright © 2018 Besher. All rights reserved.
//

import UIKit
import CloudKit

class MyGenresViewController: UITableViewController {

    var myGenres: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let defaults = UserDefaults.standard
        if let savedGenres = defaults.object(forKey: "myGenres") as? [String] {
            myGenres = savedGenres
        } else {
            myGenres = [String]()
        }
        title = "Notify me about..."
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTapped))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let selectedGenre = SelectGenreViewController.genres[indexPath.row]
            
            if cell.accessoryType == .none {
                cell.accessoryType = .checkmark
                myGenres.append(selectedGenre)
            } else {
                cell.accessoryType = .none
                if let index = myGenres.index(of: selectedGenre) {
                    myGenres.remove(at: index)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let genre = SelectGenreViewController.genres[indexPath.row]
        cell.textLabel?.text = genre
        if myGenres.contains(genre) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    @objc func saveTapped() {
        
        let defaults = UserDefaults.standard
        defaults.set(myGenres, forKey: "myGenres")
        let database = CKContainer.default().publicCloudDatabase
        database.fetchAllSubscriptions {
            [unowned self] subscriptions, error in
            if error == nil {
                if let subscriptions = subscriptions {
                    for subscription in subscriptions {
                        database.delete(withSubscriptionID: subscription.subscriptionID) {
                            str, error in
                            if error != nil {
                                let ac = UIAlertController(title: "Error", message: "Cannot delete subscriptions. \(error!.localizedDescription)", preferredStyle: .alert)
                                ac.addAction(UIAlertAction(title: "OK", style: .default))
                                self.present(ac, animated: true)
                                
                                print(error!.localizedDescription)
                            }
                        }
                    }
                    for genre in self.myGenres {
                        let predicate = NSPredicate(format: "genre = %@", genre)
                        let subscription = CKQuerySubscription(recordType: "Whistles", predicate: predicate, options: .firesOnRecordCreation)
                        let notification = CKNotificationInfo()
                        notification.alertBody = "There's a new whistle in the \(genre) genre!"
                        notification.soundName = "default"
                        subscription.notificationInfo = notification
                        database.save(subscription) {
                            result, error in
                            if let error = error {
                                print(error.localizedDescription)
                                let ac = UIAlertController(title: "Error", message: "Cannot create subscriptions. \(error.localizedDescription)", preferredStyle: .alert)
                                ac.addAction(UIAlertAction(title: "OK", style: .default))
                                self.present(ac, animated: true)
                            }
                        }
                    }
                }
            } else {
                let ac = UIAlertController(title: "Error", message: "Cannot fetch subscriptions. \(error!.localizedDescription)", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
                print(error!.localizedDescription)
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return SelectGenreViewController.genres.count
    }


}
