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
    
    var currentDrawing: Drawing!
    
    @IBOutlet weak var drawingView: UIView!
    @IBOutlet weak var colorWell: UIColorWell!
    @IBOutlet weak var eraserButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var drawingColor: UIColor = UIColor.label
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action:#selector(handleScreenPan))
        
        drawingView.addGestureRecognizer(panGestureRecognizer)
        
        if currentDrawing == nil {
            currentDrawing = Drawing()
        } else {
            for layer in currentDrawing.markLayers {
                view.layer.addSublayer(layer)
            }

        }
        colorWell.selectedColor = drawingColor
        colorWell.title = "Select Pencil Color"
        colorWell.addTarget(self, action: #selector(colorWellChanged(_:)), for: .valueChanged)
        
    }
    
    @objc func handleScreenPan(_ sender: UIGestureRecognizer) {
        
        switch sender.state {
        case .began:
            let firstPoint = sender.location(in: self.drawingView)
            
            if eraserButton.isSelected {
                currentDrawing.eraseStarted(at: firstPoint)
            } else {
                let layer = currentDrawing.drawStarted(at: firstPoint, with: drawingColor)
                drawingView.layer.addSublayer(layer)
            }
            
        case .changed:
            let point = sender.location(in: self.drawingView)
            
            if eraserButton.isSelected {
                currentDrawing.eraseMoved(to: point)
                
            } else {
                currentDrawing.drawMoved(to: point)
                
            }
            
        case .ended:
            
            if eraserButton.isSelected {
                currentDrawing.eraseEnded()
            } else {
                currentDrawing.drawEnded()
                
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
    
    @objc func colorWellChanged(_ sender: Any) {
        drawingColor = colorWell.selectedColor!
    }
    
    @IBAction func eraserButtonPressed(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        sender.tintColor = sender.isSelected ? .systemGreen : .lightGray
        
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        loadingIndicator.startAnimating()
        saveButton.isEnabled = false
        saveButton.tintColor = .clear

        if let drawingID = currentDrawing.id {
            db.collection("drawing").document(drawingID).updateData(currentDrawing.dictionary) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                        self.loadingIndicator.stopAnimating()
                        self.saveButton.isEnabled = true
                        self.saveButton.tintColor = .systemGreen

                        self.dismiss(animated: true, completion: nil)
                    }
            }

        } else {
            db.collection("drawing").addDocument(data: currentDrawing.dictionary) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    self.loadingIndicator.stopAnimating()
                    self.saveButton.isEnabled = true
                    self.saveButton.tintColor = .systemGreen

                    self.dismiss(animated: true, completion: nil)
                }
            }

        }
        
        print(currentDrawing.dictionary)
        
    }
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

