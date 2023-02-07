//
//  GameViewController.swift
//  FindOrLose
//
//  Created by Shilpa Joy on 2023-02-03.
//

import UIKit
import Combine

class GameViewController: UIViewController {
  // MARK: - Variables

  var subscription: Set<AnyCancellable> = []
  var gameState: GameState = .stop {
    didSet {
      switch gameState {
        case .play:
          playGame()
        case .stop:
          stopGame()
      }
    }
  }

  var gameImages: [UIImage] = []
  var gameTimer: Timer?
  var gameLevel = 0
  var gameScore = 0

  // MARK: - Outlets

  @IBOutlet weak var gameStateButton: UIButton!

  @IBOutlet weak var gameScoreLabel: UILabel!

  @IBOutlet var gameImageView: [UIImageView]!

  @IBOutlet var gameImageButton: [UIButton]!

  @IBOutlet var gameImageLoader: [UIActivityIndicatorView]!

  // MARK: - View Controller Life Cycle

  override func viewDidLoad() {
    precondition(!UnsplashAPI.accessToken.isEmpty, "Please provide a valid Unsplash access token!")

    title = "Find or Lose"
    gameScoreLabel.text = "Score: \(gameScore)"
  }

  // MARK: - Game Actions

  @IBAction func playOrStopAction(sender: UIButton) {
    gameState = gameState == .play ? .stop : .play
  }

  @IBAction func imageButtonAction(sender: UIButton) {
    let selectedImages = gameImages.filter { $0 == gameImages[sender.tag] }
    
    if selectedImages.count == 1 {
      playGame()
    } else {
      gameState = .stop
    }
  }

  // MARK: - Game Functions

  func playGame() {
    gameTimer?.invalidate()
    
    gameStateButton.setTitle("Stop", for: .normal)
    
    gameLevel += 1
    title = "Level: \(gameLevel)"
    
    gameScoreLabel.text = "Score: \(gameScore)"
    gameScore += 200
    
    resetImages()
    startLoaders()
    
    let firstImage = UnsplashAPI.randomImage()
      .flatMap { randomImageResponse in
        ImageDownloader.download(url: randomImageResponse.urls.regular)
      }
    let secoundImage = UnsplashAPI.randomImage()
      .flatMap { randomImageResponse in
        ImageDownloader.download(url: randomImageResponse.urls.regular)
      }
    
      firstImage.zip(secoundImage)
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { [unowned self]  completion in
      switch completion {
      case .finished: break
      case .failure(let error):
        print("Error\(error)")
        self.gameState = .stop
      }
    }, receiveValue: { [unowned self] first, secound in
      self.gameImages = [first, secound, secound, secound].shuffled()
      self.gameScoreLabel.text = "Score: \(self.gameScore)"
      
      self.gameTimer = Timer
        .scheduledTimer(withTimeInterval: 0.1, repeats: true) { [unowned self] timer in
        self.gameScoreLabel.text = "Score: \(self.gameScore)"

        self.gameScore -= 10

        if self.gameScore <= 0 {
          self.gameScore = 0

          timer.invalidate()
        }
      }
      
      self.stopLoaders()
      self.setImages()
    })
      .store(in: &subscription)
  }

  func stopGame() {
    gameTimer?.invalidate()

    gameStateButton.setTitle("Play", for: .normal)

    title = "Find or Lose"

    gameLevel = 0

    gameScore = 0
    gameScoreLabel.text = "Score: \(gameScore)"

    stopLoaders()
    resetImages()
  }

  // MARK: - UI Functions

  func setImages() {
    if gameImages.count == 4 {
      for (index, gameImage) in gameImages.enumerated() {
        gameImageView[index].image = gameImage
      }
    }
  }

  func resetImages() {
    gameImages = []

    gameImageView.forEach { $0.image = nil }
  }

  func startLoaders() {
    gameImageLoader.forEach { $0.startAnimating() }
  }

  func stopLoaders() {
    gameImageLoader.forEach { $0.stopAnimating() }
  }
}
