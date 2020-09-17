//
//  DrawingsDisplayViewController.swift
//  Doodler
//
//  Created by Alex Lucas on 9/17/20.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol DrawingDeleteDelegate {
    func didDeleteDrawing(_ drawing: Drawing)
}

class DrawingsDisplayViewController: UITableViewController, DrawingDeleteDelegate {
    
    private var documents: [DocumentSnapshot] = []
    public var drawings: [Drawing] = []
    private var listener : ListenerRegistration!
    
    fileprivate func baseQuery() -> Query {
        return Firestore.firestore().collection("drawing").limit(to: 50)
    }
    
    fileprivate var query: Query? {
        didSet {
            if let listener = listener {
                listener.remove()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.query = baseQuery()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.listener =  query?.addSnapshotListener { (documents, error) in
            print("listned")
            guard let snapshot = documents else {
                print("Error fetching documents results: \(error!)")
                return
            }
            print("results: ")
            let results = snapshot.documents.map { (document) -> Drawing? in
                if let drawing = Drawing(dictionary: document.data(), id: document.documentID) {
                    return drawing
                } else {
                    print("not a good drawing")
                    return nil
//                    fatalError("Unable to initialize type \(Drawing.self) with dictionary \(document.data())")
                }
            }
            
            self.drawings = results.compactMap({ $0 })
            print("\(self.drawings.count) drawings")
            self.documents = snapshot.documents
            self.tableView.reloadData()
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener.remove()
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        drawings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "drawingCell") as! DrawingTableViewCell
        
        cell.drawing = drawings[indexPath.row]
        cell.deleteDelegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    
    func didDeleteDrawing(_ drawing: Drawing) {
        guard let drawingID = drawing.id else {
            return
        }
        Firestore.firestore().collection("drawing").document(drawingID).delete()
        tableView.reloadData()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
