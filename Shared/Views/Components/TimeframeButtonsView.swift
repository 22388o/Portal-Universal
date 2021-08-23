//
//  TimeframeButtonsView.swift
//  Portal
//
//  Created by Farid on 29.06.2021.
//

import SwiftUI

struct TimeframeButtonsView: View {
    let type: AssetMarketValueViewType
    @Binding var timeframe: Timeframe

    var body: some View {
        HStack(spacing: 0) {
            Button(action: {
                timeframe = .day
            }) {
                Text("Day")
                    .modifier(
                        TimeframeButton(type: type, isSelected: timeframe == .day)
                    )
            }
            .frame(width: 60)
            
            Button(action: {
                timeframe = .week
            }) {
                Text("Week")
                    .modifier(
                        TimeframeButton(type: type, isSelected: timeframe == .week)
                    )
            }
            .frame(width: 60)

            Button(action: {
                timeframe = .month
            }) {
                Text("Month")
                    .modifier(
                        TimeframeButton(type: type, isSelected: timeframe == .month)
                    )
            }
            .frame(width: 60)
            
            Button(action: {
                timeframe = .year
            }) {
                Text("Year")
                    .modifier(
                        TimeframeButton(type: type, isSelected: timeframe == .year)
                    )
            }
            .frame(width: 60)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}

struct TimeframeButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        TimeframeButtonsView(type: .asset, timeframe: .constant(.day))
    }
}

#if os(macOS)
extension NSTextField {
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
}
#endif
