
# MetalEAGLLayer

[![iOS](https://img.shields.io/badge/iOS-16.0+-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A drop-in replacement for deprecated `CAEAGLLayer` that uses Metal rendering under the hood. Perfect for maintaining compatibility with legacy frameworks while leveraging modern, stable graphics APIs.

## 🚀 Features

- **🔄 Drop-in Replacement**: Works with existing frameworks that expect `CAEAGLLayer`
- **⚡ Metal-Powered**: Uses `CAMetalLayer` internally for superior performance and stability
- **🎯 Format Translation**: Automatic conversion between EAGL and Metal pixel formats
- **📱 iOS Compatibility**: Supports iOS 16.0+ with backward compatibility handling
- **🔧 Zero Configuration**: Works out of the box with sensible defaults
- **🐛 Crash Prevention**: Eliminates common `CAEAGLLayer` crashes and context issues

## 📋 Requirements

- iOS 15.0+
- Xcode 16.0+
- Swift 5.0+

## 📦 Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/yourname/MetalEAGLLayer.git", from: "1.0.0")
]
```

Or add it through Xcode:
1. File → Add Package Dependencies
2. Enter: `https://github.com/yourname/MetalEAGLLayer.git`
3. Select version and add to target

### Manual Installation

1. Download `MetalEAGLLayer.swift`
2. Add it to your Xcode project
3. Import the required frameworks:
   ```swift
   import QuartzCore
   import Metal
   import UIKit
   ```

## 🛠 Usage

### Basic Setup

Replace your `CAEAGLLayer` initialization with `MetalEAGLLayer`:

```swift
import MetalEAGLLayer

class MyView: UIView {
    private let metalEAGLLayer = MetalEAGLLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayer()
    }
    
    private func setupLayer() {
        // Configure the layer
        metalEAGLLayer.device = MTLCreateSystemDefaultDevice()
        metalEAGLLayer.pixelFormat = .bgra8Unorm
        metalEAGLLayer.framebufferOnly = true
        
        // Add to view
        view.layer.addSublayer(metalEAGLLayer)
    }
}
```

### With Third-Party Frameworks

Use with frameworks that expect `CAEAGLLayer`:

```swift
// Example with a hypothetical AR framework
private func setupARView() -> UIView? {
    guard let viewSize = self.viewSize else { return nil }
    
    let frame = CGRect(origin: .zero, size: viewSize)
    let view = UIView(frame: frame)
    
    // Create MetalEAGLLayer instead of CAEAGLLayer
    let metalEAGLLayer = MetalEAGLLayer()
    metalEAGLLayer.device = MTLCreateSystemDefaultDevice()
    
    // Framework accepts our adapter as CAEAGLLayer
    arFramework?.initialize(
        withWidth: Int(viewSize.width),
        height: Int(viewSize.height),
        window: metalEAGLLayer  // ← Framework thinks this is CAEAGLLayer
    )
    
    view.layer.addSublayer(metalEAGLLayer)
    return view
}
```

### Custom Configuration

```swift
let layer = MetalEAGLLayer()

// Set Metal device
layer.device = MTLCreateSystemDefaultDevice()

// Configure pixel format
layer.pixelFormat = .bgra8Unorm  // or .bgra8Unorm_srgb for sRGB

// Set drawable properties (EAGL-style)
layer.setDrawableProperties([
    kEAGLDrawablePropertyRetainedBacking: false,
    kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
])

// Enable HDR (iOS 16+)
if #available(iOS 16.0, *) {
    layer.wantsExtendedDynamicRangeContent = true
}
```

## 🎯 Common Use Cases

### Migration from CAEAGLLayer

**Before:**
```swift
// Old OpenGL ES setup
class OpenGLView: UIView {
    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }
    
    private var eaglLayer: CAEAGLLayer {
        return layer as! CAEAGLLayer
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        eaglLayer.isOpaque = true
        eaglLayer.drawableProperties = [
            kEAGLDrawablePropertyRetainedBacking: false,
            kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
        ]
    }
}
```

**After:**
```swift
// New Metal-backed setup
class MetalView: UIView {
    private let metalEAGLLayer = MetalEAGLLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        metalEAGLLayer.device = MTLCreateSystemDefaultDevice()
        metalEAGLLayer.setDrawableProperties([
            kEAGLDrawablePropertyRetainedBacking: false,
            kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
        ])
        layer.addSublayer(metalEAGLLayer)
    }
}
```

### Using MetalEAGLView (Recommended)

The package includes `MetalEAGLView` - a ready-to-use UIView subclass that handles all the setup automatically:

```swift
import MetalEAGLLayer

class ViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupARView()
    }
    
    private func setupARView() {
        // Create MetalEAGLView - handles all Metal setup internally
        let metalView = MetalEAGLView(frame: containerView.bounds)
        metalView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Optional: Configure the underlying layer
        metalView.metalEAGLLayer.pixelFormat = .bgra8Unorm_srgb
        
        // Use with any framework that expects CAEAGLLayer
        someARFramework?.initialize(
            withWidth: Int(metalView.bounds.width),
            height: Int(metalView.bounds.height),
            window: metalView.metalEAGLLayer
        )
        
        containerView.addSubview(metalView)
    }
}
```

**Interface Builder Integration:**
```swift
class ViewController: UIViewController {
    @IBOutlet weak var metalView: MetalEAGLView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MetalEAGLView is ready to use immediately
        setupFramework(with: metalView.metalEAGLLayer)
    }
}
```

**Programmatic Creation:**
```swift
let metalView = MetalEAGLView()
metalView.translatesAutoresizingMaskIntoConstraints = false

view.addSubview(metalView)
NSLayoutConstraint.activate([
    metalView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
    metalView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    metalView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    metalView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
])

// Ready to use with any EAGL-expecting framework
thirdPartyFramework.setup(layer: metalView.metalEAGLLayer)
```

## 🔧 API Reference

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `device` | `MTLDevice?` | Metal device for rendering |
| `pixelFormat` | `MTLPixelFormat` | Pixel format for rendering |
| `framebufferOnly` | `Bool` | Whether layer is optimized for display only |
| `drawableSize` | `CGSize` | Size of drawable in pixels |
| `nextDrawable` | `CAMetalDrawable?` | Next available drawable for rendering |
| `colorspace` | `CGColorSpace?` | Color space for rendering |
| `presentsWithTransaction` | `Bool` | Synchronize with Core Animation transactions |

### Methods

```swift
// EAGL compatibility
func setDrawableProperties(_ properties: [AnyHashable: Any]!)
func drawableProperties() -> [AnyHashable: Any]!
```

### Supported EAGL Formats

| EAGL Format | Metal Format | Description |
|-------------|--------------|-------------|
| `kEAGLColorFormatRGBA8` | `.bgra8Unorm` | 32-bit RGBA |
| `kEAGLColorFormatRGB565` | `.b5g6r5Unorm` | 16-bit RGB |
| `kEAGLColorFormatSRGBA8` | `.bgra8Unorm_srgb` | 32-bit sRGB (iOS 10+) |

## ⚠️ Important Notes

### Memory Management
Always release the Metal device when the view is deallocated:

```swift
deinit {
    metalEAGLLayer.device = nil
}
```

### Thread Safety
- Layer configuration should be done on the main thread
- Metal command buffers can be created on background threads
- Core Animation updates must happen on the main thread

### Performance Tips
- Use `framebufferOnly = true` for display-only rendering
- Set appropriate `pixelFormat` for your use case
- Call `updateDrawableSize()` only when necessary

## 🐛 Troubleshooting

### Common Issues

**Layer not appearing:**
```swift
// Ensure Metal device is set
metalEAGLLayer.device = MTLCreateSystemDefaultDevice()

// Check that layer bounds are valid
print("Layer bounds: \(metalEAGLLayer.bounds)")
```

**Poor performance:**
```swift
// Enable framebuffer optimization
metalEAGLLayer.framebufferOnly = true

// Use appropriate pixel format
metalEAGLLayer.pixelFormat = .bgra8Unorm  // Most efficient on Apple hardware
```

**Framework compatibility issues:**
```swift
// Ensure proper property translation
metalEAGLLayer.setDrawableProperties([
    kEAGLDrawablePropertyRetainedBacking: false,
    kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
])
```

### Debug Tips

Enable Metal validation for debugging:
```swift
#if DEBUG
// In your scheme settings, add environment variable:
// METAL_VALIDATE_API = 1
#endif
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Apple's Metal and Core Animation documentation
- The iOS development community for identifying CAEAGLLayer issues
- Contributors who helped improve framework compatibility

## 📞 Support

- 📧 Email: support@yourpackage.com
- 🐛 Issues: [GitHub Issues](https://github.com/yourname/MetalEAGLLayer/issues)
- 📖 Documentation: [Wiki](https://github.com/yourname/MetalEAGLLayer/wiki)

---

**Made with ❤️ for the iOS development community**
