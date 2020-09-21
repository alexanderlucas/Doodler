//
//  DrawingCollectionViewCell.swift
//  Doodler
//
//  Created by Alex Lucas on 9/17/20.
//

import UIKit

class DrawingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var elapsedLabel: UILabel!
    
    var drawing: Drawing! {
        didSet {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd hh:mm"
            let date = formatter.string(from: drawing.startDate!)
            if let endDate = drawing.endDate {
                let timeElapsed = endDate.timeIntervalSince(drawing.startDate!)
                elapsedLabel.text = "\(timeElapsed)s"
            }

            dateLabel?.text = date
            for thumbnailLayer in drawing.thumbnail {
                thumbnailView.layer.addSublayer(thumbnailLayer)

            }
        }
    }
    var deleteDelegate: DrawingDeleteDelegate!
    
    var initialTouchPoint: CGPoint?
    var initialFrame: CGRect?

    private var shadowLayer: CAShapeLayer!

    override func layoutSubviews() {
        super.layoutSubviews()
        thumbnailView.layer.cornerRadius = 12
                

        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor

            shadowLayer.shadowColor = UIColor.systemGray2.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
            shadowLayer.shadowOpacity = 0.8
            shadowLayer.shadowRadius = 6

            layer.insertSublayer(shadowLayer, at: 0)
            //layer.insertSublayer(shadowLayer, below: nil) // also works
        }
    }
    
    override func prepareForReuse() {
        guard let superLayers = thumbnailView.layer.sublayers else {
            return
        }
        for l in superLayers {
            l.removeFromSuperlayer()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        print("awakefromenib")
        
        thumbnailView.layer.cornerRadius = 12
                
    }



}
