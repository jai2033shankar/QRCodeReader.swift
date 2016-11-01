/*
 * QRCodeReader.swift
 *
 * Copyright 2014-present Yannick Loriot.
 * http://yannickloriot.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

import UIKit
import AVFoundation

class ViewController: UIViewController, QRCodeReaderViewControllerDelegate {
  lazy var reader = QRCodeReaderViewController(builder: QRCodeReaderViewControllerBuilder {
    $0.reader          = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
    $0.showTorchButton = true
  })

  @IBAction func scanAction(sender: AnyObject) {
    if QRCodeReader.supportsMetadataObjectTypes() {
      reader.modalPresentationStyle = .FormSheet
      reader.delegate               = self

      reader.completionBlock = { (result: QRCodeReaderResult?) in
        if let result = result {
          print("Completion with result: \(result.value) of type \(result.metadataType)")
        }
      }

      presentViewController(reader, animated: true, completion: nil)
    }
    else {
      let alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .Alert)
      alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))

      presentViewController(alert, animated: true, completion: nil)
    }
  }

  // MARK: - QRCodeReader Delegate Methods

  func reader(reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
    reader.stopScanning()

    dismissViewControllerAnimated(true) { [weak self] in
      let alert = UIAlertController(
        title: "QRCodeReader",
        message: String (format:"%@ (of type %@)", result.value, result.metadataType),
        preferredStyle: .Alert
      )
      alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))

      self?.presentViewController(alert, animated: true, completion: nil)
    }
  }
  
  func reader(reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
    if let cameraName = newCaptureDevice.device.localizedName {
      print("Switching capturing to: \(cameraName)")
    }
  }
  
  func readerDidCancel(reader: QRCodeReaderViewController) {
    reader.stopScanning()

    dismissViewControllerAnimated(true, completion: nil)
  }
}
