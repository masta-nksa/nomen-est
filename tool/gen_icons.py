#!/usr/bin/env python3
"""Erzeugt alle Icon-Dateien fuer Nomen est aus einer einzigen Vektorquelle.

Aufruf aus dem Projektstamm:  python tool/gen_icons.py
Schreibt nach web/favicon.png und web/icons/.
"""
import os
import shutil
import subprocess
import sys

# ---------------------------------------------------------------
# EINZIGE STELLE FUER DIE CI-FARBE
ORANGE = "#FF890A"
WHITE = "#FFFFFF"
# ---------------------------------------------------------------

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WEB = os.path.join(ROOT, "web")
ICONS = os.path.join(WEB, "icons")


def icon_svg(radius=44, motif_scale=1.0, uid="a"):
    """Motiv "Foto & Name" auf einem 200x200-Raster.

    radius       Eckenradius im 200er-Raster (0 = vollflaechig quadratisch)
    motif_scale  Verkleinerung des Motivs, z. B. fuer die maskable-Safe-Zone
    """
    return f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200" width="200" height="200">
  <rect width="200" height="200" rx="{radius}" fill="{ORANGE}"/>
  <g transform="translate(100 100) scale({motif_scale}) translate(-100 -100)">
    <clipPath id="frame{uid}"><rect x="52" y="44" width="96" height="82" rx="12"/></clipPath>
    <rect x="52" y="44" width="96" height="82" rx="12" fill="{WHITE}"/>
    <g clip-path="url(#frame{uid})" fill="{ORANGE}">
      <circle cx="100" cy="80" r="17"/>
      <circle cx="100" cy="138" r="30"/>
    </g>
    <rect x="52" y="138" width="96" height="18" rx="9" fill="{WHITE}"/>
  </g>
</svg>
"""


def draw_with_pillow(path, size, radius, motif_scale):
    """Letzter Rueckfallweg: dasselbe Motiv direkt mit Pillow zeichnen.

    Auf Windows fehlt cairosvg meist die native cairo-DLL, und librsvg oder
    Inkscape sind selten vorhanden. Pillow ist ein reines Python-Wheel und
    laeuft ueberall. Die Geometrie ist dieselbe wie in icon_svg(), nur
    gezeichnet statt gerendert. Gegen Treppenstufen wird vierfach
    ueberabgetastet und danach verkleinert.
    """
    from PIL import Image, ImageDraw

    SS = 4
    k = size * SS / 200.0          # Raster 200 -> Pixel
    px = lambda v: v * k
    orange = tuple(int(ORANGE[i:i + 2], 16) for i in (1, 3, 5)) + (255,)
    white = tuple(int(WHITE[i:i + 2], 16) for i in (1, 3, 5)) + (255,)
    # Motiv um den Mittelpunkt (100 100) skalieren, wie im SVG-transform
    m = lambda v: 100 + (v - 100) * motif_scale
    r = lambda v: v * motif_scale  # Radien und Laengen ohne Verschiebung

    big = size * SS
    img = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([0, 0, big - 1, big - 1], radius=px(radius), fill=orange)

    frame = [px(m(52)), px(m(44)), px(m(148)) - 1, px(m(126)) - 1]
    d.rounded_rectangle(frame, radius=px(r(12)), fill=white)

    # Silhouette auf eigener Ebene, damit sie am Fotorahmen beschnitten wird
    figure = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    fd = ImageDraw.Draw(figure)
    for cx, cy, rad in ((100, 80, 17), (100, 138, 30)):
        fd.ellipse([px(m(cx) - r(rad)), px(m(cy) - r(rad)),
                    px(m(cx) + r(rad)), px(m(cy) + r(rad))], fill=orange)
    clip = Image.new("L", (big, big), 0)
    ImageDraw.Draw(clip).rounded_rectangle(frame, radius=px(r(12)), fill=255)
    img.paste(figure, (0, 0), Image.composite(figure.getchannel("A"), clip, clip))

    d.rounded_rectangle([px(m(52)), px(m(138)), px(m(148)) - 1, px(m(156)) - 1],
                        radius=px(r(9)), fill=white)

    img.resize((size, size), Image.LANCZOS).save(path)


def rasterize(svg, path, size, radius, motif_scale):
    """Rendert SVG nach PNG. Nutzt cairosvg, sonst ein externes Werkzeug."""
    try:
        import cairosvg
        cairosvg.svg2png(bytestring=svg.encode(), write_to=path,
                         output_width=size, output_height=size)
        return
    except (ImportError, OSError):
        # OSError: cairosvg ist installiert, die native cairo-Bibliothek fehlt
        pass

    tmp = path + ".tmp.svg"
    with open(tmp, "w") as f:
        f.write(svg)
    candidates = [
        ["rsvg-convert", "-w", str(size), "-h", str(size), "-o", path, tmp],
        ["inkscape", tmp, "--export-type=png", f"--export-filename={path}",
         "-w", str(size), "-h", str(size)],
    ]
    try:
        for cmd in candidates:
            if shutil.which(cmd[0]):
                subprocess.run(cmd, check=True, capture_output=True)
                return
    finally:
        if os.path.exists(tmp):
            os.remove(tmp)

    try:
        draw_with_pillow(path, size, radius, motif_scale)
    except ImportError:
        sys.exit("Kein Rasterizer gefunden. Bitte 'pip install pillow' oder "
                 "'pip install cairosvg' oder librsvg bzw. Inkscape installieren.")


def render(path, size, radius=44, motif_scale=1.0, uid="a"):
    rasterize(icon_svg(radius, motif_scale, uid), path, size, radius, motif_scale)
    print(f"  {os.path.relpath(path, ROOT):40s} {size}x{size}")


os.makedirs(ICONS, exist_ok=True)

# Vektorquelle mitliefern, damit das Motiv nachvollziehbar bleibt
with open(os.path.join(ICONS, "logo.svg"), "w") as f:
    f.write(icon_svg(radius=44, uid="m"))
print("Vektorquelle\n  web/icons/logo.svg")

# Standard-Icons: abgerundetes Quadrat, Motiv in voller Groesse
print("\nmanifest icons (purpose: any)")
for s in (192, 512):
    render(os.path.join(ICONS, f"Icon-{s}.png"), s, radius=44, uid=f"any{s}")

# Maskable: vollflaechig quadratisch, Motiv auf 90 %. Es liegt damit
# innerhalb eines Kreises von rund 66 % Durchmesser; die Spezifikation
# erlaubt bis 80 %, also schneidet kein Launcher hinein.
print("\nmanifest icons (purpose: maskable)")
for s in (192, 512):
    render(os.path.join(ICONS, f"Icon-maskable-{s}.png"), s,
           radius=0, motif_scale=0.9, uid=f"msk{s}")

# iOS: vollflaechig und deckend. Transparenz wuerde dort schwarz.
# Keine eigene Rundung, iOS maskiert selbst.
print("\niOS Homescreen")
render(os.path.join(ICONS, "apple-touch-icon.png"), 180, radius=0, uid="apple")

print("\nFavicon")
render(os.path.join(WEB, "favicon.png"), 32, radius=44, uid="fav")

print(f"\nFertig. Farbe: {ORANGE}")
