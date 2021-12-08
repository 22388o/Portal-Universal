//
//  LineChartMarkerView.swift
//  Portal (macOS)
//
//  Created by Farid on 10.11.2021.
//

import Charts

class LineChartMarkerView: MarkerView {
    var text = String()

    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        super.refreshContent(entry: entry, highlight: highlight)
        text = entry.y.formattedString(Portal.shared.state.wallet.currency)
    }

    override func draw(context: CGContext, point: CGPoint) {
        super.draw(context: context, point: point)

        var drawAttributes = [NSAttributedString.Key : Any]()
        drawAttributes[.font] = NSFont.init(name: "Avenir-Medium", size: 12)
        drawAttributes[.foregroundColor] = NSColor.white
        drawAttributes[.backgroundColor] = NSColor.clear
        
        let nstext = " \(text) " as NSString
        self.offset = CGPoint(x: 0, y: -self.bounds.size.height - 2)

        let offset = self.offsetForDrawing(atPoint: point)

        drawText(text: nstext, rect: CGRect(origin: CGPoint(x: point.x + offset.x, y: point.y + offset.y), size: self.bounds.size), withAttributes: drawAttributes)
    }

    func drawText(text: NSString, rect: CGRect, withAttributes attributes: [NSAttributedString.Key : Any]? = nil) {
        let size = text.size(withAttributes: attributes)
        let centeredRect = CGRect(x: rect.origin.x + (rect.size.width - size.width) / 2.0, y: rect.origin.y + (rect.size.height - size.height) / 2.0, width: size.width, height: size.height)
        
        let nsRect = NSRect(x: centeredRect.origin.x, y: centeredRect.origin.y, width: centeredRect.size.width, height: centeredRect.size.height)
        
        let path = NSBezierPath(roundedRect: nsRect, xRadius: 4, yRadius: 4)
        let fillColor = NSColor(red: 8.0/255.0, green: 137.0/255.0, blue: 206.0/255.0, alpha: 1)
        fillColor.setFill()
        path.fill()
        
        text.draw(in: centeredRect, withAttributes: attributes)
    }
}
