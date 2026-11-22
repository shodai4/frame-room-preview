import PhotosUI
import SwiftUI

enum StudioTab: String, CaseIterable, Identifiable {
    case wall, frame, size, finish, save

    var id: String { rawValue }

    var name: String {
        switch self {
        case .wall: return "壁"
        case .frame: return "額"
        case .size: return "寸法"
        case .finish: return "仕上"
        case .save: return "保存"
        }
    }
}

/// 下部の操作パネル。文字だけの区切りと、細い罫線。
struct ControlPanel: View {
    @ObservedObject var studio: StudioModel
    @Binding var tab: StudioTab

    @EnvironmentObject private var pro: ProStore

    var body: some View {
        VStack(spacing: 0) {
            captionRow
            Hairline()
            tabRow
            panel
                .frame(height: 168, alignment: .top)
                .frame(maxWidth: .infinity)
        }
        .background(Theme.paper)
    }

    // MARK: - キャプション

    private var captionRow: some View {
        let hasArtwork = studio.hasArtwork
        return HStack(alignment: .center, spacing: 14) {
            Text(studio.canvas.caption)
                .font(Theme.mono(10.5))
                .foregroundStyle(Theme.charcoal)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Spacer(minLength: 8)

            PhotosPicker(selection: $studio.artworkItem, matching: .images) {
                Text(hasArtwork ? "作品を替える" : "作品を選ぶ")
                    .font(Theme.label(11))
                    .foregroundStyle(Theme.ink)
            }

            if studio.cameraAvailable {
                Button {
                    studio.isCameraPresented = true
                } label: {
                    Text("撮影")
                        .font(Theme.label(11))
                        .foregroundStyle(Theme.ink)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }

    // MARK: - 区切り

    private var tabRow: some View {
        HStack(spacing: 22) {
            ForEach(StudioTab.allCases) { item in
                Button {
                    tab = item
                } label: {
                    VStack(spacing: 5) {
                        Text(item.name)
                            .font(Theme.label(12, weight: tab == item ? .medium : .regular))
                            .foregroundStyle(tab == item ? Theme.ink : Theme.charcoal.opacity(0.7))
                        Rectangle()
                            .fill(tab == item ? Theme.ink : Color.clear)
                            .frame(height: 1)
                    }
                }
                .buttonStyle(.plain)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 6)
    }

    @ViewBuilder private var panel: some View {
        switch tab {
        case .wall: wallPanel
        case .frame: framePanel
        case .size: sizePanel
        case .finish: finishPanel
        case .save: savePanel
        }
    }

    // MARK: - 壁

    private var wallPanel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(WallStyle.allCases) { item in
                    VStack(spacing: 7) {
                        if item == .roomPhoto {
                            PhotosPicker(selection: $studio.wallItem, matching: .images) {
                                wallSwatch(item)
                            }
                        } else {
                            wallSwatch(item)
                                .onTapGesture { studio.wall = item }
                        }
                        Text(item.name)
                            .font(Theme.label(10))
                            .foregroundStyle(studio.wall == item ? Theme.ink : Theme.charcoal)
                    }
                    .frame(width: 60)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
    }

    private func wallSwatch(_ item: WallStyle) -> some View {
        ZStack {
            if item == .roomPhoto, let photo = studio.wallPhoto {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
            } else {
                WallSurface(style: item, photo: nil)
            }
        }
        .frame(width: 56, height: 46)
        .clipped()
        .overlay(Rectangle().strokeBorder(studio.wall == item ? Theme.ink : Theme.hairline,
                                          lineWidth: studio.wall == item ? 1.2 : 0.8))
    }

    // MARK: - 額

    private var framePanel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(FrameStyle.allCases) { item in
                    VStack(spacing: 7) {
                        ZStack {
                            FrameBorder(style: item, frameWidth: 8, unit: 0.3, sideColor: Theme.charcoal)
                            Rectangle()
                                .fill(Theme.matPaper)
                                .padding(8)
                        }
                        .frame(width: 56, height: 46)
                        .overlay(Rectangle().strokeBorder(studio.frame == item ? Theme.ink : Theme.hairline,
                                                          lineWidth: studio.frame == item ? 1.2 : 0.8))
                        .onTapGesture { studio.frame = item }

                        Text(item.name)
                            .font(Theme.label(10))
                            .foregroundStyle(studio.frame == item ? Theme.ink : Theme.charcoal)
                    }
                    .frame(width: 66)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
    }

    // MARK: - 寸法

    private var sizePanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(CanvasSize.allCases) { size in
                        VStack(spacing: 6) {
                            Text(size.name)
                                .font(Theme.mono(12, weight: studio.canvas == size ? .medium : .regular))
                                .foregroundStyle(studio.canvas == size ? Theme.ink : Theme.charcoal)
                            Rectangle()
                                .fill(studio.canvas == size ? Theme.ink : Color.clear)
                                .frame(height: 1)
                        }
                        .onTapGesture { studio.canvas = size }
                    }
                }
                .padding(.horizontal, 20)
            }

            sliderRow(title: "拡大",
                      value: $studio.zoom,
                      range: PreviewGeometry.zoomRange,
                      readout: String(format: "×%.2f", studio.zoom))
        }
        .padding(.top, 14)
    }

