"""Turn an AgentMind into a networkx graph ready for visualization."""

from __future__ import annotations

import networkx as nx

from .models import AgentMind, MemoryNode

CORE_ANCHOR = "__core__"
CORE_COLOR = "#e8e6ff"
LEAF_COLOR = "#f5f5f7"


def _leaf_color(border: str) -> dict:
    return {"background": LEAF_COLOR, "border": border, "highlight": {"background": LEAF_COLOR, "border": border}}


def _add_memory_tree(
    graph: nx.Graph,
    parent_id: str,
    nodes: list[MemoryNode],
    dept_key: str,
    color: str,
    path: str,
    depth: int,
) -> None:
    size = max(6, 16 - depth * 3)
    for i, node in enumerate(nodes):
        node_id = f"{dept_key}:{path}:{i}"
        graph.add_node(
            node_id,
            label="",
            title=node.label,
            color=_leaf_color(color),
            shape="dot",
            size=size,
        )
        graph.add_edge(parent_id, node_id, color=color, width=1)
        if node.children:
            _add_memory_tree(
                graph, node_id, node.children, dept_key, color, f"{path}:{i}", depth + 1
            )


def build_graph(mind: AgentMind) -> nx.Graph:
    """Build the full mind graph: core cluster + every department's tree."""
    graph = nx.Graph()

    graph.add_node(
        CORE_ANCHOR,
        label="",
        title=mind.name,
        color=_leaf_color(CORE_COLOR),
        shape="dot",
        size=4,
        physics=True,
    )

    prev_id = None
    for i, label in enumerate(mind.core_nodes):
        node_id = f"core:{i}"
        graph.add_node(
            node_id,
            label="",
            title=label,
            color=_leaf_color(CORE_COLOR),
            shape="dot",
            size=5,
        )
        graph.add_edge(CORE_ANCHOR, node_id, color=CORE_COLOR, width=1)
        if prev_id is not None and i % 3 != 0:
            graph.add_edge(prev_id, node_id, color=CORE_COLOR, width=1)
        prev_id = node_id

    for dept in mind.departments:
        graph.add_node(
            dept.key,
            label=f"{dept.icon}\n{dept.label}",
            title=f"{dept.label} — {dept.subtitle}",
            color=dept.color,
            shape="dot",
            size=30,
            borderWidth=3,
            font={"color": "white", "size": 16, "face": "arial", "bold": "true"},
        )
        graph.add_edge(CORE_ANCHOR, dept.key, color=dept.color, width=2)
        _add_memory_tree(graph, dept.key, dept.nodes, dept.key, dept.color, "n", 1)

    return graph
