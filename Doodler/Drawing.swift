//
//  Drawing.swift
//  Doodler
//
//  Created by Alex Lucas on 9/17/20.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class Drawing {
    
    var startDate: Date?
    var marks = [Mark]()
    var id: String?
    
    var dictionary: [String: Any] {
        [
            "startDate": startDate!,
            "marks": marks.map({ $0.dictionary })
        ]
    }
    
    var thumbnail: CAShapeLayer {
        let paths = marks.map({ $0.path })
        let thumbnailPath = UIBezierPath()

        for path in paths {
            thumbnailPath.append(path)
        }
        let thumbnailLayer = CAShapeLayer()
        thumbnailLayer.path = thumbnailPath.cgPath
        thumbnailLayer.fillColor = nil
        thumbnailLayer.strokeColor = UIColor.label.cgColor

        thumbnailLayer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        return thumbnailLayer
    }
    
    init() {
        
    }
    
    init(id: String, startDate: Date, marks: [[String: Any]]) {
        self.id = id
        self.startDate = startDate
        self.marks = marks.map({ Mark(dictionary: $0)! })
    }

    
    convenience init?(dictionary: [String : Any], id: String) {
        guard let startDate = dictionary["startDate"] as? Timestamp, let marks = dictionary["marks"] as? [[String: Any]] else { return nil }
         
        self.init(id: id, startDate: startDate.dateValue(), marks: marks)
    }

    
    func drawStarted(at point: CGPoint) -> CAShapeLayer {
        
        if marks.count == 0 {
            startDate = Date()
        }
        let mark = Mark(startingPoint: point)
        
        marks.append(mark)
        
        return mark.drawingLayer
        
    }
    
    func drawMoved(to point: CGPoint) {
        guard let mark = marks.last else {
            return
        }
        mark.addPoint(point)
    }
    
    func drawEnded() {
        
    }
    
    func eraseStarted(at point: CGPoint) {
        for mark in marks {
            if mark.path.contains(point) {
                mark.erase()
            }
        }
    }
    
    func eraseMoved(to point: CGPoint) {
        for mark in marks {
            if mark.path.contains(point) {
                mark.erase()
            }
        }
    }
    
    func eraseEnded() {
        
    }
    
}


class Mark {
    var startDate: Date
    var pathPoints: [TimeInterval: CGPoint]
    var erased: Bool
    var path: UIBezierPath
    var drawingLayer: CAShapeLayer
    
    var dictionary: [String: Any] {
        [
            "startDate": startDate,
            "points": pathPoints.map({ (time, point) -> [String: Any] in
                [
                    "timestamp": time,
                    "x": point.x,
                    "y": point.y
                
                ]
            }),
            "erased": erased
        ]
    }
    
    
    init(startingPoint: CGPoint) {
        startDate = Date()
        pathPoints = [TimeInterval: CGPoint]()
        pathPoints[0] = startingPoint
        erased = false
        path = UIBezierPath()
        path.move(to: startingPoint)
        
        drawingLayer = CAShapeLayer()
        drawingLayer.path = path.cgPath
        drawingLayer.fillColor = nil
        drawingLayer.strokeColor = UIColor.label.cgColor
//        let thickness = Int.random(in: 0..<10)
//        drawingLayer.lineWidth = CGFloat(thickness)
        
    }
    
    init(startDate: Date, points: [TimeInterval: CGPoint], erased: Bool) {
        self.startDate = startDate
        self.pathPoints = points
        self.erased = erased
        drawingLayer = CAShapeLayer()
        path = UIBezierPath()

        
        for (i, point) in points.enumerated() {
            if i == 0 {
                path.move(to: point.value)
                drawingLayer.path = path.cgPath
                drawingLayer.fillColor = nil
            }
            
            drawingLayer.strokeColor = erased ? UIColor.clear.cgColor : UIColor.label.cgColor
            
            
            path.addLine(to: point.value)
            drawingLayer.path = path.cgPath
        }
    }
    
    convenience init?(dictionary: [String : Any]) {
        print(dictionary)
        guard let startDate = dictionary["startDate"] as? Timestamp else {print("a"); return nil}
        guard let points = dictionary["points"] as? [[String: Any]] else {print("first m"); return nil }
                
        let erased: Bool = dictionary["erased"] as? Bool ?? false
        var pathPoints = [TimeInterval: CGPoint]()
        
        for point in points {
            guard let timestamp = point["timestamp"] as? TimeInterval, let x = point["x"] as? CGFloat, let y = point["y"] as? CGFloat else {print("sedond m"); return nil}
            
            let cgPoint = CGPoint(x: x, y: y)
            pathPoints[timestamp] = cgPoint
        }
         
        self.init(startDate: startDate.dateValue(), points: pathPoints, erased: erased)
        
    }

    
    func addPoint(_ point: CGPoint)  {
        let now = Date()
        pathPoints[now.timeIntervalSince(startDate)] = point
        path.addLine(to: point)
        drawingLayer.path = path.cgPath
    }
    
    func erase() {
        self.erased = true
        drawingLayer.removeFromSuperlayer()
    }
    
    
}

