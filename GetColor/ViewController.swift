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

private var videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")



class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var torchSlider: UISlider!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var graphView: GraphView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
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
    var isMeasuring = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        log2n = vDSP_Length(log2(Double(windowSize)))
        setup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2))
        graphView.setupGraphView()
        startButton.isEnabled = true
        stopButton.isEnabled = false
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.session.stopRunning()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    
    
    
    @IBAction func onChangeTorch(_ sender: Any) {
        
        let value = torchSlider.value > 0 ? torchSlider.value : 0.1
        DispatchQueue.main.async { [self] in
            do {
                try selectedDevice!.setTorchModeOn(level: value)
            }
            catch  {
                print("set torch mode on failed")
            }
        }
        
    }
    
    
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
        try! setupAVCapture(position: .back)
        startButton.isEnabled = false
        stopButton.isEnabled = true
    }
    //
    @IBAction func stopTapped(_ sender: Any) {
        session.stopRunning()
        startButton.isEnabled = true
        stopButton.isEnabled = false
        
        let fileName = "Tasks.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        var csvText = "Time,Red\n"
        print("===> timer: \(timer.count)")
        print("===> arrayRed: \(arrayRed.count)")
        
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
            isMeasuring = false
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
            
            
            
            arrayRed.append(redAverage)
            
            
            if startTime == nil {
                startTime = CFAbsoluteTimeGetCurrent()
                
            }
            let currentTime = CFAbsoluteTimeGetCurrent()
            let elapsedTime = currentTime - startTime
            timer.append(Float(elapsedTime))
            
            // Process the video frame here
            
            
            var hue: CGFloat = 0.0
            var saturation: CGFloat = 0.0
            var brightness: CGFloat = 0.0
            var alpha: CGFloat = 1.0
            
            let color: UIColor = UIColor(red: CGFloat(redAverage/255.0), green: CGFloat(greenAverage/255.0), blue: CGFloat(blueAverage/255.0), alpha: alpha)
            color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            
            DispatchQueue.global(qos: .background).async {
                // Background Thread
                
                DispatchQueue.main.async {
                    self.graphView.addX(x: Float(redAverage))
                    
                }
            }
            
        }
        
        
        
    }
    
}

