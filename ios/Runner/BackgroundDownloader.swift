import Foundation
import Flutter

@objc class BackgroundDownloader: NSObject, URLSessionDownloadDelegate {
    private var session: URLSession!
    private var channel: FlutterMethodChannel!
    private var activeDownloads: [Int: URLSessionDownloadTask] = [:]
    private var completionHandlers: [String: () -> Void] = [:]

    init(messenger: FlutterBinaryMessenger) {
        super.init()
        self.channel = FlutterMethodChannel(name: "com.dirxplore.app/downloads", binaryMessenger: messenger)

        let config = URLSessionConfiguration.background(withIdentifier: "com.dirxplore.app.background")
        config.sessionSendsLaunchEvents = true
        config.isDiscretionary = false

        self.session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)

        channel.setMethodCallHandler { [weak self] (call, result) in
            self?.handle(call, result: result)
        }
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startDownload":
            if let args = call.arguments as? [String: Any],
               let urlString = args["url"] as? String,
               let url = URL(string: urlString) {
                let task = session.downloadTask(with: url)
                activeDownloads[task.taskIdentifier] = task
                task.resume()
                result(task.taskIdentifier)
            } else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing URL", details: nil))
            }
        case "pauseDownload":
            if let args = call.arguments as? [String: Any],
               let taskId = args["taskId"] as? Int,
               let task = activeDownloads[taskId] {
                task.cancel(byProducingResumeData: { resumeData in
                    // In a real app, save resumeData to Disk/CoreData
                    self.channel.invokeMethod("onDownloadPaused", arguments: ["taskId": taskId, "hasResumeData": resumeData != nil])
                })
                result(true)
            } else {
                result(false)
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - URLSessionDownloadDelegate

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsURL.appendingPathComponent(downloadTask.response?.suggestedFilename ?? "downloaded_file")

        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.moveItem(at: location, to: destinationURL)

            channel.invokeMethod("onDownloadComplete", arguments: [
                "taskId": downloadTask.taskIdentifier,
                "path": destinationURL.path
            ])
        } catch {
            channel.invokeMethod("onDownloadError", arguments: [
                "taskId": downloadTask.taskIdentifier,
                "error": error.localizedDescription
            ])
        }
        activeDownloads.removeValue(forKey: downloadTask.taskIdentifier)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        channel.invokeMethod("onDownloadProgress", arguments: [
            "taskId": downloadTask.taskIdentifier,
            "progress": progress,
            "bytesWritten": totalBytesWritten,
            "totalBytes": totalBytesExpectedToWrite
        ])
    }
}