    // MARK: - 仕上げ

    private var finishPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 20) {
                Text("マット")
                    .font(Theme.mono(9.5))
                    .foregroundStyle(Theme.charcoal)
                ForEach(MatWidth.allCases) { item in
                    VStack(spacing: 5) {
                        Text(item.name)
                            .font(Theme.label(11, weight: studio.mat == item ? .medium : .regular))
                            .foregroundStyle(studio.mat == item ? Theme.ink : Theme.charcoal)
                        Rectangle()
                            .fill(studio.mat == item ? Theme.ink : Color.clear)
                            .frame(height: 1)
                    }
                    .onTapGesture { studio.mat = item }
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)

            sliderRow(title: "傾き",
                      value: $studio.tilt,
                      range: PreviewGeometry.tiltRange,
                      readout: String(format: "%+.1f°", studio.tilt))

            VStack(spacing: 2) {
                HStack(spacing: 14) {
                    insetSlider("上", value: $studio.insets.top)
                    insetSlider("下", value: $studio.insets.bottom)
                }
                HStack(spacing: 14) {
                    insetSlider("左", value: $studio.insets.left)
                    insetSlider("右", value: $studio.insets.right)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 14)
    }

    private func insetSlider(_ label: String, value: Binding<Double>) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .font(Theme.mono(9))
                .foregroundStyle(Theme.charcoal)
                .frame(width: 12, alignment: .leading)
            Slider(value: Binding(get: { value.wrappedValue * 100 },
                                  set: { value.wrappedValue = $0 / 100 }),
                   in: 0...45)
                .tint(Theme.charcoal)
                .controlSize(.mini)
            Text(String(format: "%d", Int((value.wrappedValue * 100).rounded())))
                .font(Theme.mono(9))
                .foregroundStyle(Theme.charcoal)
                .frame(width: 18, alignment: .trailing)
        }
    }

    // MARK: - 保存

    private var savePanel: some View {
        VStack(spacing: 12) {
            HStack(spacing: 20) {
                Text("比率")
                    .font(Theme.mono(9.5))
                    .foregroundStyle(Theme.charcoal)
                ForEach(ExportShape.allCases) { shape in
                    VStack(spacing: 5) {
                        Text(shape.name)
                            .font(Theme.mono(11, weight: studio.exportShape == shape ? .medium : .regular))
                            .foregroundStyle(studio.exportShape == shape ? Theme.ink : Theme.charcoal)
                        Rectangle()
                            .fill(studio.exportShape == shape ? Theme.ink : Color.clear)
                            .frame(height: 1)
                    }
                    .onTapGesture { studio.exportShape = shape }
                }
                Spacer(minLength: 0)
                Text("長辺 2048")
                    .font(Theme.mono(9))
                    .foregroundStyle(Theme.charcoal.opacity(0.8))
            }
            .padding(.horizontal, 20)

            Button {
                Task { await studio.export() }
            } label: {
                HStack(spacing: 8) {
                    if studio.isExporting {
                        ProgressView()
                            .controlSize(.mini)
                    }
                    Text(studio.isExporting ? "書き出し中" : "写真に保存")
                        .font(Theme.label(12, weight: .medium))
                }
                .foregroundStyle(Theme.paper)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(studio.hasArtwork ? Theme.ink : Theme.charcoal.opacity(0.35))
            }
            .buttonStyle(.plain)
            .disabled(!studio.hasArtwork || studio.isExporting)
            .padding(.horizontal, 20)

            if let message = studio.message {
                Text(message)
                    .font(Theme.mono(9))
                    .foregroundStyle(Theme.charcoal)
            } else if let product = pro.product, !pro.isPro {
                Button {
                    Task { await pro.purchase() }
                } label: {
                    Text("広告を消す　\(product.displayPrice)")
                        .font(Theme.mono(10))
                        .foregroundStyle(Theme.charcoal)
                        .underline()
                }
                .buttonStyle(.plain)
            } else if let message = pro.message {
                Text(message)
                    .font(Theme.mono(9))
                    .foregroundStyle(Theme.charcoal)
            }

            Spacer(minLength: 0)
        }
        .padding(.top, 14)
    }

    // MARK: - 部品

    private func sliderRow(title: String,
                           value: Binding<Double>,
                           range: ClosedRange<Double>,
                           readout: String) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(Theme.mono(9.5))
                .foregroundStyle(Theme.charcoal)
                .frame(width: 30, alignment: .leading)
            Slider(value: value, in: range)
                .tint(Theme.charcoal)
            Text(readout)
                .font(Theme.mono(10))
                .foregroundStyle(Theme.charcoal)
                .frame(width: 50, alignment: .trailing)
        }
        .padding(.horizontal, 20)
    }
}
