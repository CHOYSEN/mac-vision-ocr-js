import MacVisionOCRCore
import NodeAPI

#NodeModule(exports: [
  "recognizeText": try NodeFunction { (imagePath: String) in
    let ocr = OCR()
    let result = try await ocr.extractText(from: imagePath)
    return result
  }
])
