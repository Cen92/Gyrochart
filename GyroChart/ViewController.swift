//
//  ViewController.swift
//  GyroChart
//
//  Created by Cen Breathnach on 18/03/2017.
//  Copyright © 2017 Cen Breathnach. All rights reserved.
//

import UIKit
import CoreMotion
import MessageUI

class ViewController: UIViewController {

	var motionManager: CMMotionManager?
	
	@IBOutlet weak var xGraphArea: UIView!
	@IBOutlet weak var yGraphArea: UIView!
	@IBOutlet weak var zGraphArea: UIView!
	
	@IBOutlet weak var xLabel: UILabel!
	@IBOutlet weak var yLabel: UILabel!
	@IBOutlet weak var zLabel: UILabel!
	
	@IBOutlet weak var hzSlider: UISlider!
	@IBOutlet weak var hzLabel: UILabel!
	
	@IBOutlet weak var startStopSwitch: UISwitch!
	
	var updateRate: Float = 30
	
	var xValues = [String]()
	var yValues = [String]()
	var zValues = [String]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupGyro()
		self.hzLabel.text = "\(self.updateRate) Hz"
		// Do any additional setup after loading the view, typically from a nib.
	}
	
	func setupGyro() {
		self.motionManager = CMMotionManager()
		guard let motionManager = motionManager else {
			self.showError()
			return
		}
	}
	@IBAction func sliderValueChanged(_ sender: Any) {
		self.updateRate = ceil(self.hzSlider.value)
		self.hzLabel.text = "\(self.updateRate) Hz"
	}
	
	@IBAction func switchToggled(_ sender: Any) {
		if self.startStopSwitch.isOn {
			self.startRecording()
		}else {
		
			self.stopRecording()
			self.createCSVFromData()
			self.sendEmail()
		}
	}
	
	func startRecording() {
		self.hzSlider.isEnabled = false
		self.hzSlider.alpha = 0.5
		
		if let motionManager = self.motionManager {
			if motionManager.isGyroAvailable {
				motionManager.gyroUpdateInterval = Double(1.0/self.updateRate)
				motionManager.startGyroUpdates(to: OperationQueue.main, withHandler: { (gyroData, error) in
					if let gyroData = gyroData {
						let x = String(format: "%.02f", gyroData.rotationRate.x)
						self.xValues.append(x)
						self.xLabel.text = x
						let y = String(format: "%.02f", gyroData.rotationRate.y)
						self.yValues.append(y)
						self.yLabel.text = y
						let z = String(format: "%.02f", gyroData.rotationRate.z)
						self.zValues.append(z)
						self.zLabel.text = z
					}else {
						print(error)
					}
				})
			}else {
				showError()
			}
		} else {
			self.showError()
		}
	}
	
	func stopRecording() {
		self.hzSlider.isEnabled = false
		self.hzSlider.alpha = 0.5
		
		if let motionManager = self.motionManager {
			motionManager.stopGyroUpdates()
		}
	}
	
	func sendEmail() {
		let mailComposeViewController = configuredMailComposeViewController()
		if MFMailComposeViewController.canSendMail() {
			self.present(mailComposeViewController, animated: true, completion: nil)
		} else {
			self.showSendMailErrorAlert()
		}
	}
	
	func createCSVFromData() {
		var csvString = String()
		csvString.append("X;Y;Z\n\n\n")
		for i in 0...xValues.count {
			guard let xValue = xValues[safe:i] else {
				continue
			}
			guard let yValue = yValues[safe:i] else {
				continue
			}
			
			guard let zValue = zValues[safe:i] else {
				continue
			}
			
			csvString.append("\(xValue);\(yValue);\(zValue)\n")
		}
		self.saveCSV(csvString: csvString)
	}
	
	func saveCSV(csvString:String) {
		if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
			let path = dir.appendingPathComponent("data.csv")
			do {
				try csvString.write(to: path, atomically: false, encoding: String.Encoding.utf8)
			}
			catch {
				print(error)
			}
		}
	}
	
	func pathForCSV() -> URL? {
		if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
			return dir.appendingPathComponent("data.csv")
		}
		return nil
	}
	
	func configuredMailComposeViewController() -> MFMailComposeViewController {
		let mailComposerVC = MFMailComposeViewController()
		mailComposerVC.mailComposeDelegate = self
		mailComposerVC.setToRecipients(["someone@somewhere.com"])
		mailComposerVC.setSubject("Sending you an in-app e-mail...")
		mailComposerVC.setMessageBody("Sending e-mail in-app is not so bad!", isHTML: false)
		if let path = self.pathForCSV() {
			do {
				let data = try Data(contentsOf: path)
				mailComposerVC.addAttachmentData(data, mimeType: "text/csv", fileName: "data.csv")
			}catch {
				print(error)
			}
		}
		return mailComposerVC
	}
	
	func showError() {
		UIAlertView(title: "Error", message: "Gyroscope not available", delegate: nil, cancelButtonTitle: "OK").show()
	}
	
	func showSendMailErrorAlert() {
		let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
		sendMailErrorAlert.show()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}

extension ViewController : MFMailComposeViewControllerDelegate {
 // MARK: MFMailComposeViewControllerDelegate Method
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true, completion: nil)
	}
}



