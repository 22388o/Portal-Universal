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
        HStack {
            Button(action: {
                timeframe = .day
            }) {
                Text("Day")
                    .modifier(
                        TimeframeButton(type: type, isSelected: timeframe == .day)
                    )
            }
            
            Spacer()
            
            Button(action: {
                timeframe = .week
            }) {
                Text("Week")
                    .modifier(
                        TimeframeButton(type: type, isSelected: timeframe == .week)
                    )
            }
            
            Spacer()

            Button(action: {
                timeframe = .month
            }) {
                Text("Month")
                    .modifier(
                        TimeframeButton(type: type, isSelected: timeframe == .month)
                    )
            }
            
            Spacer()
            
            Button(action: {
                timeframe = .year
            }) {
                Text("Year")
                    .modifier(
                        TimeframeButton(type: type, isSelected: timeframe == .year)
                    )
            }
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}

struct TimeframeButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        TimeframeButtonsView(type: .asset, timeframe: .constant(.day))
    }
}
