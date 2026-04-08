//
//  ImagePickerView.swift
//  MakrojiApp
//

import SwiftUI
import UIKit

// MARK: - ImagePickerView
/// Kamerayı açar, fotoğraf çekildikten sonra POST /images/upload'a gönderir.
struct ImagePickerView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var pickedImage:   UIImage?
    @State private var showPicker   = true
    @State private var isUploading  = false
    @State private var uploadResult: ImageUploadResponse?
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if showPicker && pickedImage == nil {
                // Kamera / galeri seçici
                CameraPickerRepresentable(image: $pickedImage, isPresented: $showPicker)
                    .ignoresSafeArea()
            } else {
                VStack(spacing: 20) {

                    // Önizleme
                    if let img = pickedImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding()
                    }

                    // Yükleniyor göstergesi
                    if isUploading {
                        ProgressView("Gönderiliyor…")
                            .foregroundColor(.white)
                    }

                    // Tespit sonuçları
                    if let result = uploadResult {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tespit Edilen Yiyecekler")
                                .font(.headline).foregroundColor(.white)

                            if result.detectedFoods.isEmpty {
                                Text("Yiyecek tespit edilemedi.")
                                    .foregroundColor(.white.opacity(0.55))
                            } else {
                                ForEach(result.detectedFoods) { food in
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text(food.name).foregroundColor(.white)
                                        Spacer()
                                        if let conf = food.confidence {
                                            Text(String(format: "%.0f%%", conf * 100))
                                                .foregroundColor(.white.opacity(0.55))
                                                .font(.footnote)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.horizontal)
                    }

                    // Hata mesajı
                    if let err = errorMessage {
                        Text(err)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Aksiyon butonları
                    HStack(spacing: 14) {
                        // Tekrar çek
                        Button {
                            pickedImage  = nil
                            uploadResult = nil
                            errorMessage = nil
                            showPicker   = true
                        } label: {
                            Label("Tekrar", systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(.bordered).tint(.white)

                        // Gönder (sonuç yoksa göster)
                        if uploadResult == nil, let img = pickedImage {
                            Button {
                                Task { await upload(img) }
                            } label: {
                                Label("Gönder", systemImage: "arrow.up.circle.fill")
                            }
                            .buttonStyle(.borderedProminent).tint(.orange)
                            .disabled(isUploading)
                        }

                        // Kapat
                        Button("Kapat") { dismiss() }
                            .buttonStyle(.bordered).tint(.white)
                    }
                    .padding(.bottom, 30)
                }
            }
        }
    }

    // MARK: - Backend'e yükleme
    private func upload(_ image: UIImage) async {
        isUploading  = true
        errorMessage = nil
        do {
            uploadResult = try await NetworkManager.shared.uploadImage(image)
        } catch {
            errorMessage = error.localizedDescription
        }
        isUploading = false
    }
}

// MARK: - UIImagePickerController → SwiftUI Köprüsü
struct CameraPickerRepresentable: UIViewControllerRepresentable {
    @Binding var image:       UIImage?
    @Binding var isPresented: Bool

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        // Simülatörde kamera yoktur, galeri kullanılır
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera)
            ? .camera
            : .photoLibrary
        picker.allowsEditing = false
        picker.delegate      = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject,
                             UIImagePickerControllerDelegate,
                             UINavigationControllerDelegate {
        let parent: CameraPickerRepresentable
        init(_ parent: CameraPickerRepresentable) { self.parent = parent }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            parent.image       = info[.originalImage] as? UIImage
            parent.isPresented = false
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Preview
#Preview {
    ImagePickerView()
}
