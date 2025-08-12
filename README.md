# Mac Vision OCR

一个使用 macOS 原生 Vision 框架的 OCR (光学字符识别) 命令行工具，支持中文和英文文本识别。

## 功能特性

- 🔍 **高精度识别**：使用 macOS 原生 Vision 框架，支持高质量的文本识别
- 🌏 **多语言支持**：支持简体中文、繁体中文和英文
- 📊 **多种输出格式**：支持纯文本和 JSON 格式输出
- 📦 **批量处理**：支持同时处理多个图片文件
- 🎯 **详细信息**：可显示置信度、边界框等详细识别信息
- 💾 **文件输出**：支持将结果保存到文件

## 系统要求

- macOS 12.0 或更高版本
- Swift 5.9 或更高版本
- Xcode 14 或更高版本

## 安装

### 从源代码编译

1. 克隆项目：

```bash
git clone <repository-url>
cd mac-vision-ocr-js
```

2. 编译项目：

```bash
swift build -c release
```

3. 复制可执行文件到系统路径（可选）：

```bash
cp .build/release/MacVisionOCR /usr/local/bin/mac-vision-ocr
```

## 使用方法

### 基本用法

识别单个图片中的文本：

```bash
swift run MacVisionOCR image.jpg
```

或者如果已安装到系统路径：

```bash
mac-vision-ocr image.jpg
```

### 高级用法

#### 详细模式

显示置信度和其他详细信息：

```bash
swift run MacVisionOCR --verbose image.jpg
```

#### JSON 输出

以 JSON 格式输出结果：

```bash
swift run MacVisionOCR --format json image.jpg
```

#### 批量处理

同时处理多个图片：

```bash
swift run MacVisionOCR --batch image1.jpg image2.png image3.jpeg
```

#### 保存到文件

将结果保存到文件：

```bash
swift run MacVisionOCR --output result.txt image.jpg
```

#### 组合选项

```bash
swift run MacVisionOCR --verbose --format json --output result.json --batch *.jpg
```

### 命令行选项

| 选项        | 短选项 | 描述                  |
| ----------- | ------ | --------------------- |
| `--format`  | `-f`   | 输出格式 (text\|json) |
| `--output`  | `-o`   | 输出文件路径          |
| `--verbose` | `-v`   | 显示详细信息          |
| `--batch`   | `-b`   | 批量处理模式          |
| `--help`    | `-h`   | 显示帮助信息          |
| `--version` |        | 显示版本信息          |

## 支持的图片格式

- JPEG (.jpg, .jpeg)
- PNG (.png)
- TIFF (.tiff, .tif)
- BMP (.bmp)
- GIF (.gif)
- HEIF (.heic, .heif)

## 输出示例

### 文本格式输出

```
这是一段示例文本
识别的置信度很高

--- 详细信息 ---
置信度: 95.67%
识别到的文本块数量: 2

文本块 1:
  内容: "这是一段示例文本"
  置信度: 96.12%

文本块 2:
  内容: "识别的置信度很高"
  置信度: 95.23%
```

### JSON 格式输出

```json
[
  {
    "file": "image.jpg",
    "text": "这是一段示例文本\n识别的置信度很高",
    "confidence": 0.9567,
    "textBlocks": [
      {
        "text": "这是一段示例文本",
        "confidence": 0.9612
      },
      {
        "text": "识别的置信度很高",
        "confidence": 0.9523
      }
    ],
    "boundingBoxes": [
      {
        "x": 0.1234,
        "y": 0.5678,
        "width": 0.789,
        "height": 0.0987
      }
    ]
  }
]
```

## API 使用

除了命令行工具，你也可以将 `MacVisionOCRCore` 作为库在你的 Swift 项目中使用：

```swift
import MacVisionOCRCore

let engine = VisionOCREngine()

// 识别单个图片
do {
    let result = try await engine.recognizeText(from: "image.jpg")
    print("识别结果: \(result.text)")
    print("置信度: \(result.confidence)")
} catch {
    print("识别失败: \(error)")
}

// 批量处理
do {
    let results = try await engine.recognizeTextBatch(from: ["image1.jpg", "image2.jpg"])
    for result in results {
        print(result.text)
    }
} catch {
    print("批量处理失败: \(error)")
}
```

## 错误处理

工具会处理以下常见错误：

- **图片加载失败**：文件不存在或格式不支持
- **OCR 处理失败**：Vision 框架处理错误
- **未找到文本**：图片中没有可识别的文本
- **不支持的图片格式**：图片格式不被支持

## 开发

### 运行测试

```bash
swift test
```

### 开发模式运行

```bash
swift run MacVisionOCR --help
```

### 清理构建

```bash
swift package clean
```

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

本项目采用 MIT 许可证。详情请查看 [LICENSE](LICENSE) 文件。

## 更新日志

### v1.0.0

- 初始版本
- 支持基本的 OCR 功能
- 命令行界面
- 批量处理
- JSON 输出
- 详细模式

## 技术细节

### 架构

项目采用模块化设计：

- **MacVisionOCRCore**：核心 OCR 引擎库
- **MacVisionOCR**：命令行接口
- **Tests**：单元测试

### Vision 框架特性

- 使用 `VNRecognizeTextRequest` 进行文本识别
- 支持准确模式 (`recognitionLevel = .accurate`)
- 启用语言校正 (`usesLanguageCorrection = true`)
- 支持多语言识别

### 性能优化

- 异步处理，支持并发
- 批量处理优化
- 内存效率优化

## 常见问题

**Q: 为什么某些图片识别效果不好？**
A: 确保图片清晰、文字对比度高。建议使用高分辨率图片，避免模糊或倾斜的文本。

**Q: 支持哪些语言？**
A: 目前支持简体中文、繁体中文和英文。可以通过修改代码添加更多语言支持。

**Q: 可以在其他 macOS 版本上运行吗？**
A: 需要 macOS 12.0 或更高版本，因为使用了 Vision 框架的新特性。

**Q: 如何提高识别准确度？**
A: 使用高质量图片、确保文字清晰、适当的对比度，并使用 `--verbose` 模式查看置信度信息。
