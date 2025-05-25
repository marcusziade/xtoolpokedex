import SwiftUI

@MainActor
class ImageCache: ObservableObject {
    static let shared = ImageCache()
    private var cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    func image(for url: String) -> UIImage? {
        return cache.object(forKey: NSString(string: url))
    }
    
    func setImage(_ image: UIImage, for url: String) {
        cache.setObject(image, forKey: NSString(string: url))
    }
}

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let url: URL?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder
    
    @StateObject private var imageCache = ImageCache.shared
    @State private var loadedImage: UIImage?
    @State private var isLoading = false
    @State private var hasError = false
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let loadedImage = loadedImage {
                content(Image(uiImage: loadedImage))
            } else if hasError {
                Image(systemName: "photo.circle.fill")
                    .foregroundColor(.gray.opacity(0.5))
                    .font(.system(size: 40))
            } else {
                placeholder()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }
    
    private func loadImage() {
        guard let url = url, loadedImage == nil, !isLoading, !hasError else { return }
        
        let urlString = url.absoluteString
        
        if let cachedImage = imageCache.image(for: urlString) {
            loadedImage = cachedImage
            return
        }
        
        isLoading = true
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        imageCache.setImage(image, for: urlString)
                        loadedImage = image
                        isLoading = false
                    }
                } else {
                    await MainActor.run {
                        hasError = true
                        isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    hasError = true
                    isLoading = false
                }
            }
        }
    }
}