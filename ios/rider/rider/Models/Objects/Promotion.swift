//
//  Promotion.swift
//
//  Created by Minimalistic Apps on 11/15/18
//  Copyright (c) . All rights reserved.
//

import Foundation

public final class Promotion: Codable {

  // MARK: Properties
  public var id: Int?
  public var description: String?
  public var title: String?
  public var startTimestamp: Double?
  public var expirationTimestamp: Double?
  //public  var daysLeft : Int?
    public  var daysLeft: Int {
        let currentDate = Date()
        let expirationDate = Date(timeIntervalSince1970: (expirationTimestamp ?? 0) / 1000) // Convert to Date
        let differenceInSeconds = expirationDate.timeIntervalSince(currentDate)
        let daysLeft = Int(differenceInSeconds / (60 * 60 * 24))
        return daysLeft
    }
}
