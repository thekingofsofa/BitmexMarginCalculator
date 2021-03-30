//
//  IBCandlestickChartView.swift
//  TestChart
//
//  Created by Иван Барабанщиков on 11/13/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import UIKit

class IBCandlestickChartView: UIView {
    
    private var candlestickWidth: CGFloat = 10.0
    private let spaceBetweenCandlestick: CGFloat = 1.0
    private var numberOfVerticals: Int = 8
    private var upColor: UIColor = UIColor(red: 0.00, green: 0.77, blue: 0.03, alpha: 1.0)
    private var downColor: UIColor = UIColor.red
    private var titlesFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
    private let rightInset: CGFloat = 60
    private var topInset: Double = 20
    private var bottomInset: Double = 80
    private var panOffset: CGFloat = 0
    private var startPanLocation: CGFloat = 0
    
    private var max: Double = 0
    private var min: Double = 0
    private var values = [(close: Double, open: Double, high: Double, low: Double, volume: Double)]()
    private var dates = [String]()
    private var valueTitles = [UILabel]()
    private var visibleValues: [(close: Double, open: Double, high: Double, low: Double, volume: Double)] {
        let graphWidth = ((candlestickWidth + spaceBetweenCandlestick) * CGFloat(values.count))
        let ratio = graphWidth / CGFloat(values.count)
        let visiblePointStart = 0 - panOffset
        let visibleValuesCount = Int((self.bounds.width - rightInset) / (candlestickWidth + spaceBetweenCandlestick))
        let startIndex = abs(Int(visiblePointStart / ratio))
        let endIndex = abs(Int(visiblePointStart / ratio) + visibleValuesCount)
        if startIndex >= endIndex {
            return Array()
        }
        return Array(values[startIndex...endIndex])
    }
    
    public func draw(values: [(close: Double, open: Double, high: Double, low: Double, volume: Double)],
                     dates: [String]) {
        
        self.layer.sublayers?.removeAll()
        self.values = values
        self.max = visibleValues.map { $0.high }.max() ?? 0.0
        self.min = visibleValues.map { $0.low }.min() ?? 0.0
        self.backgroundColor = .white
        self.layer.cornerRadius = 6.0
        self.dates = dates
        self.clipsToBounds = true
        drawChart(values: values)
        drawBackgroundLines()
        drawBorderLines()
        setupLabels()
        setupGestureRecognizer()
        drawLastValuePointer()
    }
    
    // MARK: - Setup Gesture Recognizers
    
