"""アプリアイコン（1024×1024）を作る。アイボリー × 墨色 + 額縁の一辺。

紙の上に、墨の細い額縁をひとつ。中は麻の色の面。引き算だけで作る。
"""

from pathlib import Path

from PIL import Image, ImageDraw

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
OUT = ROOT / "Resources" / "Assets.xcassets" / "AppIcon.appiconset"

SIZE = 1024
SCALE = 4
PAPER = (249, 248, 245)
INK = (26, 26, 27)
GROUND_TOP = (240, 231, 214)
GROUND_BOTTOM = (214, 202, 180)
MAT = (252, 251, 247)


def main() -> None:
    canvas = SIZE * SCALE
    image = Image.new("RGB", (canvas, canvas), PAPER)
    draw = ImageDraw.Draw(image)

    # 額縁の外寸（画面の 55% × 43%）
    frame_w = 0.556 * canvas
    frame_h = 0.432 * canvas
    left = (canvas - frame_w) / 2
    top = (canvas - frame_h) / 2
    right = left + frame_w
    bottom = top + frame_h

    # 内側の面（麻色のグラデーション）
    band = 0.036 * canvas
    inner = [left + band, top + band, right - band, bottom - band]
    gradient = Image.new("RGB", (8, 256))
    for y in range(256):
        t = y / 255
        gradient.putpixel(
            (0, y),
            tuple(
                int(GROUND_TOP[i] + (GROUND_BOTTOM[i] - GROUND_TOP[i]) * t)
                for i in range(3)
            ),
        )
    gradient = gradient.resize(
        (int(inner[2] - inner[0]), int(inner[3] - inner[1])), Image.LANCZOS
    )
    image.paste(gradient, (int(inner[0]), int(inner[1])))

    # 墨の額縁（外側の稜線と内側の溝を 1 本ずつ）
    draw.rectangle([left, top, right, bottom], outline=INK, width=int(band))
    draw.rectangle(
        [left + band, top + band, right - band, bottom - band],
        outline=(255, 255, 255),
        width=max(2, int(0.004 * canvas)),
    )

    # マットの縁（紙の白をひと筋）
    mat_band = 0.030 * canvas
    draw.rectangle(
        [left + band + 1, top + band + 1, right - band - 1, bottom - band - 1],
        outline=MAT,
        width=int(mat_band),
    )

    icon = image.resize((SIZE, SIZE), Image.LANCZOS)
    OUT.mkdir(parents=True, exist_ok=True)
    icon.save(OUT / "AppIcon.png", "PNG")
    print(f"wrote {OUT / 'AppIcon.png'} ({icon.size})")


if __name__ == "__main__":
    main()
