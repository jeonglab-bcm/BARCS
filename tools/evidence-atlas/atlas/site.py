"""Render the static, read-only browser from a public export (never from the internal DB)."""

from . import model as M

TEMPLATE = M.ROOT / "web" / "template.html"
PLACEHOLDER = "/*__ATLAS_DATA__*/null"


def render(exp):
    payload = M.canonical_json(exp)
    # Keep the JSON inert inside <script>: no closing tags or HTML comments.
    payload = payload.replace("<", "\\u003c").replace(">", "\\u003e").replace("&", "\\u0026")
    payload = payload.replace("\u2028", "\\u2028").replace("\u2029", "\\u2029")
    html = TEMPLATE.read_text(encoding="utf-8")
    if html.count(PLACEHOLDER) != 1:
        raise ValueError("template must contain the data placeholder exactly once")
    return html.replace(PLACEHOLDER, payload)
