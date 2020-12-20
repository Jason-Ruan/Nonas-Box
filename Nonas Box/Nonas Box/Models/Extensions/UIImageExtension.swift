

import UIKit

public extension UIImage {
    
    // Third-party code
    convenience init(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        color.set()
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        self.init(data: image.pngData()!)!
    }
    
}
