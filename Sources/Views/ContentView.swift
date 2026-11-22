import PhotosUI
import SwiftUI

/// 上部に壁と作品、下部に操作、最下部に広告。
@MainActor
struct ContentView: View {
    @EnvironmentObject private var pro: ProStore
    @StateObject private var studio = StudioModel()

    @State private var tab: StudioTab = .wall
    @State private var pinchBase: Double = 1
    @State private var isPinching = false

    var body: some View {
        VStack(spacing: 0) {
            previewArea
            ControlPanel(studio: studio, tab: $tab)
            adArea
        }
        .background(Theme.paper)
        .onChange(of: studio.artworkItem) { _, _ in studio.loadArtworkItem() }
        .onChange(of: studio.wallItem) { _, _ in studio.loadWallItem() }
        .onChange(of: studio.insets) { _, _ in studio.refreshCrop() }
        .sheet(isPresented: $studio.isCameraPresented) {
            CameraPicker { image in
                studio.adoptCameraImage(image)
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - プレビュー

    private var previewArea: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let layout = PreviewGeometry.layout(canvas: studio.canvas,
                                                mat: studio.mat,
                                                frame: studio.frame,
                                                zoom: studio.zoom,
                                                previewSize: size)
            ZStack {
                WallSurface(style: studio.wall, photo: studio.wallPhoto)

                if let artwork = studio.croppedArtwork {
                    FramedArtwork(image: artwork,
                                  layout: layout,
                                  style: studio.frame,
                                  tilt: studio.tilt,
                                  sideColor: studio.sideColor)
                        .position(x: size.width / 2, y: size.height / 2)
                } else {
                    emptyState(layout: layout)
                }
            }
            .frame(width: size.width, height: size.height)
            .clipped()
            .contentShape(Rectangle())
            .gesture(
                MagnifyGesture()
                    .onChanged { value in
                        if !isPinching {
                            isPinching = true
                            pinchBase = studio.zoom
                        }
                        studio.zoom = PreviewGeometry.clampedZoom(pinchBase * Double(value.magnification))
                    }
                    .onEnded { _ in
                        isPinching = false
                        pinchBase = studio.zoom
                    }
            )
            .onAppear { pinchBase = studio.zoom }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func emptyState(layout: FrameLayout) -> some View {
        let dark = studio.wall.isDark
        let lineColor = dark ? Color.white.opacity(0.32) : Theme.ink.opacity(0.22)
        let textColor = dark ? Color.white.opacity(0.72) : Theme.charcoal
        return VStack(spacing: 20) {
            PhotosPicker(selection: $studio.artworkItem, matching: .images) {
                VStack(spacing: 14) {
                    Rectangle()
                        .strokeBorder(lineColor, lineWidth: 1)
                        .frame(width: max(160, layout.outerSize.width),
                               height: max(120, layout.outerSize.height))
                    Text("作品を置く")
                        .font(Theme.mono(10.5))
                        .foregroundStyle(textColor)
                }
            }

            if studio.cameraAvailable {
                Button {
                    studio.isCameraPresented = true
                } label: {
                    Text("カメラで撮る")
                        .font(Theme.mono(10.5))
                        .foregroundStyle(textColor)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - 広告

    @ViewBuilder private var adArea: some View {
        if pro.isPro {
            EmptyView()
        } else {
            VStack(spacing: 0) {
                Hairline()
                BannerAdView()
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(Theme.paper)
            }
        }
    }
}
