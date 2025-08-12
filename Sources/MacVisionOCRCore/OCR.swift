import Cocoa
import Vision

public class OCR {
  public init() {}

  private func getSupportedLanguages() -> [String] {
    // if #available(macOS 13, *) {
    //   let request = VNRecognizeTextRequest()
    //   do {
    //     return try request.supportedRecognitionLanguages()
    //   } catch {
    //     return ["zh-Hans", "zh-Hant", "en-US"]
    //   }
    // } else {
    //   return ["zh-Hans", "zh-Hant", "en-US"]
    // }
    return ["zh-Hans", "zh-Hant", "en", "vi", "id", "pt", "ms", "ja", "ko"]
  }

  var revision: Int {
    var REVISION: Int
    if #available(macOS 13, *) {
      REVISION = VNRecognizeTextRequestRevision3
    } else if #available(macOS 11, *) {
      REVISION = VNRecognizeTextRequestRevision2
    } else {
      REVISION = VNRecognizeAnimalsRequestRevision1
    }
    return REVISION
  }

  private func extractSubBounds(
    imageRef: CGImage, observation: VNRecognizedTextObservation, recognizedText: VNRecognizedText,
    positionalJson: inout [[String: Any]]
  ) {
    func normalizeCoordinate(_ value: CGFloat) -> CGFloat {
      return max(0, min(1, value))
    }

    let text = recognizedText.string
    let topLeft = observation.topLeft
    let topRight = observation.topRight
    let bottomRight = observation.bottomRight
    let bottomLeft = observation.bottomLeft

    let quad: [String: Any] = [
      "topLeft": [
        "x": normalizeCoordinate(topLeft.x),
        "y": normalizeCoordinate(1 - topLeft.y),
      ],
      "topRight": [
        "x": normalizeCoordinate(topRight.x),
        "y": normalizeCoordinate(1 - topRight.y),
      ],
      "bottomRight": [
        "x": normalizeCoordinate(bottomRight.x),
        "y": normalizeCoordinate(1 - bottomRight.y),
      ],
      "bottomLeft": [
        "x": normalizeCoordinate(bottomLeft.x),
        "y": normalizeCoordinate(1 - bottomLeft.y),
      ],
    ]

    positionalJson.append([
      "text": text,
      "confidence": observation.confidence,
      "quad": quad,
    ])
  }

  public func extractText(from imagePath: String) async throws -> String {
    guard let img = NSImage(byReferencingFile: imagePath) else {
      throw OCRError.imageLoadFailed(path: imagePath)
    }

    guard let cgImage = img.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
      throw OCRError.imageConversionFailed(path: imagePath)
    }

    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true

    request.recognitionLanguages = getSupportedLanguages()

    request.revision = revision

    request.minimumTextHeight = 0.01

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    try handler.perform([request])

    guard let observations = request.results else {
      throw OCRError.noTextFound
    }

    var positionalJson: [[String: Any]] = []
    var fullText: [String] = []

    for observation in observations {
      guard let candidate = observation.topCandidates(1).first else { continue }
      fullText.append(candidate.string)
      extractSubBounds(
        imageRef: cgImage, observation: observation, recognizedText: candidate,
        positionalJson: &positionalJson)
    }

    let combinedFullText = fullText.joined(separator: "\n")

    let fileManager = FileManager.default
    let absolutePath = (fileManager.currentDirectoryPath as NSString).appendingPathComponent(
      imagePath)

    let info: [String: Any] = [
      "filename": (imagePath as NSString).lastPathComponent,
      "filepath": absolutePath,
      "width": cgImage.width,
      "height": cgImage.height,
    ]

    let result: [String: Any] = [
      "info": info,
      "observations": positionalJson,
      "texts": combinedFullText,
    ]

    let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
    return String(data: jsonData, encoding: .utf8) ?? ""
  }
}

enum OCRError: Error {
  case imageLoadFailed(path: String)
  case imageConversionFailed(path: String)
  case jsonParsingFailed
  case noTextFound
}
