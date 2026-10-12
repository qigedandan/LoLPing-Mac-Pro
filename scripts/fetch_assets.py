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
    # Emote voices, one per emote (see PingKind.emotes).
    "facepalm.mp3": "emotes/facepalm.ogg",
    "unworthy.mp3": "emotes/unworthy.ogg",
    "unworthy_cn.mp3": "emotes/unworthy_cn.ogg",
    "poro_snax.mp3": "emotes/poro_snax.ogg",
    "sad_kitten.mp3": "emotes/sad_kitten.ogg",
    "cheeky_poro.mp3": "emotes/cheeky_poro.ogg",
    "angry_kitty.mp3": "emotes/angry_kitty.ogg",
    "gg_heart.mp3": "emotes/gg_heart.ogg",
    "bee_happy.mp3": "emotes/bee_happy.ogg",
    "bee_mad.mp3": "emotes/bee_mad.ogg",
    "bee_sad.mp3": "emotes/bee_sad.ogg",
    "snoozy_poro.mp3": "emotes/snoozy_poro.ogg",
    "wahaha.mp3": "emotes/wahaha.ogg",
    "omg_love_it.mp3": "emotes/omg_love_it.ogg",
    "poro_ride.mp3": "emotes/poro_ride.ogg",
    "dont_make_me_laugh.mp3": "emotes/dont_make_me_laugh.ogg",
    "woah_dizzy.mp3": "emotes/woah_dizzy.ogg",
    "haha_hilarious.mp3": "emotes/haha_hilarious.ogg",
    "gasp.mp3": "emotes/gasp.ogg",
    "super_approved.mp3": "emotes/super_approved.ogg",
    "pain.mp3": "emotes/pain.ogg",
    "laughing_out_loud.mp3": "emotes/laughing_out_loud.ogg",
    "hats_off.mp3": "emotes/hats_off.ogg",
    "call_me.mp3": "emotes/call_me.ogg",
    "think_about_it.mp3": "emotes/think_about_it.ogg",
    "unimpressed.mp3": "emotes/unimpressed.ogg",
    "did_you_just.mp3": "emotes/did_you_just.ogg",
    "nice_try.mp3": "emotes/nice_try.ogg",
    "nice.mp3": "emotes/nice.ogg",
    "despair.mp3": "emotes/despair.ogg",
    "does_not_compute.mp3": "emotes/does_not_compute.ogg",
    "come_at_me.mp3": "emotes/come_at_me.ogg",
    "how_could_you.mp3": "emotes/how_could_you.ogg",
    "scout_approved.mp3": "emotes/scout_approved.ogg",
    "maybe_next_time.mp3": "emotes/maybe_next_time.ogg",
    "okay.mp3": "emotes/okay.ogg",
    "good_job_buddy.mp3": "emotes/good_job_buddy.ogg",
    "teamwork.mp3": "emotes/teamwork.ogg",
    "i_will_destroy_you.mp3": "emotes/i_will_destroy_you.ogg",
    "not_today.mp3": "emotes/not_today.ogg",
    "oh.mp3": "emotes/oh.ogg",
    "come_again.mp3": "emotes/come_again.ogg",
    "magpie_oopsie.mp3": "emotes/magpie_oopsie.ogg",
    "such_foolishness.mp3": "emotes/such_foolishness.ogg",
}
EMOTES = {
    "facepalm.png": "emotes/facepalm.png",
    "unworthy.png": "emotes/unworthy.png",
    "unworthy_cn.png": "emotes/unworthy_cn.png",
    "poro_snax.png": "emotes/poro_snax.png",
    "sad_kitten.png": "emotes/sad_kitten.png",
    "cheeky_poro.png": "emotes/cheeky_poro.png",
    "angry_kitty.png": "emotes/angry_kitty.png",
    "gg_heart.png": "emotes/gg_heart.png",
    "bee_happy.png": "emotes/bee_happy.png",
    "bee_mad.png": "emotes/bee_mad.png",
    "bee_sad.png": "emotes/bee_sad.png",
    "snoozy_poro.png": "emotes/snoozy_poro.png",
    "wahaha.png": "emotes/wahaha.png",
    "omg_love_it.png": "emotes/omg_love_it.png",
    "poro_ride.png": "emotes/poro_ride.png",
    "dont_make_me_laugh.png": "emotes/dont_make_me_laugh.png",
    "woah_dizzy.png": "emotes/woah_dizzy.png",
    "haha_hilarious.png": "emotes/haha_hilarious.png",
    "gasp.png": "emotes/gasp.png",
    "super_approved.png": "emotes/super_approved.png",
    "pain.png": "emotes/pain.png",
    "laughing_out_loud.png": "emotes/laughing_out_loud.png",
    "hats_off.png": "emotes/hats_off.png",
    "call_me.png": "emotes/call_me.png",
    "think_about_it.png": "emotes/think_about_it.png",
    "unimpressed.png": "emotes/unimpressed.png",
    "did_you_just.png": "emotes/did_you_just.png",
    "nice_try.png": "emotes/nice_try.png",
    "nice.png": "emotes/nice.png",
    "despair.png": "emotes/despair.png",
    "does_not_compute.png": "emotes/does_not_compute.png",
    "come_at_me.png": "emotes/come_at_me.png",
    "how_could_you.png": "emotes/how_could_you.png",
    "scout_approved.png": "emotes/scout_approved.png",
    "maybe_next_time.png": "emotes/maybe_next_time.png",
    "okay.png": "emotes/okay.png",
    "good_job_buddy.png": "emotes/good_job_buddy.png",
    "teamwork.png": "emotes/teamwork.png",
    "i_will_destroy_you.png": "emotes/i_will_destroy_you.png",
    "not_today.png": "emotes/not_today.png",
    "oh.png": "emotes/oh.png",
    "come_again.png": "emotes/come_again.png",
    "magpie_oopsie.png": "emotes/magpie_oopsie.png",
    "such_foolishness.png": "emotes/such_foolishness.png",
}


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
