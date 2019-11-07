# Dataflow

![plateform: ios](https://img.shields.io/badge/plateform-ios-lightgrey)

Dataflow appears within *DIALOG*, an interactive installation from the art collective [PRISME](https://prisme.studio/) (Québec). *DIALOG* intends to emphasize the various aspects of language that an individual may leave during a conversation. 

The Dataflow application collects and parses different features from the user's speech in order to be used within a third-party application (*e.g.* Touchdesigner for generative visuals). The application is composed of an audio processing section as well as a speech transcription part, supported by a machine learning emotion recognition algorithm.

## How to

The application is made to run on iOS 12.2+. Testing has only been done on iPhone, but it should work the same way on an iPad.

Dataflow uses the [AudioKit](https://github.com/AudioKit/AudioKit) framework to perform real-time audio-analysis on the microphone input. Apple [Speech Framework](https://developer.apple.com/documentation/speech) is also used to get an (almost) real-time transcription of what the speaker is saying. By default, the locale is set to French Canadian but it can be changed in `speechRecognizer.swift:19`.
Emotions are detected from the transcribed phrases using a machine learning model that takes into input the current phrase and outputs the ID of an emotion.

### Getting data

A device set as Emitter can transmit the calculated audio data as JSON to a server. The transmission is done through a barebone TCP connection. Transmitted informations are 
* Audio Amplitude
* Audio Frequency
* The spoken phrase transcripion, if any
* The current emotion

### Using with two devices

The application supports connecting two devices together, simulating a classic phone call, through the use of Apple [MultipeerConnectivity Framework](https://developer.apple.com/documentation/multipeerconnectivity). This framework allows for interconnecting multiple devices using Bluetooth or Wi-Fi.
To enable this, one device must be set as Emitter, and the other one as Receiver. In this scenario, only the Emitter data are sent to the server. 

## Installations

This app uses CocoaPods dependecies, make sure to `$ pod install`  before building.

The pods `SwiftSocket` and `Repeat` tends to have version problem. Xcode raises errors as their version of Swift is too old, but they are fully compatible with current version. You just have to change the Swift version for these pods manually.


