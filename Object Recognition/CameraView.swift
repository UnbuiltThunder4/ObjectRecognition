//
//  CameraView.swift
//  Object Recognition
//
//  Created by Eugenio Raja on 07/12/21.
//

import Foundation
import SwiftUI

extension Color {
    static let PurpleBG = Color("PurpleBG")
}

struct CameraView: View {
    
    @State private var showSheet: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    
    @State private var image: UIImage?

    @State private var firstclassification: Bool = true
    
    @State private var classificationLabel: String = ""
    @State private var classificationLabelProb: String = ""
    
    let model = try! MobileNetV2(configuration: .init())
    
    let impact = UIImpactFeedbackGenerator(style: .soft)
    
    public func performImageClassification(image: UIImage?) {
        
        guard let img = image,
            let resizedImage = img.resizeTo(size: CGSize(width: 224, height: 224)),
            let buffer = resizedImage.toCVPixelBuffer() else {
                  return
        }
        
        let output = try? model.prediction(image: buffer)
        
        if let output = output {
            self.classificationLabel = output.classLabel
            
            let sortedProbs = output.classLabelProbs.sorted  { $0.1 > $1.1 }
            
            let spacedProbs = sortedProbs.map { (key, value) in
                return "\(Float16(value * 100))"
            }.joined(separator: " ")
            
            let results = spacedProbs.components(separatedBy: " ")
            
            classificationLabelProb = "\(results[0])%"
            
            /*let results = output.classLabelProbs.sorted { $0.1 > $1.1 } all results
            
            let result = results.map { (key, value) in
                return "\(key) = \(Int(value * 100))%"
            }.joined(separator: "\n")
            
            classificationLabelProb = result */
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Image(uiImage: UIImage(named: "glassBG")!)
                    .opacity(0.1)
                    .offset(x: -60, y: -100)
                    .accessibilityHidden(true)
                VStack {
                    if (image != nil) {
                        Image(uiImage: image!)
                            .resizable()
                            .cornerRadius(10)
                            .shadow(color: .black, radius: 5, x: 5, y: 5)
                            .aspectRatio(contentMode: ContentMode.fit)
                            .frame(maxWidth: 380, maxHeight: 380)
                            .offset(y: -80)
                            .accessibilityHidden(true)
                            .onAppear {
                                self.firstclassification = false
                            }
                    }
                    else {
                        Image(uiImage: UIImage(named: "glass")!)
                            .resizable()
                            .frame(width: 330, height: 440)
                            .offset(x: 0, y: -25)
                            .accessibilityHidden(true)
                        Text("Take the photo of one single object and see if it matches the app's guess")
                            .padding()
                            .font(.system(size: 30, weight: .light))
                            .frame(width: 400, height: 140)
                            .offset(y: -40)
                            .accessibilityAddTraits(.isStaticText)
                    }
                    if (self.firstclassification) {
                        Button(action: {
                            self.showSheet = true
                            impact.impactOccurred()
                        }) {
                            Text("Get Started")
                                .font(.system(size: 18))
                                .frame(width: 300)
                        }
                        .frame(width: 300)
                        .padding()
                        .foregroundColor(Color.white)
                        .background(Color.indigo)
                        .cornerRadius(10)
                        .actionSheet(isPresented: $showSheet) {
                            ActionSheet(title: Text("Select Image"),
                                        message: Text("From one of the options"),
                                        buttons: [
                                            .default(Text("Photo Library")){
                                                self.showImagePicker = true
                                                self.sourceType = .photoLibrary
                                                impact.impactOccurred()
                                            },
                                            .default(Text("Camera")){
                                                self.showImagePicker = true
                                                self.sourceType = .camera
                                                impact.impactOccurred()
                                            },
                                            .cancel(){
                                                impact.impactOccurred()
                                            }
                            ])
                        }
                    }
                    else {
                        ZStack {
                        Card(label: classificationLabel, certainty: classificationLabelProb)
                            .cornerRadius(10)
                            .frame(width: UIScreen.main.bounds.width - 32)
                            .padding()
                            .offset(y: -50)
                        
                        Button(action: {
                            self.showSheet = true
                            impact.impactOccurred()
                        }) {
                            Text("Try Again")
                                .font(.system(size: 18))
                                .frame(width: 300)
                        }
                        .frame(width: 300)
                        .padding()
                        .foregroundColor(Color.white)
                        .background(Color.indigo)
                        .cornerRadius(10)
                        .offset(y: 130)
                        .actionSheet(isPresented: $showSheet) {
                            ActionSheet(title: Text("Select Image"),
                                        message: Text("From one of the options"),
                                        buttons: [
                                            .default(Text("Photo Library")){
                                                self.showImagePicker = true
                                                self.sourceType = .photoLibrary
                                                impact.impactOccurred()
                                            },
                                            .default(Text("Camera")){
                                                self.showImagePicker = true
                                                self.sourceType = .camera
                                                impact.impactOccurred()
                                            },
                                            .cancel(){
                                                impact.impactOccurred()
                                            }
                            ])
                        }
                    }
                    }
                }
            }
            .background(Color.PurpleBG)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: self.$image, isShown: self.$showImagePicker, sourceType: self.sourceType)
                .ignoresSafeArea(.all, edges: .bottom)
                .onDisappear {
                    self.performImageClassification(image: self.image)
                }
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
