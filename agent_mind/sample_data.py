"""Example AgentMind: six department agents sharing one core, modeled after
a typical small-company org chart. Swap this out with your own agents'
skills/memories to visualize your own system."""

from __future__ import annotations

from .models import AgentMind, Department, MemoryNode


def chain(*labels: str) -> MemoryNode:
    """Build a linear chain of nodes, e.g. chain('a', 'b', 'c') -> a -> b -> c."""
    head = MemoryNode(labels[-1])
    for label in reversed(labels[:-1]):
        head = MemoryNode(label, children=[head])
    return head


SAMPLE_MIND = AgentMind(
    name="Company Agent Mind",
    core_nodes=[
        "identity", "mission", "tone of voice", "tool access", "shared calendar",
        "org chart", "brand assets", "active goals", "escalation policy",
        "user profile", "compliance rules", "budget limits",
    ],
    departments=[
        Department(
            key="marketing",
            label="MARKETING",
            subtitle="content · brand · distribution",
            color="#8b7cf6",
            icon="\U0001F4E3",
            nodes=[
                chain("content calendar", "blog topics", "SEO keywords"),
                chain("brand voice guide", "tone examples"),
                chain("social posts", "channel mix", "posting cadence"),
                chain("email campaigns", "segment lists"),
                chain("ad copy templates", "A/B results"),
                chain("competitor tracking"),
                chain("campaign analytics", "attribution model"),
            ],
        ),
        Department(
            key="operations",
            label="OPERATIONS",
            subtitle="onboarding · builds · client ops",
            color="#2fd9c8",
            icon="⚙️",
            nodes=[
                chain("onboarding checklist", "welcome sequence"),
                chain("build pipeline", "release steps", "rollback plan"),
                chain("client ops runbook"),
                chain("SLAs", "response targets"),
                chain("incident log", "postmortems"),
                chain("vendor list"),
                chain("tooling inventory", "access requests"),
            ],
        ),
        Department(
            key="sales",
            label="SALES",
            subtitle="targeting · outreach · sequencing",
            color="#e0507a",
            icon="\U0001F4C8",
            nodes=[
                chain("lead scoring rules", "ICP criteria"),
                chain("outreach sequences", "follow-up cadence"),
                chain("call scripts", "objection handling"),
                chain("pipeline stages", "forecast model"),
                chain("CRM sync", "field mapping"),
                chain("quota tracking"),
                chain("win/loss notes"),
            ],
        ),
        Department(
            key="customer",
            label="CUSTOMER",
            subtitle="support · success · community",
            color="#d162c4",
            icon="\U0001F4AC",
            nodes=[
                chain("support macros", "tone guidelines"),
                chain("escalation paths", "on-call rotation"),
                chain("NPS surveys", "sentiment trends"),
                chain("churn signals", "save playbook"),
                chain("onboarding calls", "success milestones"),
                chain("community guidelines"),
                chain("renewal checklist"),
            ],
        ),
        Department(
            key="internal",
            label="INTERNAL",
            subtitle="tools · access · security",
            color="#4f8cf0",
            icon="\U0001F50E",
            nodes=[
                chain("tool integrations", "API keys inventory"),
                chain("internal wiki", "runbooks index"),
                chain("access policies", "role matrix"),
                chain("IT tickets"),
                chain("security audits", "findings log"),
                chain("backup schedule"),
            ],
        ),
        Department(
            key="back_office",
            label="BACK OFFICE",
            subtitle="finance · legal · admin",
            color="#f0b93f",
            icon="\U0001F4B0",
            nodes=[
                chain("invoicing rules", "payment terms"),
                chain("payroll calendar"),
                chain("expense policy", "approval limits"),
                chain("contracts repo", "renewal dates"),
                chain("compliance checklist"),
                chain("tax docs"),
                chain("vendor payments"),
            ],
        ),
    ],
)
