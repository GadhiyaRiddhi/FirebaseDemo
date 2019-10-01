//
//  ViewController.swift
//  FirebaseDemoApp
//
//  Created by Riddhi.Gadhiya on 26/09/19.
//  Copyright © 2019 Riddhi.Gadhiya. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    var artistList : [ArtistData] = []
    var refArtists:DatabaseReference!
    @IBOutlet weak var artistTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.artistTableView.tableFooterView = UIView()
        
        // Getting path from the database to add records
        refArtists =  Database.database().reference().child("artists")
        
        //Reading data from database
        
        refArtists.observe(DataEventType.value) { (snapshot) in
            if snapshot.childrenCount > 0{
                self.artistList.removeAll()
                
                for artists in snapshot.children.allObjects as! [DataSnapshot]{
                    let artistObj = artists.value as? [String:AnyObject]
                    let artistName = artistObj?["artistName"]
                    let artistGenre = artistObj?["artistGenre"]
                    let artistId = artistObj?["id"]
                    
                    let artistModelObj = ArtistData()
                    artistModelObj.idKey = artistId as! String
                    artistModelObj.artistName = artistName as! String
                    artistModelObj.artistGenre = artistGenre as! String
                    
                    self.artistList.append(artistModelObj)
                    self.artistTableView.reloadData()
                }
            }
        }
        
    }

     func addArtistInList(){
        let alert = UIAlertController.init(title: "Add Artist", message: "", preferredStyle: UIAlertController.Style.alert)
        var textF1 = UITextField.init()
        var textF2 = UITextField.init()
        let artistData = ArtistData()
        
        alert.addTextField { (textF) in
            textF1 = textF
            textF.placeholder = "Please Enter Artist Name."
        }
        alert.addTextField { (textF) in
            textF2 = textF
            textF.placeholder = "Please Enter Artist's Genre."
        }
        
        let addAction = UIAlertAction.init(title: "Add", style:.default) { (action) in
            if textF1.text != nil{
                artistData.artistName = textF1.text
            }
            if textF2.text != nil{
                artistData.artistGenre = textF2.text
            }
            
            let key = self.refArtists.childByAutoId().key
            let artist = [
                "id" : key,
                "artistName" : artistData.artistName,
                "artistGenre" : artistData.artistGenre
            ]
            
            // Write into Firebase Database
            self.refArtists.child(key!).setValue(artist)
            self.artistList.append(artistData)
            self.artistTableView.reloadData()
        }
        
        alert.addAction(addAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addArtistButtonTapped(_ sender: Any) {
        self.addArtistInList()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artistList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "artistCell"
        var cell = self.artistTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        cell.textLabel?.text = artistList[indexPath.row].artistName
        cell.detailTextLabel?.text = artistList[indexPath.row].artistGenre
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let artist = artistList[indexPath.row]
        let alertController = UIAlertController(title: artist.artistName, message: "Give new values to update ", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            let id = artist.idKey
            let name = alertController.textFields?[0].text
            let genre = alertController.textFields?[1].text
            self.updateArtist(id: id!, name: name!, genre: genre!)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        alertController.addTextField { (textField) in
            textField.text = artist.artistName
        }
        alertController.addTextField { (textField) in
            textField.text = artist.artistGenre
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func updateArtist(id:String, name:String, genre:String) {
        let artist = ["id":id,
                      "artistName": name,
                      "artistGenre": genre
        ]
        refArtists.child(id).setValue(artist)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete
        {
            let artist = artistList[indexPath.row]
            let id = artist.idKey
            refArtists.child(id!).setValue(nil)
            artistList.remove(at: indexPath.row)
            self.artistTableView.reloadData()
        }
    }
}

