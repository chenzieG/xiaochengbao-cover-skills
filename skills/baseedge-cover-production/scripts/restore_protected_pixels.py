#!/usr/bin/env python3
"""Restore protected pixels exactly after image-model outpainting."""

import argparse
import json
import tempfile
from pathlib import Path

from PIL import Image


def restore(generated_path, protected_path, mask_path, output_path, audit_path=None):
    generated = Image.open(generated_path).convert("RGBA")
    protected = Image.open(protected_path).convert("RGBA")
    mask = Image.open(mask_path).convert("L")
    if generated.size != protected.size or generated.size != mask.size:
        raise ValueError("generated, protected reference, and mask must have identical dimensions")

    binary_mask = mask.point(lambda value: 255 if value else 0)
    restored = generated.copy()
    restored.paste(protected, (0, 0), binary_mask)
    Path(output_path).parent.mkdir(parents=True, exist_ok=True)
    restored.save(output_path, format="PNG")

    changed = 0
    max_error = 0
    for actual, expected, selected in zip(
        restored.get_flattened_data(),
        protected.get_flattened_data(),
        binary_mask.get_flattened_data(),
    ):
        if selected:
            error = max(abs(actual[i] - expected[i]) for i in range(4))
            if error:
                changed += 1
                max_error = max(max_error, error)
    audit = {"changed_pixel_count": changed, "max_channel_error": max_error}
    if audit_path:
        Path(audit_path).write_text(json.dumps(audit, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(audit, ensure_ascii=False))
    if changed or max_error:
        raise RuntimeError("protected pixel restoration did not reach exact equality")


def self_test():
    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory)
        Image.new("RGBA", (4, 4), (255, 0, 0, 255)).save(root / "generated.png")
        Image.new("RGBA", (4, 4), (0, 255, 0, 255)).save(root / "protected.png")
        mask = Image.new("L", (4, 4), 0)
        for y in range(1, 3):
            for x in range(1, 3):
                mask.putpixel((x, y), 255)
        mask.save(root / "mask.png")
        restore(root / "generated.png", root / "protected.png", root / "mask.png", root / "out.png")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--generated")
    parser.add_argument("--protected")
    parser.add_argument("--mask")
    parser.add_argument("--out")
    parser.add_argument("--audit-json")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        self_test()
        return
    required = (args.generated, args.protected, args.mask, args.out)
    if not all(required):
        parser.error("--generated, --protected, --mask, and --out are required")
    restore(args.generated, args.protected, args.mask, args.out, args.audit_json)


if __name__ == "__main__":
    main()
