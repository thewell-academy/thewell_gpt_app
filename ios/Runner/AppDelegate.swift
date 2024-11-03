import Flutter
import UIKit
import TOCropViewController

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate {

    private var flutterResult: FlutterResult?
    private var imageToCrop: UIImage?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let imageEditorChannel = FlutterMethodChannel(name: "com.example.thewellFrontend/image_editor",
                                                      binaryMessenger: controller.binaryMessenger)

        imageEditorChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let self = self else { return }
            if call.method == "takeAndEditPhoto" {
                self.takeAndEditPhoto(result: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func takeAndEditPhoto(result: @escaping FlutterResult) {
        flutterResult = result

        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false // Disable built-in editing to prevent "Use Photo" prompt
        imagePicker.delegate = self

        self.window?.rootViewController?.present(imagePicker, animated: true, completion: nil)
    }

    // UIImagePickerControllerDelegate method - After capturing image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }

            if let capturedImage = info[.originalImage] as? UIImage {
                // Store the captured image and open TOCropViewController for cropping
                self.imageToCrop = capturedImage
                let cropViewController = TOCropViewController(image: capturedImage)
                cropViewController.delegate = self
                cropViewController.aspectRatioLockEnabled = false // Allow freeform cropping
                cropViewController.resetAspectRatioEnabled = false // Start in freeform mode
                cropViewController.doneButtonTitle = "Use Photo" // Customize confirmation button title
                self.window?.rootViewController?.present(cropViewController, animated: true, completion: nil)
            } else {
                self.flutterResult?(FlutterError(code: "IMAGE_CAPTURE_FAILED", message: "No image captured", details: nil))
                self.flutterResult = nil
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        flutterResult?(FlutterError(code: "IMAGE_PICKER_CANCELLED", message: "User cancelled image selection", details: nil))
        flutterResult = nil
    }

    // TOCropViewControllerDelegate method - After cropping image
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo croppedImage: UIImage, with cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true, completion: nil)

        // Save the cropped image to a temporary file and return the path
        if let imageData = croppedImage.jpegData(compressionQuality: 0.8) {
            let imagePath = NSTemporaryDirectory() + UUID().uuidString + ".jpg"
            let url = URL(fileURLWithPath: imagePath)
            do {
                try imageData.write(to: url)
                flutterResult?(imagePath)
            } catch {
                flutterResult?(FlutterError(code: "IMAGE_SAVE_FAILED", message: "Failed to save cropped image", details: nil))
            }
        } else {
            flutterResult?(FlutterError(code: "IMAGE_ENCODING_FAILED", message: "Failed to encode cropped image", details: nil))
        }

        flutterResult = nil
        imageToCrop = nil
    }

    func cropViewControllerDidCancel(_ cropViewController: TOCropViewController) {
        cropViewController.dismiss(animated: true, completion: nil)
        flutterResult?(FlutterError(code: "CROP_CANCELLED", message: "User cancelled cropping", details: nil))
        flutterResult = nil
        imageToCrop = nil
    }
}
