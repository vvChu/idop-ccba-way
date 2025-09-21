import anyio
import json
from typing import Any

from mcp.client.session_group import (
    ClientSessionGroup,
    SseServerParameters,
    StreamableHttpParameters,
)

BASE_URL = "http://127.0.0.1:9121"
# FastMCP defaults: SSE at /sse, StreamableHTTP at /mcp
SSE_ENDPOINTS = ["/sse"]
STREAM_ENDPOINTS = ["/mcp"]
PROJECT_PATH = r"d:\\idop-ccba-way"
REL_FILE = "tools/scripts/modules/SpListDeploy.psm1"


async def main() -> None:
    async with ClientSessionGroup() as group:
        # Try SSE endpoints first (preferred in our setup)
        connected = False
        last_error: Exception | None = None
        for ep in SSE_ENDPOINTS:
            try:
                await group.connect_to_server(
                    SseServerParameters(url=f"{BASE_URL}{ep}")
                )
                print(f"Connected via SSE at {BASE_URL}{ep}")
                connected = True
                break
            except Exception as e:
                last_error = e

        # Fall back to Streamable HTTP if needed
        if not connected:
            for ep in STREAM_ENDPOINTS:
                try:
                    await group.connect_to_server(
                        StreamableHttpParameters(url=f"{BASE_URL}{ep}")
                    )
                    print(f"Connected via StreamableHTTP at {BASE_URL}{ep}")
                    connected = True
                    break
                except Exception as e:
                    last_error = e

        if not connected:
            raise RuntimeError(
                f"Failed to connect to Serena MCP at {BASE_URL}. Last error: {last_error}"
            )

        # List tools
        print("Available tools:", list(group.tools.keys()))

        # Activate the current project (so future relative paths resolve)
        if "activate_project" in group.tools:
            res = await group.call_tool("activate_project", {"project": PROJECT_PATH})
            # Extract text from CallToolResult content blocks
            try:
                from mcp import types as mcp_types  # type: ignore
                if hasattr(res, "content") and isinstance(res.content, list):
                    texts = []
                    for block in res.content:
                        if isinstance(block, dict) and block.get("type") == "text":
                            texts.append(block.get("text", ""))
                        elif hasattr(block, "type") and getattr(block, "type") == "text":
                            texts.append(getattr(block, "text", ""))
                    print("activate_project ->", "\n".join([t for t in texts if t]))
                else:
                    print("activate_project ->", res)
            except Exception:
                print("activate_project ->", res)
        else:
            print("activate_project tool not available – continuing anyway")

    # Get symbols overview for the target file
        if "get_symbols_overview" in group.tools:
            res = await group.call_tool("get_symbols_overview", {"relative_path": REL_FILE})
            # Extract text payload and pretty print JSON if possible
            payload = None
            if hasattr(res, "content") and isinstance(res.content, list):
                for block in res.content:
                    text = None
                    if isinstance(block, dict) and block.get("type") == "text":
                        text = block.get("text", None)
                    elif hasattr(block, "type") and getattr(block, "type") == "text":
                        text = getattr(block, "text", None)
                    if text:
                        payload = text
                        break
            if payload is None:
                payload = str(res)
            # Print compact json or raw text
            try:
                data: Any = json.loads(payload)
            except Exception:
                data = payload
            print("get_symbols_overview ->", (
                json.dumps(data, indent=2) if isinstance(data, (dict, list)) else data
            )[:4000])
        else:
            print("get_symbols_overview tool not available")


if __name__ == "__main__":
    anyio.run(main)
