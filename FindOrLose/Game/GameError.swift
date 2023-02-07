//
//  GameError.swift
//  FindOrLose
//
//  Created by Shilpa Joy on 2023-02-06.
//

import Foundation

enum GameError: Error {
  case statusCode
  case decoding
  case invalidImage
  case invalidUrl
  case other(Error)
  
  static func map(_ error: Error) -> GameError {
    return (error as? GameError) ?? .other(error)
  }
}
