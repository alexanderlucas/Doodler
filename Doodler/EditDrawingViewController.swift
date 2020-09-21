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
import RoundSlider
import SwiftUI


class EditDrawingViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    var currentDrawing: Drawing!
    
    @IBOutlet weak var drawingView: UIView!
    @IBOutlet weak var colorWell: UIColorWell!
    @IBOutlet weak var eraserButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var sliderData: SliderData = SliderData(minValue: 1, maxValue: 10, defaultValue: 1, color: .green, goesUp: false)
    
    
    var drawingColor: UIColor = UIColor.label {
        didSet {
            sliderData.color = Color(drawingColor)
        }
    }
    
    let db = Firestore.firestore()
    
    var layers: [CAShapeLayer]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
                
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action:#selector(handleScreenPan))
        
        drawingView.addGestureRecognizer(panGestureRecognizer)
        
        layers = []
        
        if currentDrawing == nil {
            currentDrawing = Drawing()
        } else {
            for layer in currentDrawing.markLayers {
                layers.append(layer)
                drawingView.layer.addSublayer(layer)
            }
            
        }
        colorWell.selectedColor = drawingColor
        colorWell.title = "Select Pencil Color"
        colorWell.addTarget(self, action: #selector(colorWellChanged(_:)), for: .valueChanged)
        
        sliderData.color = Color(drawingColor)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func animateLayers() {
        for layer in layers {
            layer.strokeEnd = 0
        }
        
        let queue = OperationQueue()
        
        for layer in layers {
            
            queue.addOperation {
                let animation = CABasicAnimation(keyPath: "strokeEnd")
                
                // Set the animation duration appropriately
                animation.duration = 1.0
                
                // Animate from 0 (no circle) to 1 (full circle)
                animation.fromValue = 0
                animation.toValue = 1
                
                // Do a linear animation (i.e. the speed of the animation stays the same)
                animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
                
                // Set the circleLayer's strokeEnd property to 1.0 now so that it's the
                // right value when the animation ends.
                layer.strokeEnd = 1.0
                
                // Do the actual animation
                layer.add(animation, forKey: "animatePath")
            }
        }
    }
    
    @objc func handleScreenPan(_ sender: UIGestureRecognizer) {
        
        switch sender.state {
        case .began:
            let firstPoint = sender.location(in: self.drawingView)
            
            if eraserButton.isSelected {
                currentDrawing.eraseStarted(at: firstPoint)
            } else {
                let layer = currentDrawing.drawStarted(at: firstPoint, color: drawingColor, thickness: CGFloat(sliderData.getValue()))
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
    
    @objc func colorWellChanged(_ sender: Any) {
        drawingColor = colorWell.selectedColor!
    }
    
    @IBAction func thicknessButtonPressed(_ sender: Any) {
        
    }
    @IBAction func eraserButtonPressed(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        sender.tintColor = sender.isSelected ? .systemGreen : .lightGray
        
    }
    @IBAction func replayButtonPressed(_ sender: Any) {
        animateLayers()
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {            if let dest = segue.destination as? SliderViewController {
        dest.sliderData = self.sliderData
        dest.modalPresentationStyle = UIModalPresentationStyle.popover
        dest.popoverPresentationController!.delegate = self
    }
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
    
}

