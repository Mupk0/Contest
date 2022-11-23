//
//  Fonts.swift
//  TelegramContest
//
//  Created by Dmitry Kulagin on 31.10.2022.
//

import Foundation

enum Fonts: String, CaseIterable {
    case arial = "ArialMT"
    case timesNewRoman = "TimesNewRomanPSMT"
    case helvetica = "Helvetica"
    case rockwell = "Rockwell-Regular"
    case verdana = "Verdana"
    case charter = "Charter-Roman"
    case futura = "Futura-Medium"
    case markerFelt = "MarkerFelt-Thin"
    
    var name: String {
        switch self {
        case .arial:
            return "Arial"
        case .timesNewRoman:
            return "TimesNewRoman"
        case .helvetica:
            return "Helvetica"
        case .rockwell:
            return "Rockwell"
        case .verdana:
            return "Verdana"
        case .charter:
            return "Charter"
        case .futura:
            return "Futura"
        case .markerFelt:
            return "MarkerFelt"
        }
    }
}
