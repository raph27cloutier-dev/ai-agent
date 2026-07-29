# agent_mind

A small toolkit for visualizing an AI agent system as a "mind": one shared
**core** (identity, goals, shared context) surrounded by **department**
clusters (specialized sub-agents), each holding a tree of memory/skill
nodes. It renders as a dark, physics-based, interactive graph — drag nodes,
zoom, hover a node to see what it represents.

This is the pattern behind dashboards like the one that inspired this repo:
a central hub with knowledge radiating out into domains such as Marketing,
Operations, Sales, Customer, Internal, and Back Office.

## Quick start

```bash
pip install -r requirements.txt
python examples/generate_demo.py   # writes examples/demo.html
```

Open `examples/demo.html` in a browser. It's fully self-contained (no
network calls at view time) and fully interactive.

## Using your own agents

Build an `AgentMind` out of your own department agents and whatever they
know (skills, memories, tasks, docs — anything you want represented as a
node):

```python
from agent_mind import AgentMind, Department, MemoryNode, build_graph, render

mind = AgentMind(
    name="My Agent System",
    core_nodes=["identity", "goals", "tool access", "shared memory"],
    departments=[
        Department(
            key="support",
            label="SUPPORT",
            subtitle="tickets · macros · escalation",
            color="#4f8cf0",
            icon="\U0001F4AC",
            nodes=[
                MemoryNode("ticket triage rules"),
                MemoryNode("macros", children=[MemoryNode("refund macro")]),
            ],
        ),
        # ...more departments
    ],
)

graph = build_graph(mind)
render(graph, "my_mind.html", title=mind.name)
```

## How it maps to a real agent architecture

- **Core** = the shared context every sub-agent can see: identity, mission,
  active goals, tool credentials, org-wide policies.
- **Department** = a specialized sub-agent (or a role/skill cluster within
  one agent) responsible for one business domain.
- **Memory nodes** = the individual facts, skills, docs, or past
  interactions that department knows about, structured as a tree so
  related memories chain off a common parent (e.g. `content calendar` →
  `blog topics` → `SEO keywords`).

Swap `agent_mind/sample_data.py` for a loader that pulls this structure
from your actual agent framework (vector store metadata, a skills
registry, a memory database, etc.) to get a live picture of what your
agents collectively know.

## Files

- `agent_mind/models.py` — data model (`AgentMind`, `Department`, `MemoryNode`)
- `agent_mind/graph.py` — builds a `networkx` graph from an `AgentMind`
- `agent_mind/visualize.py` — renders the graph to interactive HTML via `pyvis`
- `agent_mind/sample_data.py` — example six-department mind used by the demo
- `examples/generate_demo.py` — generates `examples/demo.html`
