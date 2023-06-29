//
//  ViewController.swift
//  GetColor
//
//  Created by HuongLam on 26/01/2023.
//
import Foundation
import AVFoundation
import CoreVideo
import CoreGraphics
import PhotosUI
import UIKit
import QuartzCore
import CoreMedia
import Accelerate

//import CoreImageExtensions

enum PixelError: Error {
    case canNotSetupAVSession
}


protocol StartSessionProtocol{
    func startSession()
}

private var videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")


class ViewController:  UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var graphView: GraphView!
    @IBOutlet weak var cameraView: UIView!
    var session: AVCaptureSession!
    
    var videoDataOutput: AVCaptureVideoDataOutput!
    
    var cameraViewLayer: AVCaptureVideoPreviewLayer!
    var maskView: UIView!
    var selectedDevice: AVCaptureDevice?
    let previewLayerConnection : AVCaptureConnection! = nil
    var photoOutput = AVCapturePhotoOutput()
    
    
    var height = 0
    var width = 0
    var numberOfPixels = 0
    var startTime: CFAbsoluteTime!

    var timer: [Float] = []

    
    // used to compute frames per second
    var newDate:NSDate = NSDate()
    var oldDate:NSDate = NSDate()
    
    
    // needed to init image context
    var context:CIContext!
    
    
    
    // FFT setup stuff
    let windowSize = 512               // granularity of the measurement, error
    var log2n:vDSP_Length = 0
    let windowSizeOverTwo = 256         // for fft
    var fps:Float = 240.0                // fps === hz
    var setup:OpaquePointer!
    
    
    // collects data from image and stores for fft
       var dataCount = 0           // tracks how many data points we have ready for fft
       var fftLoopCount = 0        // how often we grab data between fft calls
    var inputSignal:[Float] = Array(repeating: 0.0, count: 512)

    
    var movingAverageArray:[CGFloat] = [0.0, 0.0, 0.0, 0.0, 0.0]      // used to store rolling average
    var movingAverageCount:CGFloat = 5.0                              // window size
    
    
    var arrayRed: [Float] = []
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        log2n = vDSP_Length(log2(Double(windowSize)))
        setup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2))
        graphView.setupGraphView()

    
    }
    
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        maskView.frame = cameraView.bounds
//        cameraViewLayer.frame = cameraView.bounds
//    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.session.stopRunning()
    }
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
   