    private func setupGestureRecognizer() {
        
        self.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(recognizer:))))
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanRecognizer(recognizer:))))
    }
    
    @objc private func handlePanRecognizer(recognizer: UIPanGestureRecognizer) {
        let currentLocation = recognizer.location(in: self)

        switch recognizer.state {
        case .began:
            startPanLocation = currentLocation.x
        case .changed:
            let dx = currentLocation.x - startPanLocation
            panOffset -= dx
            if panOffset > 0 {
                panOffset = 0
            }
            if panOffset < -((candlestickWidth + spaceBetweenCandlestick) * CGFloat(values.count)) + (self.bounds.width - rightInset) {
                panOffset = -((candlestickWidth + spaceBetweenCandlestick) * CGFloat(values.count)) + (self.bounds.width - rightInset)
            }
            startPanLocation = currentLocation.x
            
            redrawChart()
        case .ended:
            startPanLocation = .zero
        default: break
        }
    }
    
    @objc private func handlePinchGesture(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
            
        case .changed:
            let graphWidth = ((candlestickWidth + spaceBetweenCandlestick) * CGFloat(values.count)) + (self.bounds.width - rightInset)
            candlestickWidth += recognizer.velocity
            
            if candlestickWidth > 20 {
                candlestickWidth = 20
            }

            if candlestickWidth < 3 {
                candlestickWidth = 3
            }
            
            let newGraphWidth = ((candlestickWidth + spaceBetweenCandlestick) * CGFloat(values.count)) + (self.bounds.width - rightInset)
            let changeRatio = graphWidth / newGraphWidth
            panOffset /= changeRatio
            panOffset -= (self.bounds.width - recognizer.location(in: self).x) - ((self.bounds.width - recognizer.location(in: self).x) * changeRatio)
            
            if panOffset > 0 {
                panOffset = 0
            }
            if panOffset < -((candlestickWidth + spaceBetweenCandlestick) * CGFloat(values.count)) + (self.bounds.width - rightInset) {
                panOffset = -((candlestickWidth + spaceBetweenCandlestick) * CGFloat(values.count)) + (self.bounds.width - rightInset)
            }
            
            redrawChart()
        default:
            break
        }
    }
    
    // MARK: - Drawing methods
    
    private func drawChart(values: [(close: Double, open: Double, high: Double, low: Double, volume: Double)]) {
        guard values.count > 0 else { return }
        
        let width = bounds.width - rightInset
        var x = width - candlestickWidth - spaceBetweenCandlestick

        for value in values {
            drawCandlestick(x: x, close: value.close, open: value.open, high: value.high, low: value.low)
            x -= candlestickWidth + spaceBetweenCandlestick
        }
    }
    
    private func drawCandlestick(x: CGFloat, close: Double, open: Double, high: Double, low: Double) {
        let color = open <= close ? upColor.cgColor : downColor.cgColor
        
        // low-high line
        let xLine = x + (candlestickWidth / 2) - panOffset
        let yHigh = getY(high)
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: xLine, y: yHigh + CGFloat(topInset)))
        linePath.addLine(to: CGPoint(x: xLine, y: getY(low) + CGFloat(topInset)))

        let lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.strokeColor = color
        lineLayer.lineWidth = 1
        layer.contentsScale = UIScreen.main.scale
        self.layer.addSublayer(lineLayer)

        // open-close rectangle
        let y = open < close ? getY(open) : getY(close)
        let height = open < close ? getY(close) - getY(open) : getY(open) - getY(close)

        let rectPath = UIBezierPath(rect: CGRect(x: x - panOffset, y: y + CGFloat(topInset), width: candlestickWidth, height: height != 0 ? height : 1))

        let rectLayer = CAShapeLayer()
        rectLayer.path = rectPath.cgPath
        rectLayer.fillColor = color
        layer.contentsScale = UIScreen.main.scale

        self.layer.addSublayer(rectLayer)
    }
    
    func redrawChart() {
        
        self.layer.sublayers?.removeAll()
        self.max = visibleValues.map { $0.high }.max() ?? 0.0
        self.min = visibleValues.map { $0.low }.min() ?? 0.0
        drawChart(values: values)
        drawBackgroundLines()
        drawBorderLines()
        setupLabels()
        drawLastValuePointer()
    }
    
    private func setupLabels() {
        
        valueTitles.forEach {
            $0.removeFromSuperview()
        }
        valueTitles = [UILabel]()
        
        numberOfVerticals = 80 / Int(candlestickWidth)
        
        let width = bounds.width - rightInset
        let height = bounds.height
        let spaceBetweenVerticalLines: CGFloat = (candlestickWidth + spaceBetweenCandlestick) * CGFloat(numberOfVerticals)
        let spaceBetweenHorisontalLines: CGFloat = 50
        let numberOfHorizontal = Int(height / spaceBetweenHorisontalLines)
        if numberOfHorizontal < 2 {
            return
        }
        
        var verticalX = self.bounds.maxX - rightInset
        var horisontalY = self.bounds.maxY
        
        for index in 2..<numberOfHorizontal + 1 {
            horisontalY = self.bounds.maxY - (CGFloat(index) * spaceBetweenHorisontalLines)
            
            let title = UILabel(frame: CGRect(x: width + 4, y: horisontalY - 6, width: rightInset - 12, height: 12))
            title.font = titlesFont
            title.text = getValue(horisontalY)
            title.adjustsFontSizeToFitWidth = true
            self.addSubview(title)
            valueTitles.append(title)
        }
        
        let filteredDates = dates.enumerated().compactMap { index, element in
            index % numberOfVerticals == 0 ? element : nil
        }
        
        for index in 0..<filteredDates.count {
            verticalX = self.bounds.maxX - (CGFloat(index) * (spaceBetweenVerticalLines)) - rightInset - 40 - panOffset
            
            let title = UILabel(frame: CGRect(x: verticalX, y: bounds.maxY - 40, width: 80, height: 30))
            
            if let date = filteredDates[index].iso8601 {
                let format = DateFormatter()
                format.dateFormat = "yyyy-MM-dd HH:mm"
                title.font = titlesFont
                title.text = format.string(from: date)
                title.numberOfLines = 0
                title.adjustsFontSizeToFitWidth = true
                title.textAlignment = .center
                self.addSubview(title)
                valueTitles.append(title)
            }
        }
    }
    
    private func drawBorderLines() {
        let height = bounds.height
        let spaceBetweenHorisontalLines: CGFloat = 50
        let verticalX = self.bounds.maxX - rightInset
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: verticalX, y: 0))
        linePath.addLine(to: CGPoint(x: verticalX, y: height - spaceBetweenHorisontalLines))
        linePath.addLine(to: CGPoint(x: 0, y: height - spaceBetweenHorisontalLines))
        linePath.addLine(to: CGPoint(x: 0, y: height))
        linePath.addLine(to: CGPoint(x: bounds.width, y: height))
        linePath.addLine(to: CGPoint(x: bounds.width, y: 0))
        let lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.fillColor = UIColor.white.cgColor
        lineLayer.strokeColor = UIColor.lightGray.cgColor
        lineLayer.lineWidth = 1
        layer.contentsScale = UIScreen.main.scale
        self.layer.addSublayer(lineLayer)
    }
    
    private func drawBackgroundLines() {
        numberOfVerticals = 80 / Int(candlestickWidth)
        
        let width = bounds.width - rightInset
        let height = bounds.height
        let spaceBetweenVerticalLines: CGFloat = (candlestickWidth + spaceBetweenCandlestick) * CGFloat(numberOfVerticals)
        let spaceBetweenHorisontalLines: CGFloat = 50
        let numberOfVertical = dates.count / numberOfVerticals
        let numberOfHorizontal = Int(height / spaceBetweenHorisontalLines)
        if numberOfHorizontal < 2 {
            return
        }
        var verticalX = self.bounds.maxX - rightInset
        var horisontalY = self.bounds.maxY
        
        for index in 1...numberOfVertical + 1 {
            let linePath = UIBezierPath()
            linePath.move(to: CGPoint(x: verticalX, y: 0))
            linePath.addLine(to: CGPoint(x: verticalX, y: height - spaceBetweenHorisontalLines))
            verticalX = self.bounds.maxX - (CGFloat(index) * spaceBetweenVerticalLines) - (rightInset - (candlestickWidth / 2)) - panOffset
            let lineLayer = CAShapeLayer()
            lineLayer.path = linePath.cgPath
            lineLayer.strokeColor = UIColor.lightGray.cgColor
            lineLayer.opacity = 0.15
            lineLayer.lineWidth = 1
            layer.contentsScale = UIScreen.main.scale
            self.layer.addSublayer(lineLayer)
        }
        
        for index in 1...numberOfHorizontal + 1 {
            let linePath = UIBezierPath()
            linePath.move(to: CGPoint(x: 0, y: horisontalY))
            linePath.addLine(to: CGPoint(x: width, y: horisontalY))
            horisontalY = self.bounds.maxY - (CGFloat(index) * spaceBetweenHorisontalLines)
            
            let lineLayer = CAShapeLayer()
            lineLayer.path = linePath.cgPath
            lineLayer.strokeColor = UIColor.lightGray.cgColor
            lineLayer.opacity = 0.15
            lineLayer.lineWidth = 1
            layer.contentsScale = UIScreen.main.scale
            self.layer.addSublayer(lineLayer)
        }
    }
    
    private func drawLastValuePointer() {
        
        guard let lastValue = values.first?.close else { return }
        let y = getY(lastValue) + CGFloat(topInset)
        let layerHeight: CGFloat = 20
        
        if lastValue > max || lastValue < min {
            return
        }
        
        let currentValuePointerPath = UIBezierPath()
        currentValuePointerPath.move(to: CGPoint(x: 0, y: y))
        currentValuePointerPath.addLine(to: CGPoint(x: bounds.width - rightInset, y: y))
        currentValuePointerPath.addLine(to: CGPoint(x: bounds.width - rightInset + 6, y: y + (layerHeight / 2)))
        currentValuePointerPath.addLine(to: CGPoint(x: bounds.width - 6, y: y + (layerHeight / 2)))
        currentValuePointerPath.addLine(to: CGPoint(x: bounds.width - 6, y: y - (layerHeight / 2)))
        currentValuePointerPath.addLine(to: CGPoint(x: bounds.width - rightInset + 6, y: y - (layerHeight / 2)))
        currentValuePointerPath.addLine(to: CGPoint(x: bounds.width - rightInset, y: y))
        
        let currentValuePointerLayer = CAShapeLayer()
        currentValuePointerLayer.path = currentValuePointerPath.cgPath
        currentValuePointerLayer.strokeColor = UIColor.orange.cgColor
        currentValuePointerLayer.fillColor = UIColor.orange.cgColor
        currentValuePointerLayer.lineWidth = 1
        self.layer.addSublayer(currentValuePointerLayer)
        
        let valueLabel = UILabel(frame: CGRect(x: bounds.width - rightInset + 6, y: y - (layerHeight / 2), width: rightInset - 14, height: layerHeight))
        valueLabel.font = titlesFont
        valueLabel.text = String(format: Settings.shared.selectedTradingPair.formatStyle, lastValue)
        valueLabel.textAlignment = .center
        valueLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(valueLabel)
    }
    
    // MARK: - Height and value calculation methods
    
    private func getY(_ value: Double?) -> CGFloat {

        let heightRatio = (max - min) / (Double(bounds.height) - (topInset + bottomInset))
        let chartHeight = (max - min) / heightRatio
        guard let value = value else { return 0 }
        
        return CGFloat(chartHeight - ((value - min) / heightRatio))
    }
    
    private func getValue(_ pointY: CGFloat?) -> String {

        let heightRatio = (max - min) / (Double(bounds.height) - (topInset + bottomInset))
        let chartHeight = (max - min) / heightRatio
        guard let pointY = pointY else { return "" }
        
        let value = ((chartHeight - Double(pointY) + topInset) * heightRatio) + min
        
        return String(format: Settings.shared.selectedTradingPair.formatStyle, value)
    }
}
