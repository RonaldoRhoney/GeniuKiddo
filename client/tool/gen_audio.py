#!/usr/bin/env python3
"""Gera os efeitos sonoros (pop/good/win/oops) e uma trilha de música de
fundo em loop, como WAV reais — mesmo desenho sonoro já aprovado nos
protótipos HTML (osciladores senoidais/triangulares via Web Audio),
renderizado em arquivo. Interino até M8 (trilhas/efeitos finais gravados).
"""
import math
import os
import struct
import sys
import wave

SR = 44100
SFX_DIR = sys.argv[1] if len(sys.argv) > 1 else '.'
MUSIC_DIR = sys.argv[2] if len(sys.argv) > 2 else '.'
os.makedirs(SFX_DIR, exist_ok=True)
os.makedirs(MUSIC_DIR, exist_ok=True)


def triangle(phase):
    # phase em [0,1) -> onda triangular, -1..1, mesma forma do oscilador
    # "triangle" do Web Audio (pico em p=0.25, vale em p=0.75).
    p = phase % 1.0
    if p < 0.25:
        return 4.0 * p
    if p < 0.75:
        return 2.0 - 4.0 * p
    return 4.0 * p - 4.0


def sine(phase):
    return math.sin(2 * math.pi * phase)


def add_tone(buf, freq, start, dur, vol, osc):
    """Envelope igual ao tone() dos protótipos: rampa linear 0->vol em
    20ms, depois decaimento exponencial vol->~0 até o fim da duração."""
    start_i = int(start * SR)
    n = int(dur * SR)
    attack = int(0.02 * SR)
    for i in range(n):
        idx = start_i + i
        if idx < 0:
            continue
        if idx >= len(buf):
            buf.extend([0.0] * (idx - len(buf) + 1))
        t = i / SR
        if i < attack:
            amp = vol * (i / attack)
        else:
            # decaimento exponencial de vol a 0.0001 ao longo do restante
            frac = (i - attack) / max(1, (n - attack))
            amp = vol * (0.0001 / vol) ** frac
        phase = freq * t
        buf[idx] += amp * osc(phase)


def render(buf, path, seconds):
    n = int(seconds * SR)
    frames = bytearray()
    peak = max(1.0, max((abs(x) for x in buf), default=1.0))
    scale = 0.9 / peak if peak > 0.9 else 1.0
    for i in range(n):
        v = buf[i] if i < len(buf) else 0.0
        v = max(-1.0, min(1.0, v * scale))
        frames += struct.pack('<h', int(v * 32767))
    with wave.open(path, 'w') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(bytes(frames))
    print('wrote', path, f'{seconds:.2f}s')


def sfx_pop():
    buf = []
    add_tone(buf, 520, 0.0, 0.18, 0.5, sine)
    add_tone(buf, 520 * 1.5, 0.06, 0.18, 0.35, sine)
    render(buf, os.path.join(SFX_DIR, 'pop.wav'), 0.3)


def sfx_good():
    buf = []
    for i, f in enumerate([523, 659, 784]):
        add_tone(buf, f, i * 0.09, 0.3, 0.55, triangle)
    render(buf, os.path.join(SFX_DIR, 'good.wav'), 0.7)


def sfx_win():
    buf = []
    for i, f in enumerate([523, 659, 784, 1047, 1319]):
        add_tone(buf, f, i * 0.11, 0.45, 0.6, triangle)
    render(buf, os.path.join(SFX_DIR, 'win.wav'), 1.0)


def sfx_oops():
    buf = []
    add_tone(buf, 247, 0.0, 0.14, 0.4, sine)
    add_tone(buf, 196, 0.1, 0.2, 0.35, sine)
    render(buf, os.path.join(SFX_DIR, 'oops.wav'), 0.35)


def sfx_build():
    buf = []
    for d in (0, 0.14, 0.28):
        add_tone(buf, 170, d, 0.09, 0.45, triangle)
    for i, f in enumerate([523, 659, 784, 1047]):
        add_tone(buf, f, 0.5 + i * 0.1, 0.35, 0.55, triangle)
    render(buf, os.path.join(SFX_DIR, 'build.wav'), 0.95)


def music_loop():
    # Mesma melodia/harmonia do musicTick() do app (escala pentatônica de
    # dó), um ciclo completo de 16 passos a 480ms, pronta pra tocar em
    # loop sem costura perceptível.
    PENT = [262, 294, 330, 392, 440, 523, 587, 659]
    MEL = [0, 2, 4, 2, 5, 4, 2, 0, 1, 3, 5, 3, 4, 2, 1, 0]
    STEP = 0.48
    buf = []
    for i, idx in enumerate(MEL):
        t = i * STEP
        f = PENT[idx]
        add_tone(buf, f, t, 0.55, 0.22, triangle)
        add_tone(buf, f * 2, t, 0.3, 0.07, sine)
        if i % 4 == 0:
            root = f / 2
            add_tone(buf, root, t, 1.3, 0.26, sine)
            add_tone(buf, root * 1.5, t, 1.3, 0.14, sine)
    total = len(MEL) * STEP
    render(buf, os.path.join(MUSIC_DIR, 'music_loop.wav'), total)


if __name__ == '__main__':
    sfx_pop()
    sfx_good()
    sfx_win()
    sfx_oops()
    sfx_build()
    music_loop()
