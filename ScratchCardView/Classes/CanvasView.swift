//
//  CanvasView.swift
//  Pods
//
//  Created by Piotr Gorzelany on 09/04/2017.
//
//

import UIKit

protocol CanvasViewDelegate: class {
    
    func canvasViewDidStartDrawing(_ view: CanvasView, at point: CGPoint)
    func canvasViewDidAddLine(_ view: CanvasView, to point: CGPoint)
    func canvasViewDidEndDrawing(_ view: CanvasView)
}

class CanvasView: UIView {
    
    // MARK: Properties
    
    weak var delegate: CanvasViewDelegate?
    
    @IBInspectable var lineWidth: CGFloat = 10
    @IBInspectable var strokeColor = UIColor.black
    
    private var pathes = [UIBezierPath]()
    private var pendingPath: UIBezierPath?
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configureView()
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(strokeColor.cgColor)
        context?.setLineWidth(lineWidth)
       
        for path in pathes {
            path.lineJoinStyle = .round
            path.lineCapStyle = .round
            path.lineWidth = self.lineWidth
            path.stroke()
        }
    }
    
    // MARK: Actions
    
    @objc func panGestureRecognized(_ recognizer: UIPanGestureRecognizer) {
        let point = recognizer.location(in: self)
        
        switch recognizer.state {
        case .began:
            pendingPath = UIBezierPath()
            pendingPath?.move(to: point)
            pathes.append(pendingPath!)
            delegate?.canvasViewDidStartDrawing(self, at: point)
        case .changed:
            pendingPath?.addLine(to: point)
            delegate?.canvasViewDidAddLine(self, to: point)
        default:
            delegate?.canvasViewDidEndDrawing(self)
        }
        setNeedsDisplay()
    }
    
    func clear() {
        pathes = []
        setNeedsDisplay()
    }
    
    // MARK: Private Methods
    
    fileprivate func configureView() {
        addGestureRecognizers()
    }
    
    fileprivate func addGestureRecognizers() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognized))
        addGestureRecognizer(panRecognizer)
    }
}

