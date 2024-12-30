//
//  WeekDaysTransformer.swift
//  Tracker
//
//  Created by Olga Trofimova on 20.12.2024.
//

import Foundation

@objc
final class WeekDaysTransformer: ValueTransformer {
    
    static func register() {
        ValueTransformer.setValueTransformer(
            WeekDaysTransformer(),
            forName: NSValueTransformerName(String(describing: WeekDaysTransformer.self))
        )
    }
    
    override class func transformedValueClass() -> AnyClass {
        NSData.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? [WeekDay] else { return nil }
        return try? JSONEncoder().encode(days)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        return try? JSONDecoder().decode([WeekDay].self, from: data as Data)
    }
}
