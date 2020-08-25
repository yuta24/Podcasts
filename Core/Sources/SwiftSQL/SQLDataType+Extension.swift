//
//  SQLDataType+Extension.swift
//  Core
//
//  Created by Yu Tawata on 2020/08/25.
//

import Foundation
import SQLite3
import SwiftSQL

extension Bool: SQLDataType {
    public func sqlBind(statement: OpaquePointer, index: Int32) {
        sqlite3_bind_int(statement, index, Int32(self ? 1 : 0))
    }

    public static func sqlColumn(statement: OpaquePointer, index: Int32) -> Bool {
        sqlite3_column_int(statement, index) == 0
    }
}

extension Date: SQLDataType {
    public func sqlBind(statement: OpaquePointer, index: Int32) {
        sqlite3_bind_double(statement, index, timeIntervalSince1970)
    }

    public static func sqlColumn(statement: OpaquePointer, index: Int32) -> Date {
        Date(timeIntervalSince1970: sqlite3_column_double(statement, index))
    }
}

extension URL: SQLDataType {
    public func sqlBind(statement: OpaquePointer, index: Int32) {
        absoluteString.sqlBind(statement: statement, index: index)
    }

    public static func sqlColumn(statement: OpaquePointer, index: Int32) -> URL {
        let pointer = sqlite3_column_text(statement, index)!
        let string = String(cString: pointer)
        return URL(string: string)!
    }
}
