"""Data model for an agent 'mind': a central core surrounded by
department-specialized knowledge clusters, each holding memory/skill nodes."""

from __future__ import annotations

from dataclasses import dataclass, field


@dataclass
class MemoryNode:
    """A single unit of knowledge/memory/skill belonging to a department.

    Children let a node branch into more specific sub-memories, producing
    the chained, radiating look of the reference visualization.
    """

    label: str
    children: list["MemoryNode"] = field(default_factory=list)


@dataclass
class Department:
    """One specialized cluster of an agent's mind (e.g. Marketing, Sales)."""

    key: str
    label: str
    subtitle: str
    color: str
    icon: str = "*"
    nodes: list[MemoryNode] = field(default_factory=list)


@dataclass
class AgentMind:
    """The full mind: a shared core plus every department cluster around it."""

    name: str
    core_label: str = "core"
    core_nodes: list[str] = field(default_factory=list)
    departments: list[Department] = field(default_factory=list)
