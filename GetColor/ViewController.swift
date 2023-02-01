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


class ViewController: UIViewController,StartSessionProtocol, AVCaptureVideoDataOutputSampleBufferDelegate {
    func startSession() {
        session.startRunning()
    }
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var graphView: GraphView!
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
    
    
    var movingAverageArray:[CGFloat] = [0.0, 0.0, 0.0, 0.0, 0.0]      // used to store rolling average
    var movingAverageCount:CGFloat = 5.0                              // window size
    

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try setupAVCapture(position: .back)
        }
        catch {
            print(error)
        }
        
        log2n = vDSP_Length(log2(Double(windowSize)))
        setup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2))
        
        // init graphs
        graphView.setupGraphView()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        maskView.frame = cameraView.bounds
        cameraViewLayer.frame = cameraView.bounds
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.session.stopRunning()
    }

    func setupAVCapture(position: AVCaptureDevice.Position) throws {
        
        if let existedSession = session, existedSession.isRunning {
            existedSession.stopRunning()
        }
        
        session = AVCaptureSession()
        

               session.sessionPreset = AVCaptureSession.Preset.cif352x288
               height = 352
               width = 288
               numberOfPixels = height * width
//                session.sessionPreset = .hd1920x1080
        //
//        guard let device = AVCaptureDevice.default( for: AVMediaType.video, position: position) else {
//            throw PixelError.canNotSetupAVSession
//        }
        
//        guard let device = AVCaptureDevice.default( for: .video) else{
//            throw PixelError.canNotSetupAVSession
//        }
        guard let device = AVCaptureDevice.default(.builtInTelephotoCamera, for: AVMediaType.video, position: position) else {
            throw PixelError.canNotSetupAVSession
        }
        selectedDevice = device
        let deviceInput = try AVCaptureDeviceInput(device: device)
        guard session.canAddInput(deviceInput) else {
            throw PixelError.canNotSetupAVSession
        }
        
        toggleTorch(device: selectedDevice!, on: true)
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
            //Step 13
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
        
    }
    
    func toggleTorch(device: AVCaptureDevice,on: Bool) {

        if device.hasTorch {
            do {
                try device.lockForConfiguration()

                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }

                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }

   
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // calculate our actual fps
        newDate = NSDate()
        print("new date: \(Float(newDate.timeIntervalSince(oldDate as Date)))")
        fps = 1.0/Float(newDate.timeIntervalSince(oldDate as Date))
        print("FPS: \(fps)")
        oldDate = newDate
        
        
        // get the image from the camera
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        
        let unlockFlags =  CVPixelBufferLockFlags();

        // lock buffer
        CVPixelBufferLockBaseAddress(pixelBuffer!, unlockFlags);
        
        // grab image info
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        
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
        
        vDSP_meamgv(&redVector, 1, &redAverage, vDSP_Length(numberOfPixels))
        vDSP_meamgv(&greenVector, 1, &greenAverage, vDSP_Length(numberOfPixels))
        vDSP_meamgv(&blueVector, 1, &blueAverage, vDSP_Length(numberOfPixels))
        
        
        
        // convert to HSV ( hue, saturation, value )
        // this gives faster, more accurate answer
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 1.0
        let color: UIColor = UIColor(red: CGFloat(redAverage/255.0), green: CGFloat(greenAverage/255.0), blue: CGFloat(blueAverage/255.0), alpha: alpha)
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        
        
        
        // 5 count rolling average
        let currentHueAverage = hue/movingAverageCount
        movingAverageArray.remove(at: 0)
        movingAverageArray.append(currentHueAverage)
        
        let movingAverage = movingAverageArray[0] + movingAverageArray[1] + movingAverageArray[2] + movingAverageArray[3] + movingAverageArray[4]
        DispatchQueue.global(qos: .background).async {

            // Background Thread

            DispatchQueue.main.async {
                self.graphView.addX(x: Float(movingAverage))
//                self.collectDataForFFT(red: Float(movingAverage), green: Float(saturation), blue: Float(brightness))
            }
        }
        
    }
}

