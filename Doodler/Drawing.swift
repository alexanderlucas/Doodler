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
    
    var thumbnail: [CAShapeLayer] {
        var thumbnailLayers = [CAShapeLayer]()

        for mark in marks {
            let markPath = UIBezierPath()
            let markLayer = CAShapeLayer()
            markLayer.fillColor = nil
            markLayer.strokeColor = mark.erased ? UIColor.clear.cgColor : mark.color.cgColor

            markPath.append(mark.path)

            markLayer.path = markPath.cgPath
            
            markLayer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
            thumbnailLayers.append(markLayer)
        }

        return thumbnailLayers
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
    var pathPoints: [clock_t: CGPoint]
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
        self.pathPoints = [clock_t: CGPoint]()
        pathPoints[clock()] = startingPoint
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
    
    init(startDate: Date, points: [clock_t: CGPoint], color: UIColor, erased: Bool) {
        self.startDate = startDate
        self.pathPoints = points
        self.erased = erased
        self.color = color
        drawingLayer = CAShapeLayer()
        path = UIBezierPath()

        
        for (i, time) in points.keys.sorted().enumerated() {
            if i == 0 {
                path.move(to: points[time]!)
                drawingLayer.path = path.cgPath
                drawingLayer.fillColor = nil
            }
            
            drawingLayer.strokeColor = erased ? UIColor.clear.cgColor : color.cgColor
            
            path.addLine(to: points[time]!)
            drawingLayer.path = path.cgPath
        }
    }
    
    convenience init?(dictionary: [String : Any]) {
        print(dictionary)
        guard let startDate = dictionary["startDate"] as? Timestamp else {print("a"); return nil}
        guard let points = dictionary["points"] as? [[String: Any]] else {print("first m"); return nil }
                
        let erased: Bool = dictionary["erased"] as? Bool ?? false
        let colorString: String = dictionary["color"] as? String ?? "#000000"
        let color = UIColor(hex: colorString)
        
        var pathPoints = [clock_t: CGPoint]()
        
        for point in points {
            guard let timestamp = point["timestamp"] as? clock_t, let x = point["x"] as? CGFloat, let y = point["y"] as? CGFloat else {print("sedond m"); return nil}
            
            let cgPoint = CGPoint(x: x, y: y)
            pathPoints[timestamp] = cgPoint
        }
         
        self.init(startDate: startDate.dateValue(), points: pathPoints, color: color, erased: erased)
        
    }

    
    func addPoint(_ point: CGPoint)  {
        pathPoints[clock()] = point
        path.addLine(to: point)
        drawingLayer.path = path.cgPath
    }
    
    func erase() {
        self.erased = true
        drawingLayer.removeFromSuperlayer()
    }
    
    
}

/*
 source: https://theswiftdev.com/uicolor-best-practices-in-swift/
 
 */
extension UIColor {
    public convenience init(hex: Int, alpha: CGFloat = 1.0) {
           let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
           let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
           let blue = CGFloat((hex & 0xFF)) / 255.0

           self.init(red: red, green: green, blue: blue, alpha: alpha)
       }

       public convenience init(hex string: String, alpha: CGFloat = 1.0) {
           var hex = string.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

           if hex.hasPrefix("#") {
               let index = hex.index(hex.startIndex, offsetBy: 1)
               hex = String(hex[index...])
           }

           if hex.count < 3 {
               hex = "\(hex)\(hex)\(hex)"
           }

           if hex.range(of: "(^[0-9A-Fa-f]{6}$)|(^[0-9A-Fa-f]{3}$)", options: .regularExpression) != nil {
               if hex.count == 3 {

                   let startIndex = hex.index(hex.startIndex, offsetBy: 1)
                   let endIndex = hex.index(hex.startIndex, offsetBy: 2)

                   let redHex = String(hex[..<startIndex])
                   let greenHex = String(hex[startIndex..<endIndex])
                   let blueHex = String(hex[endIndex...])

                   hex = redHex + redHex + greenHex + greenHex + blueHex + blueHex
               }

               let startIndex = hex.index(hex.startIndex, offsetBy: 2)
               let endIndex = hex.index(hex.startIndex, offsetBy: 4)
               let redHex = String(hex[..<startIndex])
               let greenHex = String(hex[startIndex..<endIndex])
               let blueHex = String(hex[endIndex...])

               var redInt: UInt64 = 0
               var greenInt: UInt64 = 0
               var blueInt: UInt64 = 0

               Scanner(string: redHex).scanHexInt64(&redInt)
               Scanner(string: greenHex).scanHexInt64(&greenInt)
               Scanner(string: blueHex).scanHexInt64(&blueInt)

               self.init(red: CGFloat(redInt) / 255.0,
                         green: CGFloat(greenInt) / 255.0,
                         blue: CGFloat(blueInt) / 255.0,
                         alpha: CGFloat(alpha))
           }
           else {
               self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
           }
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
