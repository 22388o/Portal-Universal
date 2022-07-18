//
//  LDKLogger.swift
//  Portal
//
//  Created by farid on 6/13/22.
//

#if os(macOS)
import LDKFramework_Mac
#else
import LDKFramework
#endif

class LDKLogger: Logger {
    override func log(record: Record) {
        let messageLevel = record.get_level()
        let arguments = record.get_args()
        
        switch messageLevel {
        case LDKLevel_Debug:
            print("\nDebug Logger:\n>\(arguments)\n")
        case LDKLevel_Info:
            print("\nInfo Logger:\n>\(arguments)\n")
        case LDKLevel_Warn:
            print("\nWarn Logger:\n>\(arguments)\n")
        case LDKLevel_Error:
            print("\nError Logger:\n>\(arguments)\n")
        case LDKLevel_Sentinel:
            print("\nSentinel Logger:\n>\(arguments)\n")
        default:
            break
        }
    }

}
