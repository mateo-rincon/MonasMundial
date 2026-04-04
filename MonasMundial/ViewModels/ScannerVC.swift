//
//  ScannerVC.swift
//  MonasMundial
//
//  Created by Mateo on 2/04/26.
//

import UIKit
import AVFoundation
import SwiftUI
import UIKit
import AVFoundation
import SwiftUI

class ScannerVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var vm: StickersViewModel
    var onScan: ((StickerCollection) -> Void)?
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    init(vm: StickersViewModel, onScan: @escaping (StickerCollection) -> Void) {
        self.vm = vm
        self.onScan = onScan
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            handleScan(stringValue)
        }
    }
    
    func handleScan(_ qrString: String) {
        guard let data = qrString.data(using: .utf8) else { return }
        
        do {
            // 1. Decodificamos el paquete del amigo (duplicates y missing)
            let otherCollection = try JSONDecoder().decode(StickerCollection.self, from: data)
            
            // 2. Pasamos el objeto decodificado al callback
            // La lógica de comparación (calculateMatches) se ejecutará en la vista de SwiftUI
            onScan?(otherCollection)
            
        } catch {
            print("❌ Error decodificando el QR: \(error)")
            // Reiniciar sesión si el QR no es válido para nuestra app
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.captureSession.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
}

// MARK: - Representable para SwiftUI
struct QRScannerView: UIViewControllerRepresentable {
    @ObservedObject var vm: StickersViewModel
    var onScan: (StickerCollection) -> Void
    
    func makeUIViewController(context: Context) -> ScannerVC {
        return ScannerVC(vm: vm, onScan: onScan)
    }
    
    func updateUIViewController(_ uiViewController: ScannerVC, context: Context) {}
}

