import SwiftUI
import VisionKit

/// Caméra de scan de codes-barres basée sur VisionKit (framework Apple).
/// Appelle `onCode` au premier code-barres détecté.
struct BarcodeScannerView: UIViewControllerRepresentable {
    var onCode: (String) -> Void

    /// Vrai si l'appareil prend en charge le scan (faux sur simulateur / sans caméra).
    static var estDisponible: Bool {
        DataScannerViewController.isSupported && DataScannerViewController.isAvailable
    }

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [.ean13, .ean8, .upce, .code128])],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ scanner: DataScannerViewController, context: Context) {
        try? scanner.startScanning()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onCode: onCode)
    }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onCode: (String) -> Void
        private var dejaEnvoye = false

        init(onCode: @escaping (String) -> Void) {
            self.onCode = onCode
        }

        func dataScanner(_ dataScanner: DataScannerViewController,
                         didAdd addedItems: [RecognizedItem],
                         allItems: [RecognizedItem]) {
            traiter(addedItems)
        }

        func dataScanner(_ dataScanner: DataScannerViewController,
                         didTapOn item: RecognizedItem) {
            traiter([item])
        }

        private func traiter(_ items: [RecognizedItem]) {
            guard !dejaEnvoye else { return }
            for item in items {
                if case let .barcode(barcode) = item,
                   let valeur = barcode.payloadStringValue, !valeur.isEmpty {
                    dejaEnvoye = true
                    onCode(valeur)
                    return
                }
            }
        }
    }
}
