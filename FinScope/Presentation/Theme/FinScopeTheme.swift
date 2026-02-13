import SwiftUI

// MARK: - Theme Constants

enum FinScopeTheme {
    // Gradients
    static let primaryGradient = LinearGradient(
        colors: [Color(red: 0.45, green: 0.31, blue: 0.95), Color(red: 0.35, green: 0.47, blue: 0.95)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let positiveGradient = LinearGradient(
        colors: [Color(red: 0.18, green: 0.75, blue: 0.47), Color(red: 0.15, green: 0.65, blue: 0.55)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let negativeGradient = LinearGradient(
        colors: [Color(red: 0.90, green: 0.30, blue: 0.30), Color(red: 0.85, green: 0.20, blue: 0.35)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let amberGradient = LinearGradient(
        colors: [Color.orange, Color(red: 0.95, green: 0.65, blue: 0.15)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Spacing
    static let cardCornerRadius: CGFloat = 16
    static let cardPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 20
    static let iconSize: CGFloat = 40
}

// MARK: - Card Style Modifier

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(FinScopeTheme.cardPadding)
            .background(.background, in: RoundedRectangle(cornerRadius: FinScopeTheme.cardCornerRadius))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}

// MARK: - Pill Segment Control

struct PillSegmentControl<T: Hashable>: View {
    let options: [T]
    @Binding var selected: T
    let label: (T) -> String

    @Namespace private var animation

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { option in
                let isSelected = selected == option
                Text(label(option))
                    .font(.subheadline.weight(.semibold))
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background {
                        if isSelected {
                            Capsule()
                                .fill(Color.accentColor)
                                .matchedGeometryEffect(id: "pill", in: animation)
                        }
                    }
                    .foregroundStyle(isSelected ? .white : .secondary)
                    .contentShape(Capsule())
                    .onTapGesture {
                        withAnimation(.snappy(duration: 0.25)) {
                            selected = option
                        }
                    }
            }
        }
        .padding(4)
        .background(Color(UIColor.systemGray6), in: Capsule())
    }
}

// MARK: - Circular Icon

struct CircularIcon: View {
    let systemName: String
    let color: Color
    var size: CGFloat = FinScopeTheme.iconSize

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size * 0.4, weight: .semibold))
            .foregroundStyle(color)
            .frame(width: size, height: size)
            .background(color.opacity(0.12))
            .clipShape(Circle())
    }
}

// MARK: - Change Indicator

struct ChangeIndicator: View {
    let value: Decimal
    let formatted: String
    var font: Font = .subheadline.monospacedDigit()
    var showBackground: Bool = false

    private var isPositive: Bool { value >= 0 }
    private var color: Color { isPositive ? .green : .red }
    private var icon: String { isPositive ? "arrow.up.right" : "arrow.down.right" }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(formatted)
        }
        .font(font)
        .foregroundStyle(color)
        .padding(.horizontal, showBackground ? 10 : 0)
        .padding(.vertical, showBackground ? 4 : 0)
        .background {
            if showBackground {
                Capsule().fill(color.opacity(0.12))
            }
        }
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    var action: (() -> Void)? = nil
    var actionLabel: String = "See All"

    var body: some View {
        HStack {
            Text(title)
                .font(.title3.bold())
            Spacer()
            if let action {
                Button(action: action) {
                    Text(actionLabel)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
    }
}

// MARK: - Gradient Progress Bar

struct GradientProgressBar: View {
    let fraction: Double
    var height: CGFloat = 8

    private var barGradient: LinearGradient {
        switch fraction {
        case ..<0.75:
            return LinearGradient(colors: [.green, .green.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
        case ..<1.0:
            return LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)
        default:
            return LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color(UIColor.systemGray5))

                RoundedRectangle(cornerRadius: height / 2)
                    .fill(barGradient)
                    .frame(width: max(0, min(geometry.size.width * min(fraction, 1.0), geometry.size.width)))
            }
        }
        .frame(height: height)
    }
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        default:
            r = 0; g = 0; b = 0
        }
        self.init(red: r, green: g, blue: b)
    }
}
