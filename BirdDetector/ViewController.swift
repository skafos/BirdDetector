//
//  ViewController.swift
//  BirdDetector
//
//  Created by Skafos on 9/5/19.
//  Copyright © 2019 Skafos LLC. All rights reserved.
//

import Skafos
import UIKit
import AVKit
import SoundAnalysis


class ViewController: UIViewController {
    
    let modelName = "BirdSoundClassifier"
    let soundClassifier = BirdSoundClassifier()
    let engine = AVAudioEngine()
    var inputFormat: AVAudioFormat!
    var analyzer: SNAudioStreamAnalyzer!
    var resultsObserver = BirdSoundClassifierResults()
    let analysisQueue = DispatchQueue(label: "com.apple.AnalysisQueue")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check for new model and reload
        reloadModel()
        
        self.view.backgroundColor = .black
        
        // Do any additional setup after loading the view.
        resultsObserver.delegate = self
        inputFormat = engine.inputNode.inputFormat(forBus: 0)
        analyzer = SNAudioStreamAnalyzer(format: inputFormat)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startCapturingAudio()
        
        do {
            try engine.start()
        } catch {
            print("Failed to start your engine")
        }
    }
    
    private func reloadModel() {
        // Skafos load new model if there is one
        Skafos.load(asset: self.modelName) { (error, asset) in
            // Log the asset in the console
            console.info(asset)
            guard error == nil else {
                console.error("Skafos load error: \(String(describing: error))")
                return
            }
            if let model = asset.model {
                // Assign model to the sound classifier class
                self.soundClassifier.model = model
            }
        }
    }
    
    private func startCapturingAudio() {
        print("starting audio capture")

        do {
            let request = try SNClassifySoundRequest(mlModel: soundClassifier.model)
            try analyzer.add(request, withObserver: resultsObserver)
        } catch {
            print("Unable to prepare request: \(error.localizedDescription)")
            return
        }
       
        engine.inputNode.installTap(onBus: 0, bufferSize: 8000, format: inputFormat) { buffer, time in
            let channelDataValue = buffer.floatChannelData!.pointee
            let channelDataValueArray = stride(from: 0,
                                               to: Int(buffer.frameLength),
                                               by: buffer.stride).map{ channelDataValue[$0] }

            let v = channelDataValueArray.map{ $0 * $0 }.reduce(0, +) / Float(buffer.frameLength)
            let rms = sqrt(v)
            let avgPower = 20 * log10(rms)
            if avgPower > -50.0 {
                self.analysisQueue.async {
                    self.analyzer.analyze(buffer, atAudioFramePosition: time.sampleTime)
                }
            }
        }
    }
    
    func createAndAnimateSoundTypeLabel(soundType: String) {
        DispatchQueue.main.async {
            let label = UILabel(frame: CGRect(x: (self.view.frame.size.width / 2) - 150, y: self.view.frame.size.height - 50, width: 300, height: 50))
            label.text = "\(soundType)"
            label.font = .systemFont(ofSize: 42)
            label.textAlignment = .center
            label.textColor = .white
            
            self.view.addSubview(label)

            UIView.animate(withDuration: 5.0, animations: {
                label.frame = CGRect(x: label.frame.origin.x, y: -100, width: label.frame.size.width, height: label.frame.size.height)
            }) { (done) in
                label.removeFromSuperview()
            }
        }
    }
}

extension ViewController: BirdSoundClassifierResultsDelegate {
    func determinedSoundType(identifier: String, confidence: Double) {
        createAndAnimateSoundTypeLabel(soundType: identifier)
    }
}

class BirdSoundClassifierResults: NSObject, SNResultsObserving {
    var delegate: BirdSoundClassifierResultsDelegate?
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult,
            let classification = result.classifications.first else { return }

        let confidence = classification.confidence * 100.0
        print(classification)
        if confidence > 90 {
            delegate?.determinedSoundType(identifier: classification.identifier, confidence: confidence)
        }
    }
}

protocol BirdSoundClassifierResultsDelegate {
    func determinedSoundType(identifier: String, confidence: Double)
}

