//
// Coupon.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

/** Объект передачи информации о купоне облигации. */

public struct Coupon: Decodable {
    public let figi: String
    public let couponDate: Date
    public let couponNumber: String
    public let fixDate: Date
    public let payOneBond: MoneyValue
    public let couponType: CouponType
    public let couponStartDate: Date
    public let couponEndDate: Date
    public let couponPeriod: Int
}
