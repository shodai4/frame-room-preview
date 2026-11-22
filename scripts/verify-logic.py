#!/usr/bin/env python3
"""額と壁の計算ロジックの写しと自己点検。

Swift 側（Sources/Models/PreviewGeometry.swift, ArtworkInsets.swift）と同じ式を
Python に写し、号数の外寸・画面への割り付け・拡大の上限・書き出しの画素数・
裁ち落としの矩形が意図どおりかを確かめる。CI でも実行する。
"""

import math

VISIBLE_WALL_HEIGHT_MM = 900.0
FIT_LIMIT = 0.86
HARD_LIMIT = 0.96
ZOOM_RANGE = (0.6, 1.6)
TILT_RANGE = (-5.0, 5.0)
EXPORT_MAX_EDGE = 2048.0

# CanvasSize.swift と同じ呼び寸法（長辺, 短辺）
CANVAS = {
    "F0": (180, 140),
    "F1": (220, 160),
    "F2": (240, 190),
    "F3": (273, 220),
    "F4": (333, 242),
    "F5": (350, 250),
    "F6": (410, 318),
    "F8": (455, 380),
    "F10": (530, 455),
    "F12": (606, 500),
    "F15": (652, 530),
    "F20": (727, 606),
}

# MatWidth.swift
MAT_MM = {"なし": 0, "細": 30, "標準": 60, "広": 100}

# FrameStyle.swift（見付け幅 mm）
FRAME_MM = {"額なし": 3, "木枠": 28, "ウォルナット": 34, "金縁": 42, "アルミ黒": 10}

# ExportShape.swift（幅 ÷ 高さ）
SHAPE_RATIO = {"1:1": 1.0, "4:5": 0.8}


def clamp(value, low, high):
    return min(max(value, low), high)


def outer_size_mm(canvas, mat, frame):
    margin = 2 * (MAT_MM[mat] + FRAME_MM[frame])
    width, height = CANVAS[canvas]
    return (width + margin, height + margin)


def layout(canvas, mat, frame, zoom, preview_size):
    """Swift の PreviewGeometry.layout と同じ。返り値はすべて pt。"""
    outer_w_mm, outer_h_mm = outer_size_mm(canvas, mat, frame)
    preview_w, preview_h = preview_size
    if preview_w <= 1 or preview_h <= 1:
        return None

    zoom = clamp(zoom, *ZOOM_RANGE)
    point_per_mm_base = preview_h / VISIBLE_WALL_HEIGHT_MM

    width = outer_w_mm * point_per_mm_base
    height = outer_h_mm * point_per_mm_base

    fit = min(1.0, preview_w * FIT_LIMIT / width, preview_h * FIT_LIMIT / height)
    width *= fit * zoom
    height *= fit * zoom

    hard = min(1.0, preview_w * HARD_LIMIT / width, preview_h * HARD_LIMIT / height)
    width *= hard
    height *= hard

    point_per_mm = width / outer_w_mm
    canvas_w, canvas_h = CANVAS[canvas]
    return {
        "outer": (width, height),
        "artwork": (canvas_w * point_per_mm, canvas_h * point_per_mm),
        "frame": FRAME_MM[frame] * point_per_mm,
        "mat": MAT_MM[mat] * point_per_mm,
        "point_per_mm": point_per_mm,
    }


def export_pixel_size(shape, max_edge=EXPORT_MAX_EDGE):
    height = max_edge
    width = round_half_up(max_edge * SHAPE_RATIO[shape])
    return (width, height)


def round_half_up(value):
    """Swift の .rounded()（四捨五入）に合わせる。"""
    return float(math.floor(value + 0.5))


def normalized_insets(top, bottom, left, right):
    def one(value):
        return clamp(value, 0.0, 0.45)

    top, bottom, left, right = one(top), one(bottom), one(left), one(right)
    vertical = top + bottom
    if vertical > 0.80:
        scale = 0.80 / vertical
        top *= scale
        bottom *= scale
    horizontal = left + right
    if horizontal > 0.80:
        scale = 0.80 / horizontal
        left *= scale
        right *= scale
    return (top, bottom, left, right)


def crop_rect(image_size, insets):
    width = max(1.0, float(image_size[0]))
    height = max(1.0, float(image_size[1]))
    top, bottom, left, right = normalized_insets(*insets)
    x = math.floor(width * left)
    y = math.floor(height * top)
    crop_w = math.floor(width * (1 - left - right))
    crop_h = math.floor(height * (1 - top - bottom))
    crop_w = min(max(crop_w, 1), width - x)
    crop_h = min(max(crop_h, 1), height - y)
    return (x, y, crop_w, crop_h)


