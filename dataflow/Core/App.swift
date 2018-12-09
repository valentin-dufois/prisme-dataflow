//
//  App.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 04/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation

struct App {
	static let dataHolder = DataHolder.instance

	static var audioAnalysisQueue = DispatchQueue(label: "prisme.dataflow.audioAnalysis", qos: DispatchQoS.utility)

	/// The current emitter stream, if any
    weak static var emitterStream: EmitterStreamController?
}
