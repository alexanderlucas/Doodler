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
        let thumbnailPath = UIBezierPath()
        let thumbnailLayer = CAShapeLayer()
        thumbnailLayer.fillColor = nil

        for mark in marks {
            thumbnailPath.append(mark.path)
            thumbnailLayer.strokeColor = mark.erased ? UIColor.clear.cgColor : mark.color.cgColor

            thumbnailLayer.path = thumbnailPath.cgPath
        }

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

    
    func drawStarted(at point: CGPoint, with color: UIColor) -> CAShapeLayer {
        
        if marks.count == 0 {
            startDate = Date()
        }
        let mark = Mark(startingPoint: point, color: color)
        
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
    
    var markLayers: [CAShapeLayer] {
        var layers = [CAShapeLayer]()
        for mark in marks {
            if !mark.erased {
                layers.append(mark.drawingLayer)
            }
        }
        return layers
    }
    
}


class Mark {
    
    var startDate: Date
    var pathPoints: [TimeInterval: CGPoint]
    var erased: Bool
    var path: UIBezierPath
    var drawingLayer: CAShapeLayer
    var color: UIColor
    
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
            "erased": erased,
            "color": color.hexValue
        ]
    }
    
    
    init(startingPoint: CGPoint, color: UIColor) {
        self.startDate = Date()
        self.pathPoints = [TimeInterval: CGPoint]()
        pathPoints[0] = startingPoint
        self.erased = false
        self.color = color
        path = UIBezierPath()
        path.move(to: startingPoint)
        
        self.drawingLayer = CAShapeLayer()
        drawingLayer.path = path.cgPath
        drawingLayer.fillColor = nil
        drawingLayer.strokeColor = color.cgColor
//        let thickness = Int.random(in: 0..<10)
//        drawingLayer.lineWidth = CGFloat(thickness)
        
    }
    
    init(startDate: Date, points: [TimeInterval: CGPoint], color: UIColor, erased: Bool) {
        self.startDate = startDate
        self.pathPoints = points
        self.erased = erased
        self.color = color
        drawingLayer = CAShapeLayer()
        path = UIBezierPath()

        
        for (i, point) in points.enumerated() {
            if i == 0 {
                path.move(to: point.value)
                drawingLayer.path = path.cgPath
                drawingLayer.fillColor = nil
            }
            
            drawingLayer.strokeColor = erased ? UIColor.clear.cgColor : color.cgColor
            
            path.addLine(to: point.value)
            drawingLayer.path = path.cgPath
        }
    }
    
    convenience init?(dictionary: [String : Any]) {
        print(dictionary)
        guard let startDate = dictionary["startDate"] as? Timestamp else {print("a"); return nil}
        guard let points = dictionary["points"] as? [[String: Any]] else {print("first m"); return nil }
                
        let erased: Bool = dictionary["erased"] as? Bool ?? false
        let colorString: String = dictionary["color"] as? String ?? "#000000"
        let color = UIColor(hex: colorString)!
        
        var pathPoints = [TimeInterval: CGPoint]()
        
        for point in points {
            guard let timestamp = point["timestamp"] as? TimeInterval, let x = point["x"] as? CGFloat, let y = point["y"] as? CGFloat else {print("sedond m"); return nil}
            
            let cgPoint = CGPoint(x: x, y: y)
            pathPoints[timestamp] = cgPoint
        }
         
        self.init(startDate: startDate.dateValue(), points: pathPoints, color: color, erased: erased)
        
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

/*
 source: https://www.hackingwithswift.com/example-code/uicolor/how-to-convert-a-hex-color-to-a-uicolor
 */
extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            } else if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = 1

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
    
    var hexValue: String {
        var color = self

        if color.cgColor.numberOfComponents < 4 {
            let c = color.cgColor.components!
            color = UIColor(red: c[0], green: c[0], blue: c[0], alpha: c[1])
        }
        if color.cgColor.colorSpace!.model != .rgb {
            return "#FFFFFF"
        }
        let c = color.cgColor.components!
        return String(format: "#%02X%02X%02X", Int(c[0]*255.0), Int(c[1]*255.0), Int(c[2]*255.0))
    }


}
