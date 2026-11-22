"""アプリアイコン（1024×1024）を作る。アイボリー × 墨 + 麻色の面。

紙の上に、墨の細い額縁をひとつ。中は麻色の面。引き算だけで作る。
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
OUT = ROOT / "Resources" / "Assets.xcassets" / "AppIcon.appiconset"

SIZE = 1024
SCALE = 4
PAPER = (249, 248, 245)
INK = (26, 26, 27)
GROUND_TOP = (241, 233, 217)
GROUND_BOTTOM = (211, 198, 174)
MAT = (252, 251, 247)


def vertical_gradient(width: int, height: int, top, bottom) -> Image.Image:
    """1px 幅で作ってから拡大する（横方向に色を混ぜない）。"""
    strip = Image.new("RGB", (1, height))
    for y in range(height):
        t = y / max(1, height - 1)
        strip.putpixel(
            (0, y),
            tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3)),
        )
    return strip.resize((width, height), Image.LANCZOS)


def main() -> None:
    canvas = SIZE * SCALE
    image = Image.new("RGB", (canvas, canvas), PAPER)
    draw = ImageDraw.Draw(image)

    # 額縁の外寸（画面の 68% × 54%）
    frame_w = 0.68 * canvas
    frame_h = 0.54 * canvas
    left = (canvas - frame_w) / 2
    top = (canvas - frame_h) / 2
    right = left + frame_w
    bottom = top + frame_h

    band = 0.030 * canvas
    mat = 0.026 * canvas

    # 壁に落ちる淡い影（右下へ少し落とす）
    shadow = Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))
    shift = 0.010 * canvas
    ImageDraw.Draw(shadow).rectangle(
        [left + shift * 0.4, top + shift, right + shift * 0.4, bottom + shift],
        fill=(0, 0, 0, 96),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=0.014 * canvas))
    image = Image.alpha_composite(image.convert("RGBA"), shadow).convert("RGB")
    draw = ImageDraw.Draw(image)

    # 中の面（麻色のグラデーション）
    inner = [
        int(left + band + mat),
        int(top + band + mat),
        int(right - band - mat),
        int(bottom - band - mat),
    ]
    ground = vertical_gradient(inner[2] - inner[0], inner[3] - inner[1], GROUND_TOP, GROUND_BOTTOM)
    image.paste(ground, (inner[0], inner[1]))

    # 墨の額縁
    draw.rectangle([left, top, right, bottom], outline=INK, width=int(band))
    # 内側の溝（紙の白をひと筋）
    groove = max(2, int(0.004 * canvas))
    draw.rectangle(
        [left + band, top + band, right - band, bottom - band],
        outline=MAT,
        width=groove,
    )

    icon = image.resize((SIZE, SIZE), Image.LANCZOS)
    OUT.mkdir(parents=True, exist_ok=True)
    icon.save(OUT / "AppIcon.png", "PNG")
    print(f"wrote {OUT / 'AppIcon.png'} ({icon.size})")


if __name__ == "__main__":
    main()
