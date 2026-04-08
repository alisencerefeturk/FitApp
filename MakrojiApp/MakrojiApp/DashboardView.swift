//
//  DashboardView.swift
//  MakrojiApp
//

import SwiftUI
import Combine

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:(a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red:     Double(r) / 255,
            green:   Double(g) / 255,
            blue:    Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - MacroRingView
/// Tek bir makro için dairesel ilerleme halkası.
struct MacroRingView: View {
    let label:    String
    let consumed: Double   // tüketilen miktar
    let target:   Double   // hedef (consumed + remaining)
    let unit:     String
    let color:    Color

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(consumed / target, 1.0)
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Arka plan halkası
                Circle()
                    .stroke(color.opacity(0.18), lineWidth: 10)

                // İlerleme halkası
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.9), value: progress)

                // Merkez değer
                VStack(spacing: 1) {
                    Text("\(Int(consumed))")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text(unit)
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.55))
                }
            }
            .frame(width: 78, height: 78)

            Text(label)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

// MARK: - DashboardViewModel
@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var summary:      UserSummary?
    @Published var isLoading =   false
    @Published var errorMessage: String?

    // Şimdilik sabit; ileride login ekranından alınacak
    private let userID = 1

    func loadSummary() async {
        isLoading    = true
        errorMessage = nil
        do {
            summary = try await NetworkManager.shared.fetchUserSummary(userID: userID)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - DashboardView
struct DashboardView: View {
    @StateObject private var vm = DashboardViewModel()
    @State private var showCamera = false

    var body: some View {
        ZStack {
            // Koyu arka plan
            LinearGradient(
                colors: [Color(hex: "#0F0C29"), Color(hex: "#302B63"), Color(hex: "#24243E")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {

                    // MARK: Başlık
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Makroji")
                                .font(.system(size: 32, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                            Text("Günlük Özet")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.55))
                        }
                        Spacer()

                        // Kamera butonu
                        Button { showCamera = true } label: {
                            Image(systemName: "camera.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: "#F093FB"), Color(hex: "#F5576C")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Circle())
                                .shadow(color: Color(hex: "#F5576C").opacity(0.45), radius: 8)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // MARK: İçerik Durumu
                    if vm.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.4)
                            .padding(.top, 60)

                    } else if let err = vm.errorMessage {
                        VStack(spacing: 14) {
                            Image(systemName: "wifi.exclamationmark")
                                .font(.system(size: 44))
                                .foregroundColor(.red.opacity(0.75))
                            Text(err)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white.opacity(0.65))
                                .padding(.horizontal)
                            Button("Tekrar Dene") {
                                Task { await vm.loadSummary() }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color(hex: "#F5576C"))
                        }
                        .padding(.top, 40)

                    } else if let s = vm.summary {

                        // MARK: 4 Dairesel Halka (2x2 grid)
                        let calTarget  = s.consumedCalories + s.remainingCalories
                        let protTarget = s.consumedProtein  + s.remainingProtein
                        let carbTarget = s.consumedCarbs    + s.remainingCarbs
                        let fatTarget  = s.consumedFat      + s.remainingFat

                        VStack(spacing: 20) {
                            HStack(spacing: 28) {
                                MacroRingView(
                                    label: "Kalori",
                                    consumed: s.consumedCalories,
                                    target: calTarget,
                                    unit: "kcal",
                                    color: Color(hex: "#FDDB92")
                                )
                                MacroRingView(
                                    label: "Protein",
                                    consumed: s.consumedProtein,
                                    target: protTarget,
                                    unit: "g",
                                    color: Color(hex: "#4FACFE")
                                )
                            }
                            HStack(spacing: 28) {
                                MacroRingView(
                                    label: "Karbonhidrat",
                                    consumed: s.consumedCarbs,
                                    target: carbTarget,
                                    unit: "g",
                                    color: Color(hex: "#43E97B")
                                )
                                MacroRingView(
                                    label: "Yağ",
                                    consumed: s.consumedFat,
                                    target: fatTarget,
                                    unit: "g",
                                    color: Color(hex: "#FA709A")
                                )
                            }
                        }
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding(.horizontal)

                        // MARK: Kalan Değerler Kartı
                        RemainingCard(summary: s)
                            .padding(.horizontal)
                    }

                    Spacer(minLength: 32)
                }
                .padding(.vertical)
            }
        }
        .task { await vm.loadSummary() }
        .sheet(isPresented: $showCamera) { ImagePickerView() }
    }
}

// MARK: - RemainingCard
struct RemainingCard: View {
    let summary: UserSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Kalan Hedefler")
                .font(.headline)
                .foregroundColor(.white)
            Divider().background(Color.white.opacity(0.2))

            row("Kalori",       value: summary.remainingCalories, icon: "flame.fill",   color: Color(hex: "#FDDB92"), unit: "kcal")
            row("Protein",      value: summary.remainingProtein,  icon: "p.circle.fill",color: Color(hex: "#4FACFE"), unit: "g")
            row("Karbonhidrat", value: summary.remainingCarbs,    icon: "bolt.fill",    color: Color(hex: "#43E97B"), unit: "g")
            row("Yağ",          value: summary.remainingFat,      icon: "drop.fill",    color: Color(hex: "#FA709A"), unit: "g")
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func row(_ name: String, value: Double, icon: String, color: Color, unit: String) -> some View {
        HStack {
            Image(systemName: icon).foregroundColor(color).frame(width: 22)
            Text(name).foregroundColor(.white.opacity(0.85))
            Spacer()
            Text(String(format: "%.0f \(unit)", value))
                .font(.footnote).foregroundColor(.white.opacity(0.6))
        }
    }
}

// MARK: - Preview
#Preview {
    DashboardView()
}

