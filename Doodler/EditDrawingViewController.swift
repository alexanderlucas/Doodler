//
//  ViewController.swift
//  Doodler
//
//  Created by Alex Lucas on 9/16/20.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift


class EditDrawingViewController: UIViewController {
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    var currentDrawing: Drawing!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action:#selector(handleScreenPan))

        view.addGestureRecognizer(panGestureRecognizer)
        
        currentDrawing = Drawing()
        
    }
    
    @objc func handleScreenPan(_ sender: UIGestureRecognizer) {
        
        switch sender.state {
        case .began:
            let firstPoint = sender.location(in: self.view)
            
            if segment.selectedSegmentIndex == 0 {
                let layer = currentDrawing.drawStarted(at: firstPoint)
                view.layer.addSublayer(layer)
            } else {
                currentDrawing.eraseStarted(at: firstPoint)
            }
            
        case .changed:
            let point = sender.location(in: self.view)

            if segment.selectedSegmentIndex == 0 {
                currentDrawing.drawMoved(to: point)
            } else {
                currentDrawing.eraseMoved(to: point)
            }

        case .ended:
        
            if segment.selectedSegmentIndex == 0 {
                currentDrawing.drawEnded()
            } else {
                currentDrawing.eraseEnded()
            }
            
        default: ()
        }
    }

    @IBAction func scaleButtonPressed(_ sender: Any) {
        var transform = CGAffineTransform.identity
        transform = transform.scaledBy(x:  0.5, y: 0.5)

        for mark in currentDrawing.marks {
            mark.drawingLayer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        var ref: DocumentReference? = nil
        print(currentDrawing.dictionary)
        ref = db.collection("drawing").addDocument(data: currentDrawing.dictionary) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }

    }
}

