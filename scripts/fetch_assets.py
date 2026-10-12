#!/usr/bin/env python3
"""Restore the documented image and audio assets; never executes downloaded code.

Wheel atlases and minimap icons come from CommunityDragon. The game audio and the
弱爆 emote art come from the `darrenprx/lolPing` extractor output, converted here
with ffmpeg because AVAudioPlayer cannot read the original Wwise WAV/Opus inside
an .ogg container.
"""
import concurrent.futures
import json
import shutil
import subprocess
import tempfile
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CDRAGON = "https://raw.communitydragon.org/15.24/game/assets/ux/minimap/pings/"
# raw.githubusercontent.com is unreachable on some networks (the local machine
# times out), so the same files are tried through mirrors in order.
LOLPING = ["https://cdn.jsdelivr.net/gh/darrenprx/lolPing@main/assets/",
           "https://github.com/darrenprx/lolPing/raw/main/assets/",
           "https://raw.githubusercontent.com/darrenprx/lolPing/main/assets/"]
ICONS = ["retreat", "push", "on_my_way_new", "all_in", "assist", "need_ward",
         "mia_new", "area_is_warded_small_red_new", "ping", "ring", "ring2",
         "ring_danger", "ring2_yellow", "ring_green", "ring_red"]
# Local file name -> source path inside darrenprx/lolPing's assets folder.
SOUNDS = {
    "retreat.mp3": "sounds/SRP_12.wav",
    "push.mp3": "sounds/SRP_9.wav",
    "on_my_way.mp3": "sounds/OnMyWay.wav",
    "all_in.mp3": "sounds/SRP_4.wav",
    "assist_me.mp3": "sounds/ComeHere.wav",
    "need_vision.mp3": "sounds/SRP_7.wav",
    "q_mark.mp3": "sounds/MIA.wav",
    "enemy_vision.mp3": "sounds/AreaIsWarded.wav",
    "alert.mp3": "sounds/Base.wav",
    "weak.mp3": "emotes/unworthy_cn.ogg",
}
EMOTES = {"weak-emote.png": "emotes/unworthy_cn.png"}


def read(url, timeout=45):
    request = urllib.request.Request(url, headers={"User-Agent": "LoLPing-local-asset-fetch/1.0"})
    with urllib.request.urlopen(request, timeout=timeout) as response:
        return response.read()


def read_lolping(path):
    """Fetch one path from the reference project through the first mirror that answers."""
    failures = []
    for mirror in LOLPING:
        try:
            return read(mirror + path)
        except Exception as error:  # network, TLS timeout, 404 on a stale mirror
            failures.append(f"{mirror}{path}: {error}")
    raise RuntimeError(" / ".join(failures))


def write_png(destination, payload, name):
    if not payload.startswith(b"\x89PNG\r\n\x1a\n"):
        raise RuntimeError(f"Invalid PNG: {name}")
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_bytes(payload)


def fetch_png(folder, name, url):
    destination = ROOT / "Resources" / folder / name
    if destination.exists() and destination.stat().st_size > 0:
        return
    write_png(destination, read(url), name)


def fetch_emote(name, source):
    destination = ROOT / "Resources" / "Artwork" / name
    if destination.exists() and destination.stat().st_size > 0:
        return
    write_png(destination, read_lolping(source), name)


def fetch_mp3(name, source):
    destination = ROOT / "Resources" / "Sounds" / name
    if destination.exists() and destination.stat().st_size > 0:
        return
    if shutil.which("ffmpeg") is None:
        raise RuntimeError("ffmpeg is required to transcode the game audio")
    suffix = Path(source).suffix
    with tempfile.NamedTemporaryFile(suffix=suffix, delete=False) as handle:
        handle.write(read_lolping(source))
        temporary = handle.name
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", temporary, "-c:a", "libmp3lame",
                    "-q:a", "4", "-ar", "44100", str(destination)], check=True)
    Path(temporary).unlink()
    if destination.stat().st_size < 1000:
        raise RuntimeError(f"Invalid audio: {name}")


def main():
    manifest_path = ROOT / "Resources" / "asset-sources.json"
    manifest = json.loads(manifest_path.read_text()) if manifest_path.exists() else None
    jobs = [(fetch_png, ("Icons", name + ".png", CDRAGON + name + ".png")) for name in ICONS]
    jobs += [(fetch_png, ("Artwork", Path(item["path"]).name, item["url"]))
             for item in (manifest or {}).get("files", []) if item["path"].startswith("Artwork/")]
    jobs += [(fetch_emote, (name, source)) for name, source in EMOTES.items()]
    jobs += [(fetch_mp3, (name, source)) for name, source in SOUNDS.items()]
    with concurrent.futures.ThreadPoolExecutor(max_workers=5) as pool:
        list(pool.map(lambda job: job[0](*job[1]), jobs))
    print(f"Ready: {len(ICONS)} minimap icons, {len(EMOTES)} emote images, {len(SOUNDS)} game sounds")


if __name__ == "__main__":
    main()