//
//
//    func setupAVCapture(position: AVCaptureDevice.Position) throws {
//
//        if let existedSession = session, existedSession.isRunning {
//            existedSession.stopRunning()
//        }
//
//        session = AVCaptureSession()
//
//
//        session.sessionPreset = AVCaptureSession.Preset.hd1920x1080
//        height = 1920
//        width = 1080
//        numberOfPixels = height * width
//
//        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: position) else {
//            throw PixelError.canNotSetupAVSession
//        }
//
//        selectedDevice = device
//        let deviceInput = try AVCaptureDeviceInput(device: device)
//        guard session.canAddInput(deviceInput) else {
//            throw PixelError.canNotSetupAVSession
//        }
//
//        session.addInput(deviceInput)
//
//
//        videoDataOutput = AVCaptureVideoDataOutput()
//        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA]
//        videoDataOutput.alwaysDiscardsLateVideoFrames = true
//        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
//
//        guard session.canAddOutput(videoDataOutput) else {
//            throw PixelError.canNotSetupAVSession
//        }
//
//        session.addOutput(videoDataOutput)
//
//        guard let connection = videoDataOutput.connection(with: .video) else {
//            throw PixelError.canNotSetupAVSession
//        }
//
//        connection.isEnabled = true
//        preparecameraViewLayer(for: session)
//        DispatchQueue.global(qos: .background).async { [self] in //[weak self] in
//            session.startRunning()
//            configureDevice(captureDevice: selectedDevice!)
//            toggleTorch(device: selectedDevice!, on: true)
//        }
//
//
//    }
//
    
    
    
    
    func setupAVCapture(position: AVCaptureDevice.Position) throws {
        
        if let existedSession = session, existedSession.isRunning {
            existedSession.stopRunning()
        }
        
        session = AVCaptureSession()
        
        
        session.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        height = 1920
        width = 1080
        numberOfPixels = height * width
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: position) else {
            throw PixelError.canNotSetupAVSession
        }
        
        selectedDevice = device
        let deviceInput = try AVCaptureDeviceInput(device: device)
        guard session.canAddInput(deviceInput) else {
            throw PixelError.canNotSetupAVSession
        }
        
        session.addInput(deviceInput)
        
        
        videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA]
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        
        guard session.canAddOutput(videoDataOutput) else {
            throw PixelError.canNotSetupAVSession
        }
        
        session.addOutput(videoDataOutput)
        
        guard let connection = videoDataOutput.connection(with: .video) else {
            throw PixelError.canNotSetupAVSession
        }
        
        connection.isEnabled = true
        preparecameraViewLayer(for: session)
        DispatchQueue.global(qos: .background).async { [self] in //[weak self] in

            session.startRunning()
            toggleTorch(device: selectedDevice!, on: true)

//            configureDevice(captureDevice: selectedDevice!)
        }
        
        
    }
    
    
    func configureDevice(captureDevice:AVCaptureDevice ) {
        if let tempDevice = selectedDevice {

            // 1
            for vFormat in captureDevice.formats {
                // 2
                let ranges = vFormat.videoSupportedFrameRateRanges as [AVFrameRateRange]
                let frameRates = ranges[0]
                // 3
                if frameRates.maxFrameRate == 240 {
                    // 4
                    try! tempDevice.lockForConfiguration()

                    tempDevice.activeFormat = vFormat as AVCaptureDevice.Format
                    tempDevice.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: Int32(240))
                    tempDevice.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: Int32(240))
                    tempDevice.focusMode = AVCaptureDevice.FocusMode.locked

                }
            }
        }

    }
    
    func preparecameraViewLayer(for session: AVCaptureSession) {
        guard cameraViewLayer == nil else {
            cameraViewLayer.session = session
            return
        }
        
        cameraViewLayer = AVCaptureVideoPreviewLayer(session: session)
        cameraViewLayer.backgroundColor = UIColor.black.cgColor
        cameraViewLayer.videoGravity = .resizeAspectFill
        cameraView.layer.addSublayer(cameraViewLayer)
        
        maskView = UIView()
        cameraView.addSubview(maskView)
        cameraView.bringSubviewToFront(maskView)
        maskView.frame = cameraView.bounds
             cameraViewLayer.frame = cameraView.bounds
        
    }
    func toggleTorch(device: AVCaptureDevice,on: Bool) {
       try! device.lockForConfiguration()
        if device.hasTorch {
            if on == true {
            
                device.torchMode = .on
            } else {
                device.torchMode = .off
            }
            
            device.unlockForConfiguration()
        }
        
        else {
            print("Torch is not available")
        }
    }
    @IBAction func startMeasure(_ sender: Any) {
//        timeElapsedStart = NSDate()     // reset clock
       try! setupAVCapture(position: .back)
    }
    //
    @IBAction func stopTapped(_ sender: Any) {
        session.stopRunning()
        let fileName = "Tasks.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        var csvText = "Time,Red\n"
//        let filterRed = arrayRed.dropFirst(240)
//        let filterTimer = timer.dropFirst(240)
        for i in 0..<arrayRed.count{
            let red = arrayRed[i]
            let negativeValue = -red
            let replaceValue = "\(negativeValue)".replacingOccurrences(of: ".", with: ",")
            let newLine = "\(timer[i]),\(replaceValue)\n"
            csvText.append(newLine)
        }
        
        self.save(text: csvText, toDirectory: self.documentDirectory(), withFileName: "RedColor.csv")
        do {
            
            try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
        print(path ?? "not found")
    }
    
    
    func save(text: String,
              toDirectory directory: String,
              withFileName fileName: String) {
        guard let filePath = self.append(toPath: directory,
                                         withPathComponent: fileName) else {
            return
        }
        
        do {
            try text.write(toFile: filePath,
                           atomically: true,
                           encoding: .utf8)
            
            
            
        } catch {
            print("Error", error)
            return
        }
        
        print("Save successful to : \(directory)")
    }
    
    private func documentDirectory() -> String {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                    .userDomainMask,
                                                                    true)
        return documentDirectory[0]
    }
    
    private func append(toPath path: String,
                        withPathComponent pathComponent: String) -> String? {
        if var pathURL = URL(string: path) {
            pathURL.appendPathComponent(pathComponent)
            
            return pathURL.absoluteString
        }
        
        return nil
    }
    
    
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // calculate our actual fps
        newDate = NSDate()
        fps = 1.0/Float(newDate.timeIntervalSince(oldDate as Date))
        oldDate = newDate
        
       
         if let croppedSampleBuffer = cropSampleBuffer(sampleBuffer, cropRect: CGRect(x: 100, y: 100, width: 200, height: 200)) {
             
               // get the image from the camera
               let pixelBuffer = CMSampleBufferGetImageBuffer(croppedSampleBuffer)
               
               let unlockFlags =  CVPixelBufferLockFlags();
               
               // lock buffer
               CVPixelBufferLockBaseAddress(pixelBuffer!, unlockFlags);
               
               // grab image info
               let imageBuffer = CMSampleBufferGetImageBuffer(croppedSampleBuffer)
               
               // get pointer to the pixel array
               let src_buff = CVPixelBufferGetBaseAddress(imageBuffer!)
               let dataBuffer = src_buff!.assumingMemoryBound(to: UInt8.self)
               // unlock buffer
               CVPixelBufferUnlockBaseAddress(imageBuffer!, unlockFlags)
               
               
               
               // compute the brightness for reg, green, blue and total
               // pull out color values from pixels ---  image is BGRA
               var greenVector:[Float] = Array(repeating: 0.0, count: numberOfPixels)
               var blueVector:[Float] = Array(repeating: 0.0, count: numberOfPixels)
               var redVector:[Float] = Array(repeating: 0.0, count: numberOfPixels)
               vDSP_vfltu8(dataBuffer, 4, &blueVector, 1, vDSP_Length(numberOfPixels))
               vDSP_vfltu8(dataBuffer+1, 4, &greenVector, 1, vDSP_Length(numberOfPixels))
               vDSP_vfltu8(dataBuffer+2, 4, &redVector, 1, vDSP_Length(numberOfPixels))
               
               
               
               
               // compute average per color
               var redAverage:Float = 0.0
               var blueAverage:Float = 0.0
               var greenAverage:Float = 0.0
               
               
               // tính trung bình màu trong 1 khoảng numberOfPixels
               vDSP_meamgv(&redVector, 1, &redAverage, vDSP_Length(numberOfPixels))
               vDSP_meamgv(&greenVector, 1, &greenAverage, vDSP_Length(numberOfPixels))
               vDSP_meamgv(&blueVector, 1, &blueAverage, vDSP_Length(numberOfPixels))
       //
             
             
             print("====>red: \(redAverage)")
               
               arrayRed.append(redAverage)
               
               
               if startTime == nil {
                          startTime = CFAbsoluteTimeGetCurrent()
                      }
                      
                      // Process the video frame here
                      
                      let currentTime = CFAbsoluteTimeGetCurrent()
                      let elapsedTime = currentTime - startTime
               timer.append(Float(elapsedTime))

                      
               
             
               var hue: CGFloat = 0.0
                    var saturation: CGFloat = 0.0
                    var brightness: CGFloat = 0.0
                    var alpha: CGFloat = 1.0
                    
               let color: UIColor = UIColor(red: CGFloat(redAverage/255.0), green: CGFloat(greenAverage/255.0), blue: CGFloat(blueAverage/255.0), alpha: alpha)
                    color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
                    
                    
                    
                    
                    // 5 count rolling average
       //             let currentHueAverage = hue/movingAverageCount
       //             movingAverageArray.remove(at: 0)
       //             movingAverageArray.append(currentHueAverage)
                    
       //             let movingAverage = movingAverageArray[0] + movingAverageArray[1] + movingAverageArray[2] + movingAverageArray[3] + movingAverageArray[4]
                    
                    
                    
                    
                    // send to graph and fft
                  
               DispatchQueue.global(qos: .background).async {

                   // Background Thread

                   DispatchQueue.main.async {
                       self.graphView.addX(x: Float(redAverage))
                       self.collectDataForFFT(red: Float(redAverage), green: Float(saturation), blue: Float(brightness))
                   }
               }
               
        }
    }
    func collectDataForFFT( red: Float, green: Float, blue: Float ){
          
          // first fill up array
          if  dataCount < windowSize {
              inputSignal[dataCount] = red
              dataCount+=1
              
              // then pop oldest off top push newest onto end
          }else{
              
              inputSignal.remove(at: 0)
              inputSignal.append(red)
          }
          
          
          
          // call fft ~ once per second
          if  fftLoopCount > Int(fps) {
              fftLoopCount = 0
              FFT()
              
          }else{ fftLoopCount+=1; }
          
          
      }
      
      
      
      
      
      func FFT(){
          
          
          // parse data input into complex vector
          var zerosR = [Float](repeating: 0.0, count: windowSizeOverTwo)
          var zerosI = [Float](repeating: 0.0,count: windowSizeOverTwo)
          var cplxData = DSPSplitComplex( realp: &zerosR, imagp: &zerosI )
          
          
          
          inputSignal.withUnsafeBufferPointer {buffer in
              buffer.baseAddress!.withMemoryRebound(to: DSPComplex.self, capacity: inputSignal.count / (MemoryLayout<DSPComplex>.size/MemoryLayout<Float>.size)) {xAsComplex in
                  vDSP_ctoz( xAsComplex, 2, &cplxData, 1, vDSP_Length(windowSizeOverTwo) )

              }
          }
          
          
          
          //perform fft
          vDSP_fft_zrip( setup, &cplxData, 1, log2n, FFTDirection(kFFTDirection_Forward) )
          
          
          
          //calculate power
          var powerVector = [Float](repeating: 0.0, count: windowSize)
          vDSP_zvmags(&cplxData, 1, &powerVector, 1, vDSP_Length(windowSizeOverTwo))
          
          // find peak power and bin
          var power = 0.0 as Float
          var bin = 0 as vDSP_Length
          
          
          
          
          // calculate heart rate, ie pulse
          // course bandwidth filter --- skip hr under/over unreasonable amounts
          let minHeartRate = 20                                       // skip anything lower ~35 bpm
          let maxHeartRate = Double(windowSizeOverTwo) / 4            // skip anything over ~225 bpm
          vDSP_maxvi(&powerVector+minHeartRate, 1, &power, &bin, vDSP_Length(maxHeartRate))
          bin += vDSP_Length(minHeartRate)
          
          
          
          
          // push heart rate data to the user
//          let timeElapsed = NSDate().timeIntervalSinceDate(timeElapsedStart)
//          timeLabel.text = NSString(format: "Seconds: %d", Int(timeElapsed)) as String
          
          let binSize = fps * 60.0 / Float(windowSize)
          let errorSize = fps * 60.0 / Float(windowSize)
          
          let bpm = Float(bin) / Float(windowSize) * (fps * 60.0)
          print("bpm: \(bpm)")
//          pulseLabel.text = ("\(Int(bpm))")
          
          
      }
}

