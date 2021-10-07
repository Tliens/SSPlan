//
//  AnimateDeleteLabel.swift
//  AnimateDeleteLabel
//
//  Created by 2020 on 2021/1/25.
//

import UIKit

class AnimateDeleteLabel: UILabel {
    /// 每一条删除线的位置 get set
    lazy private var lineRects = allRects(height: 1)
    /// text 属性
    override var text: String?{
        didSet{
            lineRects = allRects(height: 1)
        }
    }
    /// frame 属性
    override var frame: CGRect{
        didSet{
            lineRects = allRects(height: 1)
        }
    }
    /// 删除线的进度
    var progress:CGFloat = 0.1
    
    /// 每一条删除线的位置 get
    var rects : [CGRect]{
        return lineRects
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        // 划线
        for lineRect in rects{
            self.textColor.set()
            UIRectFill(CGRect(origin: lineRect.origin
                              , size: CGSize(width: lineRect.width*progress, height: lineRect.height)))
        }
        
    }
    /// 获取行文字
    private func lines(forLabel: UILabel) -> [String]? {

        guard let text = text, let font = font else { return nil }

        let attStr = NSMutableAttributedString(string: text)
        attStr.addAttribute(NSAttributedString.Key.font, value: font, range: NSRange(location: 0, length: attStr.length))

        let frameSetter = CTFramesetterCreateWithAttributedString(attStr as CFAttributedString)
        let path = CGMutablePath()

        let size = sizeThatFits(CGSize(width: self.frame.width, height: .greatestFiniteMagnitude))
        path.addRect(CGRect(x: 0, y: 0, width: size.width, height: size.height > 20 ? size.height : 20), transform: .identity)

        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, attStr.length), path, nil)
        guard let lines = CTFrameGetLines(frame) as? [Any] else { return nil }

        var linesArray: [String] = []

        for line in lines {
            let lineRef = line as! CTLine
            let lineRange = CTLineGetStringRange(lineRef)
            let range = NSRange(location: lineRange.location, length: lineRange.length)
            let lineString = (text as NSString).substring(with: range)
            linesArray.append(lineString)
        }
        return linesArray
    }
    /// 获取行宽度
    private func maxXForLine(withText text: NSAttributedString, labelWidth: CGFloat) -> CGFloat {
        let labelSize = CGSize(width: labelWidth, height: .infinity)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: labelSize)
        let textStorage = NSTextStorage(attributedString: text)

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = .byWordWrapping
        textContainer.maximumNumberOfLines = 0

        let lastGlyphIndex = layoutManager.glyphIndexForCharacter(at: text.length - 1)
        let lastLineFragmentRect = layoutManager.lineFragmentUsedRect(forGlyphAt: lastGlyphIndex,
                effectiveRange: nil)

        return lastLineFragmentRect.maxX
    }
  
    /// 所有的线的位置
    public func allRects(height:CGFloat = 0) ->[CGRect]{

        var lineRects = [CGRect]()
        func singleRect(line: Int, inLines lines: [String]) {
            let baseYPosition = (font.lineHeight * (CGFloat(line - 1) + 0.5))
            guard baseYPosition < self.frame.height else { return }

            let attributedText = NSAttributedString(string: lines[line - 1].trimmingCharacters(in: .whitespaces),
                    attributes: [.font: self.font!])
            let lineMaxX = maxXForLine(withText: attributedText,
                    labelWidth: self.bounds.width) + 4

            let rect = CGRect(x: -4, y: baseYPosition, width: lineMaxX, height: 1)
            lineRects.append(rect)
            
        }

        let lines = self.lines(forLabel: self) ?? []
        let numberOfLines = lines.count
        if numberOfLines < 1{
            return []
        }
        for line in 1...numberOfLines {
            singleRect(line: line, inLines: lines)
        }
        return lineRects
    }
}
