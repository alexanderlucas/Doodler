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

class DrawingsDisplayViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, DrawingDeleteDelegate {
    
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
                }
            }
            
            self.drawings = results.compactMap({ $0 }).sorted(by: { $0.startDate! > $1.startDate! })
            print("\(self.drawings.count) drawings")
            self.documents = snapshot.documents
            self.collectionView.reloadData()
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener.remove()
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
 
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        drawings.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "drawingCell", for: indexPath) as! DrawingCollectionViewCell
        
        cell.drawing = drawings[indexPath.row]
        cell.deleteDelegate = self

        
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let drawing = drawings[indexPath.row]
        
        guard let editDrawingVC = storyboard?.instantiateViewController(identifier: "editDrawingVC") as? EditDrawingViewController else {
            return
        }
        editDrawingVC.currentDrawing = drawing
        present(editDrawingVC, animated: true, completion: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: (self.view.frame.width / 2) - 30 , height: (self.view.frame.width / 2) - 30 )
    }
   
    func didDeleteDrawing(_ drawing: Drawing) {
        guard let drawingID = drawing.id else {
            return
        }
        Firestore.firestore().collection("drawing").document(drawingID).delete()
//        tableView.reloadData()
        self.collectionView.reloadData()
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
