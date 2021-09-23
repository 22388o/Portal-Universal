//
//  NSTableView+Extension.swift
//  Portal (macOS)
//
//  Created by Farid on 23.08.2021.
//

import AppKit

extension NSTableView {
  open override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()

    backgroundColor = NSColor.clear
    enclosingScrollView?.drawsBackground = false
  }
}
