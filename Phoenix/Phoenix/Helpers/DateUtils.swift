//
//  DateUtils.swift
//  Phoenix
//
//  Created by James Hughes on 9/24/23.
//

import Foundation

func convertIntoString(input: Date) -> String {
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    return dateFormatter.string(from: input)
}

func convertIntoDate(input: String) -> Date {
    let dateFormatter = DateFormatter()
        // Set Date Format
        dateFormatter.dateFormat = "MMM dd, yyyy"
        // Convert String to Date
    return dateFormatter.date(from: input) ?? Date()
}