def dimension_text(canvas):
    width, height = CANVAS[canvas]
    return f"{width} × {height} mm"


def aspect_text(canvas):
    width, height = CANVAS[canvas]
    return f"{width / height:.2f}：1"


def caption(canvas):
    return f"{canvas}　{dimension_text(canvas)}　{aspect_text(canvas)}"


# --- 点検 -------------------------------------------------------------

CHECKS = []


def check(name, condition, detail=""):
    CHECKS.append((name, bool(condition), detail))


def close(a, b, tolerance=0.01):
    return abs(a - b) <= tolerance


def main():
    # 1. 号数の外寸
    check(
        "F10・マット標準・木枠の外寸",
        outer_size_mm("F10", "標準", "木枠") == (706, 631),
        str(outer_size_mm("F10", "標準", "木枠")),
    )
    check(
        "F20・マット広・金縁の外寸",
        outer_size_mm("F20", "広", "金縁") == (1011, 890),
        str(outer_size_mm("F20", "広", "金縁")),
    )
    check(
        "額なしの外寸は側面 3mm ぶんだけ広い",
        outer_size_mm("F0", "なし", "額なし") == (186, 146),
        str(outer_size_mm("F0", "なし", "額なし")),
    )
    check("マットなし・額なしでも外寸は作品より大きい", outer_size_mm("F3", "なし", "額なし")[0] > 273)

    # 2. 画面への割り付け（iOS の縦長）
    lay = layout("F10", "標準", "木枠", 1.0, (390, 500))
    check("F10 は画面幅の 86% に収まる", lay["outer"][0] <= 390 * FIT_LIMIT + 1e-6, f"{lay['outer'][0]:.2f}pt")
    check("F10 の拡大率 1.0 で縦横比が保たれる", close(lay["outer"][0] / lay["outer"][1], 706 / 631, 0.002),
          f"{lay['outer'][0] / lay['outer'][1]:.4f}")
    recomposed = lay["artwork"][0] + 2 * lay["mat"] + 2 * lay["frame"]
    check("作品＋マット＋額縁＝外寸", close(recomposed, lay["outer"][0], 0.01), f"{recomposed:.2f} / {lay['outer'][0]:.2f}")
    check("F10 の作品は実寸どおり 530mm の比率", close(lay["artwork"][0], 530 * lay["point_per_mm"], 0.01),
          f"{lay['artwork'][0]:.2f}pt")
    check("F10 の額縁は約 13pt", 12 < lay["frame"] < 15, f"{lay['frame']:.2f}pt")

    # 3. 大きい号数は縮めて収める
    big = layout("F20", "広", "金縁", 1.0, (390, 500))
    check("F20 は 86% に縮む", big["outer"][0] <= 390 * FIT_LIMIT + 1e-6 and big["outer"][1] <= 500 * FIT_LIMIT + 1e-6,
          f"{big['outer'][0]:.1f} × {big['outer'][1]:.1f}pt")
    check("F20 は F10 より大きい", big["outer"][0] > lay["outer"][0] - 1e-6)

    # 4. 拡大と縮小
    small = layout("F0", "なし", "額なし", 1.0, (390, 500))
    zoom_in = layout("F0", "なし", "額なし", 1.6, (390, 500))
    zoom_out = layout("F0", "なし", "額なし", 0.6, (390, 500))
    check("F0 は画面の 3 割ほど", 0.2 < small["outer"][0] / 390 < 0.45, f"{small['outer'][0] / 390:.2f}")
    check("拡大 1.6 で 1.6 倍", close(zoom_in["outer"][0], small["outer"][0] * 1.6, 0.01),
          f"{zoom_in['outer'][0]:.2f}pt")
    check("縮小 0.6 で 0.6 倍", close(zoom_out["outer"][0], small["outer"][0] * 0.6, 0.01),
          f"{zoom_out['outer'][0]:.2f}pt")

    # 5. 拡大の上限（はみ出さない）
    over = layout("F20", "広", "金縁", 1.6, (390, 500))
    check("拡大しても画面の 96% を超えない",
          over["outer"][0] <= 390 * HARD_LIMIT + 1e-6 and over["outer"][1] <= 500 * HARD_LIMIT + 1e-6,
          f"{over['outer'][0]:.2f} × {over['outer'][1]:.2f}pt")
    check("拡大の上限は実際に効いている", over["outer"][0] > big["outer"][0], f"{big['outer'][0]:.1f} → {over['outer'][0]:.1f}pt")

    # 6. 予期しない入力
    check("プレビューが 0 なら割り付けなし", layout("F10", "標準", "木枠", 1.0, (0, 0)) is None)
    extreme = layout("F10", "標準", "木枠", 9.0, (390, 500))
    check("拡大率 9 は 1.6 に丸める", close(extreme["outer"][0], layout("F10", "標準", "木枠", 1.6, (390, 500))["outer"][0], 0.01))

    # 7. 書き出しの画素数
    square = export_pixel_size("1:1")
    portrait = export_pixel_size("4:5")
    check("1:1 は 2048 角", square == (2048.0, 2048.0), str(square))
    check("4:5 は 1638 × 2048", portrait == (1638.0, 2048.0), str(portrait))
    check("4:5 の縦横比", close(portrait[0] / portrait[1], 0.8, 0.0005), f"{portrait[0] / portrait[1]:.4f}")
    check("書き出しは 2048px を超えない", max(square + portrait) <= EXPORT_MAX_EDGE)

    # 8. 書き出しの割り付け（プレビューと同じ関数）
    export_layout = layout("F10", "標準", "木枠", 1.0, (2048, 2048))
    check("2048px に収まる", export_layout["outer"][0] <= 2048 * FIT_LIMIT + 1e-6,
          f"{export_layout['outer'][0]:.1f}px")
    check("作品は 1206px 前後", 1150 < export_layout["artwork"][0] < 1260,
          f"{export_layout['artwork'][0]:.1f}px")
    check("4096px の読み込みで足りる（引き伸ばさない）", 4096 > export_layout["artwork"][0] * 1.5,
          f"必要 {export_layout['artwork'][0] * 1.5:.0f}px")
    portrait_layout = layout("F10", "標準", "木枠", 1.0, export_pixel_size("4:5"))
    check("4:5 でも作品は収まる", portrait_layout["outer"][0] <= 1638 * FIT_LIMIT + 1e-6,
          f"{portrait_layout['outer'][0]:.1f}px")

    # 9. 裁ち落とし
    rect = crop_rect((1200, 900), (0.08, 0.0, 0.10, 0.05))
    check("裁ち落としの矩形", rect == (120, 72, 1020, 828), str(rect))
    check("裁ち落としで縦横比が変わる", not close(1020 / 828, 1200 / 900, 0.001))
    wide = crop_rect((1200, 900), (0.45, 0.45, 0.45, 0.45))
    # 45 + 45 を 80 に縮めるので残りは 20%。0.2 は二進で表せず、切り下げで 239 / 179 になる。
    check("上下 45% は合計 80% に縮める", wide[3] == 179, str(wide))
    check("左右 45% は合計 80% に縮める", wide[2] == 239, str(wide))
    check("上下左右とも 45% でも 1px 以上残る", wide[2] >= 1 and wide[3] >= 1)
    check("切り出しは元画像の内側", rect[0] + rect[2] <= 1200 and rect[1] + rect[3] <= 900)
    check("裁ち落としなしは全体", crop_rect((500, 400), (0, 0, 0, 0)) == (0, 0, 500, 400))

    # 10. キャプション
    check("F3 の寸法表記", dimension_text("F3") == "273 × 220 mm", dimension_text("F3"))
    check("F3 のアスペクト比", aspect_text("F3") == "1.24：1", aspect_text("F3"))
    check("F10 のキャプション", caption("F10") == "F10　530 × 455 mm　1.16：1", caption("F10"))

    # 11. 号数の並び
    check("号数は 12 種", len(CANVAS) == 12)
    ratios = [CANVAS[name][0] / CANVAS[name][1] for name in CANVAS]
    check("F 判はすべて横長", all(r > 1.0 for r in ratios), f"最小 {min(ratios):.3f}")
    check("F10 は F20 より小さい", CANVAS["F10"][0] < CANVAS["F20"][0])

    # --- 出力 ---
    width = max(len(name) for name, _, _ in CHECKS)
    failures = 0
    for name, ok, detail in CHECKS:
        print(f"{'ok  ' if ok else 'FAIL'}  {name.ljust(width)}  {detail}")
        if not ok:
            failures += 1
    print(f"\n{len(CHECKS) - failures} / {len(CHECKS)} 件 ok")
    if failures:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
