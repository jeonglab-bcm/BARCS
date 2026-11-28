"""Map archived gene symbols to stable ids from pinned reference snapshots (HGNC, MGI).

The importer will call this. Reference files are downloaded once, stored outside git,
and recorded by name, version and sha256 in the build manifest. No network access here.

Mapping rule, per organism reference:
  exact current symbol (case-sensitive)            -> mapped
  else a unique id through previous symbols/aliases -> synonym
  else several candidate ids                        -> ambiguous (gene_id null)
  else                                              -> unmapped  (gene_id null)
Nothing but "mapped" is silent: the other statuses are validator warnings and the
reviewer confirms source identity.
"""

import csv
from dataclasses import dataclass
from pathlib import Path

from . import model as M

# Column layouts of the official bulk files. Check them against the downloaded
# snapshot before the first import; a missing column fails loudly.
LAYOUTS = {
    "hgnc": {"id": "hgnc_id", "symbol": "symbol", "synonyms": ("prev_symbol", "alias_symbol"), "sep": "|"},
    "mgi": {"id": "MGI Accession ID", "symbol": "Marker Symbol",
            "synonyms": ("Marker Synonyms (pipe-separated)",), "sep": "|"},
}


@dataclass(frozen=True)
class Mapping:
    gene_id: str | None
    status: str
    candidates: tuple


class GeneReference:
    def __init__(self, path, layout, version):
        self.path = Path(path)
        self.layout_name = layout
        self.version = version
        self.sha256 = M.sha256_file(self.path)
        lay = LAYOUTS[layout]
        self.current, self.synonyms = {}, {}
        with self.path.open(encoding="utf-8", newline="") as fh:
            reader = csv.DictReader(fh, delimiter="\t")
            needed = [lay["id"], lay["symbol"], *lay["synonyms"]]
            missing = [c for c in needed if c not in (reader.fieldnames or [])]
            if missing:
                raise ValueError(f"{self.path}: columns missing for layout {layout}: {missing}")
            for row in reader:
                gid, sym = row[lay["id"]].strip(), row[lay["symbol"]].strip()
                if not gid or not sym:
                    continue
                self.current.setdefault(sym, set()).add(gid)
                for col in lay["synonyms"]:
                    for syn in (row[col] or "").strip('"').split(lay["sep"]):
                        syn = syn.strip()
                        if syn:
                            self.synonyms.setdefault(syn, set()).add(gid)

    def map(self, symbol):
        exact = self.current.get(symbol, set())
        if len(exact) == 1:
            return Mapping(next(iter(exact)), "mapped", tuple(exact))
        cands = exact or self.synonyms.get(symbol, set())
        if len(cands) == 1:
            return Mapping(next(iter(cands)), "synonym", tuple(cands))
        if cands:
            return Mapping(None, "ambiguous", tuple(sorted(cands)))
        return Mapping(None, "unmapped", ())

    def manifest_entry(self):
        return {"layout": self.layout_name, "version": self.version, "file": self.path.name, "sha256": self.sha256}
