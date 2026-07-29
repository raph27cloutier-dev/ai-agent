"""Render an AgentMind graph as a self-contained, interactive dark-themed HTML page."""

from __future__ import annotations

import json

import networkx as nx
from pyvis.network import Network

BACKGROUND = "#2b2a55"

PHYSICS_OPTIONS = {
    "physics": {
        "solver": "barnesHut",
        "barnesHut": {
            "gravitationalConstant": -12000,
            "centralGravity": 0.9,
            "springLength": 90,
            "springConstant": 0.03,
            "damping": 0.35,
            "avoidOverlap": 0.6,
        },
        "stabilization": {"iterations": 400},
    },
    "interaction": {
        "hover": True,
        "dragNodes": True,
        "zoomView": True,
        "tooltipDelay": 100,
    },
    "edges": {
        "smooth": {"type": "continuous"},
        "color": {"inherit": False},
    },
}


def render(graph: nx.Graph, output_path: str, title: str = "Agent Mind") -> str:
    """Write `graph` out as an interactive HTML file at `output_path`. Returns the path."""
    net = Network(
        height="950px",
        width="100%",
        bgcolor=BACKGROUND,
        font_color="#ffffff",
        directed=False,
        notebook=False,
        cdn_resources="in_line",
    )
    net.from_nx(graph)
    net.set_options(json.dumps(PHYSICS_OPTIONS))
    net.write_html(output_path, open_browser=False, notebook=False)

    with open(output_path, "r+", encoding="utf-8") as f:
        html = f.read().replace("<title>Network</title>", f"<title>{title}</title>", 1)
        f.seek(0)
        f.write(html)
        f.truncate()

    return output_path
