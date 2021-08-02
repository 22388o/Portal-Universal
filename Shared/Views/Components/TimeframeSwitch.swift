//
//  TimeframeSwitch.swift
//  Portal
//
//  Created by Farid on 11.04.2021.
//

import SwiftUI

struct TimeframeSwitch: View {
    var body: some View {
        HStack {
            Text("Hour")
            Text("Day")
            Text("Week")
            Text("Month")
            Text("Year")
            Text("All time")
        }
    }
}

struct TimeframeSwitch_Previews: PreviewProvider {
    static var previews: some View {
        TimeframeSwitch()
    }
}
