//
//  Anabul_careWidgetLiveActivity.swift
//  Anabul-careWidget
//
//  Created by Stevanus Ivan Santoso on 03/06/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct Anabul_careWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct Anabul_careWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: Anabul_careWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension Anabul_careWidgetAttributes {
    fileprivate static var preview: Anabul_careWidgetAttributes {
        Anabul_careWidgetAttributes(name: "World")
    }
}

extension Anabul_careWidgetAttributes.ContentState {
    fileprivate static var smiley: Anabul_careWidgetAttributes.ContentState {
        Anabul_careWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: Anabul_careWidgetAttributes.ContentState {
         Anabul_careWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: Anabul_careWidgetAttributes.preview) {
   Anabul_careWidgetLiveActivity()
} contentStates: {
    Anabul_careWidgetAttributes.ContentState.smiley
    Anabul_careWidgetAttributes.ContentState.starEyes
}
