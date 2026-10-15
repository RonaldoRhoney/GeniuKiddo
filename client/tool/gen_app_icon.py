"""Gera o ícone do app (rosto do Kiddo) a partir do mesmo desenho vetorial
de app/guide_avatar.dart (mesmas cores e coordenadas, viewBox 120x132,
recortado na região da cabeça). Zero custo: só Pillow (stdlib-adjacent,
já instalado), nenhum serviço externo.

Saída:
  assets/icon/icon.png          -- ícone completo (fundo roxo + rosto), 1024x1024
  assets/icon/icon_foreground.png -- só o rosto, fundo transparente, pro
                                      adaptive icon do Android (foreground layer)
"""

from PIL import Image, ImageDraw

SIZE = 1024
SCALE = SIZE / 120  # mesmo viewBox 120x132 do guide_avatar.dart, mas só a cabeça (0..120 x 0..100)

PURPLE = (124, 92, 255, 255)   # 0xFF7C5CFF
SKIN = (255, 217, 184, 255)    # 0xFFFFD9B8
TURBAN = (255, 201, 60, 255)   # 0xFFFFC93C
GEM = (255, 107, 107, 255)     # 0xFFFF6B6B
INK = (43, 45, 66, 255)        # 0xFF2B2D42
BLUSH = (255, 154, 162, 204)   # 0xFFFF9AA2 @ 0.8 alpha
WHITE = (255, 255, 255, 255)
WHITE_SOFT = (255, 255, 255, 178)


def p(x, y):
    return (x * SCALE, y * SCALE)


def draw_face(draw: ImageDraw.ImageDraw):
    # Cabeça
    cx, cy, r = 60, 54, 38
    draw.ellipse([p(cx - r, cy - r), p(cx + r, cy + r)], fill=SKIN)

    # Bochechas
    draw.ellipse([p(33 - 7.5, 64 - 7.5), p(33 + 7.5, 64 + 7.5)], fill=BLUSH)
    draw.ellipse([p(87 - 7.5, 64 - 7.5), p(87 + 7.5, 64 + 7.5)], fill=BLUSH)

    # Turbante (aproximado por polígono suave, fiel à curva do original)
    turban = [
        (23, 46), (28, 24), (45, 14), (60, 12), (75, 14), (92, 24), (97, 46),
        (80, 31), (60, 31), (40, 31),
    ]
    draw.polygon([p(x, y) for x, y in turban], fill=TURBAN)

    # Joia
    draw.ellipse([p(60 - 8.5, 21 - 8.5), p(60 + 8.5, 21 + 8.5)], fill=GEM)
    draw.ellipse([p(57 - 2.6, 18 - 2.6), p(57 + 2.6, 18 + 2.6)], fill=WHITE_SOFT)

    # Olhos
    draw.ellipse([p(45 - 6.5, 56 - 8.5), p(45 + 6.5, 56 + 8.5)], fill=INK)
    draw.ellipse([p(75 - 6.5, 56 - 8.5), p(75 + 6.5, 56 + 8.5)], fill=INK)
    draw.ellipse([p(47.3 - 2.4, 52 - 2.4), p(47.3 + 2.4, 52 + 2.4)], fill=WHITE)
    draw.ellipse([p(77.3 - 2.4, 52 - 2.4), p(77.3 + 2.4, 52 + 2.4)], fill=WHITE)

    # Sorriso
    draw.pieslice([p(45, 63), p(75, 86)], 0, 180, fill=INK)


def main():
    import os
    out_dir = os.path.join(os.path.dirname(__file__), "..", "assets", "icon")
    os.makedirs(out_dir, exist_ok=True)

    # Fundo transparente + rosto (foreground do adaptive icon)
    fg = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw_face(ImageDraw.Draw(fg))
    fg.save(os.path.join(out_dir, "icon_foreground.png"))

    # Ícone completo: fundo roxo sólido + rosto (pra launchers sem adaptive icon)
    full = Image.new("RGBA", (SIZE, SIZE), PURPLE)
    draw_face(ImageDraw.Draw(full))
    full.save(os.path.join(out_dir, "icon.png"))

    print("Gerado:", out_dir)


if __name__ == "__main__":
    main()
