//
// CouponType.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

/** Тип купонов. */

public enum CouponType: String, Codable {
    case unspecified = "COUPON_TYPE_UNSPECIFIED"
    case constant = "COUPON_TYPE_CONSTANT"
    case floating = "COUPON_TYPE_FLOATING"
    case discount = "COUPON_TYPE_DISCOUNT"
    case mortgage = "COUPON_TYPE_MORTGAGE"
    case fix = "COUPON_TYPE_FIX"
    case variable = "COUPON_TYPE_VARIABLE"
    case other = "COUPON_TYPE_OTHER"
}