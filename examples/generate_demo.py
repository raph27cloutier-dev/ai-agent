"""Generate demo.html: an interactive visualization of the sample AgentMind."""

import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))

from agent_mind import build_graph, render
from agent_mind.sample_data import SAMPLE_MIND

if __name__ == "__main__":
    graph = build_graph(SAMPLE_MIND)
    out = pathlib.Path(__file__).resolve().parent / "demo.html"
    render(graph, str(out), title=SAMPLE_MIND.name)
    print(f"wrote {out} ({graph.number_of_nodes()} nodes, {graph.number_of_edges()} edges)")
