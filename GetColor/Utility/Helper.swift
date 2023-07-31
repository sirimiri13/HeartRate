//
//  Helper.swift
//  GetColor
//
//  Created by Hương Lâm Quỳnh on 18/06/2023.
//

import Foundation
import AVFoundation
import PhoneNumberKit
//
//func cropSampleBuffer(_ sampleBuffer: CMSampleBuffer, cropRect: CGRect) -> CMSampleBuffer? {
//    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
//        return nil
//    }
//
//    let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer)
//    let originalWidth = CVPixelBufferGetWidth(pixelBuffer)
//    let originalHeight = CVPixelBufferGetHeight(pixelBuffer)
//
//    let cropRectNormalized = CGRect(x: cropRect.origin.x / CGFloat(originalWidth),
//                                     y: cropRect.origin.y / CGFloat(originalHeight),
//                                     width: cropRect.size.width / CGFloat(originalWidth),
//                                     height: cropRect.size.height / CGFloat(originalHeight))
//
//    let croppedWidth = Int(cropRectNormalized.size.width * CGFloat(originalWidth))
//    let croppedHeight = Int(cropRectNormalized.size.height * CGFloat(originalHeight))
//
//    var croppedPixelBuffer: CVPixelBuffer?
//    let status = CVPixelBufferCreate(nil, croppedWidth, croppedHeight, CVPixelBufferGetPixelFormatType(pixelBuffer), nil, &croppedPixelBuffer)
//    print("====> status \(status)")
//    guard status == kCVReturnSuccess, let croppedPixelBuffer = croppedPixelBuffer else {
//        return nil
//    }
//
//    CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
//    CVPixelBufferLockBaseAddress(croppedPixelBuffer, [])
//
//    let bytesPerPixel = 4 // Assuming RGBA pixel format
//    let srcBytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
//    let destBytesPerRow = CVPixelBufferGetBytesPerRow(croppedPixelBuffer)
//
//    let srcStartAddress = CVPixelBufferGetBaseAddress(pixelBuffer)!
//        .advanced(by: Int(cropRectNormalized.origin.y * CGFloat(srcBytesPerRow)))
//        .advanced(by: Int(cropRectNormalized.origin.x * CGFloat(bytesPerPixel)))
//    let destStartAddress = CVPixelBufferGetBaseAddress(croppedPixelBuffer)!
//
//    for row in 0..<croppedHeight {
//        let srcAddress = srcStartAddress.advanced(by: row * srcBytesPerRow)
//        let destAddress = destStartAddress.advanced(by: row * destBytesPerRow)
//        memcpy(destAddress, srcAddress, croppedWidth * bytesPerPixel)
//    }
//
//    CVPixelBufferUnlockBaseAddress(croppedPixelBuffer, [])
//    CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
//
//    var newSampleBuffer: CMSampleBuffer?
//    var timingInfo = CMSampleTimingInfo(duration: CMSampleBufferGetDuration(sampleBuffer),
//                                        presentationTimeStamp: CMSampleBufferGetPresentationTimeStamp(sampleBuffer),
//                                        decodeTimeStamp: CMSampleBufferGetDecodeTimeStamp(sampleBuffer))
//    let status2 = CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault,
//                                                     imageBuffer: croppedPixelBuffer,
//                                                     dataReady: true,
//                                                     makeDataReadyCallback: nil,
//                                                     refcon: nil,
//                                                     formatDescription: formatDescription!,
//                                                     sampleTiming: &timingInfo,
//                                                     sampleBufferOut: &newSampleBuffer)
//
//    if status2 != noErr {
//        return nil
//    }
//
//    return newSampleBuffer
//}

//// Example usage
//let sampleBuffer = /* your original CMSampleBuffer */
//if let croppedSampleBuffer = cropSampleBuffer(sampleBuffer, cropRect: CGRect(x: 100, y:



func cropSampleBuffer(_ sampleBuffer: CMSampleBuffer, cropRect: CGRect) -> CMSampleBuffer? {
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
        return nil
    }
    
    let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer)
    let originalWidth = CVPixelBufferGetWidth(pixelBuffer)
    let originalHeight = CVPixelBufferGetHeight(pixelBuffer)
    
    let cropRectNormalized = CGRect(x: cropRect.origin.x / CGFloat(originalWidth),
                                     y: cropRect.origin.y / CGFloat(originalHeight),
                                     width: cropRect.size.width / CGFloat(originalWidth),
                                     height: cropRect.size.height / CGFloat(originalHeight))
    
    let croppedWidth = Int(cropRectNormalized.size.width * CGFloat(originalWidth))
    let croppedHeight = Int(cropRectNormalized.size.height * CGFloat(originalHeight))
    
    var timingInfo = CMSampleTimingInfo()
    CMSampleBufferGetSampleTimingInfo(sampleBuffer, at: 0, timingInfoOut: &timingInfo)
    
    var newSampleBuffer: CMSampleBuffer?
    let status = CMSampleBufferCreateCopy(allocator: kCFAllocatorDefault, sampleBuffer: sampleBuffer, sampleBufferOut: &newSampleBuffer)
    
    guard status == noErr, let newSampleBuffer = newSampleBuffer else {
        return nil
    }
    
    guard let croppedPixelBuffer = cropPixelBuffer(pixelBuffer, cropRect: cropRectNormalized, croppedWidth: croppedWidth, croppedHeight: croppedHeight) else {
        return nil
    }
    
    let attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, createIfNecessary: true)
    let attachment = unsafeBitCast(CFArrayGetValueAtIndex(attachments, 0), to: CFMutableDictionary.self)
    
    CMSetAttachment(newSampleBuffer, key: "cropped_sample" as CFString, value: croppedPixelBuffer, attachmentMode: kCMAttachmentMode_ShouldNotPropagate)
    
    return newSampleBuffer
}

func cropPixelBuffer(_ pixelBuffer: CVPixelBuffer, cropRect: CGRect, croppedWidth: Int, croppedHeight: Int) -> CVPixelBuffer? {
    var croppedPixelBuffer: CVPixelBuffer?
    let status = CVPixelBufferCreate(nil, croppedWidth, croppedHeight, CVPixelBufferGetPixelFormatType(pixelBuffer), nil, &croppedPixelBuffer)
    
    guard status == kCVReturnSuccess, let croppedPixelBuffer = croppedPixelBuffer else {
        return nil
    }
    
    CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
    CVPixelBufferLockBaseAddress(croppedPixelBuffer, [])
    
    let bytesPerPixel = 4 // Assuming RGBA pixel format
    let srcBytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
    let destBytesPerRow = CVPixelBufferGetBytesPerRow(croppedPixelBuffer)
    
    let srcStartAddress = CVPixelBufferGetBaseAddress(pixelBuffer)!
    let destStartAddress = CVPixelBufferGetBaseAddress(croppedPixelBuffer)!
    
    let srcCropX = Int(cropRect.origin.x * CGFloat(CVPixelBufferGetWidth(pixelBuffer)))
    let srcCropY = Int(cropRect.origin.y * CGFloat(CVPixelBufferGetHeight(pixelBuffer)))
    
    for row in 0..<croppedHeight {
        let srcAddress = srcStartAddress.advanced(by: (srcCropY + row) * srcBytesPerRow + srcCropX * bytesPerPixel)
        let destAddress = destStartAddress.advanced(by: row * destBytesPerRow)
        memcpy(destAddress, srcAddress, croppedWidth * bytesPerPixel)
    }
    
    CVPixelBufferUnlockBaseAddress(croppedPixelBuffer, [])
    CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
    
    return croppedPixelBuffer
}

