//
//  AKFlatFrequencyResponseReverb.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/3/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import AVFoundation

public class AKFlatFrequencyResponseReverb: AKOperation {

    var internalAU: AKFlatFrequencyResponseReverbAudioUnit?

    var reverbDurationParameter: AUParameter?
    
    var token: AUParameterObserverToken?

    public var reverbDuration: Float = 0.5 {
        didSet {
            reverbDurationParameter?.setValue(reverbDuration, originator: token!)
        }
    }

    public init(_ input: AKOperation, loopDuration: Float) {
        super.init()
        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x616c7073 /*'alps'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKFlatFrequencyResponseReverbAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKFlatFrequencyResponseReverb",
            version: UInt32.max)

        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in
            
            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.output = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKFlatFrequencyResponseReverbAudioUnit
            AKManager.sharedInstance.engine.attachNode(self.output!)
            AKManager.sharedInstance.engine.connect(input.output!, to: self.output!, format: nil)
        }

        guard let tree = internalAU?.parameterTree else { return }

        reverbDurationParameter = tree.valueForKey("reverbDuration") as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in
            
            dispatch_async(dispatch_get_main_queue()) {
                self.reverbDuration = value
            }
        }

    }
}
