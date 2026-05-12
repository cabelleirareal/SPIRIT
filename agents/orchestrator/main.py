"""
SPIRIT Orchestrator Agent
Main coordination logic
"""

import os
import json
import asyncio
from anthropic import Anthropic
import redis.asyncio as redis
from datetime import datetime

# Configuration
ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY")
REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379")

# Initialize clients
anthropic = Anthropic(api_key=ANTHROPIC_API_KEY)
redis_client = None

# System prompt
SYSTEM_PROMPT = """You are the Orchestrator Agent for SPIRIT - a Strategic Predictive Intelligence & Research Intelligence Technology platform.

Your role is to coordinate multiple specialist agents to help users make data-driven decisions.

Available capabilities:
- Web research and data collection (via Firecrawl)
- Scenario simulation (via MiroFish)
- Workflow execution (via Langflow)
- Report generation

When a user asks for a decision or analysis:
1. Break down the request into sub-tasks
2. Delegate to specialist agents
3. Synthesize results
4. Provide clear recommendation with:
   - Confidence level (%)
   - Key assumptions
   - Main risks
   - Recommended action

Be concise, data-driven, and actionable."""


async def process_request(client_id: str, text: str):
    """
    Process user request through orchestrator
    """
    print(f"[Orchestrator] Processing request from {client_id}: {text[:100]}...")
    
    try:
        # Call Claude for orchestration
        response = anthropic.messages.create(
            model="claude-sonnet-4-20250514",
            max_tokens=4000,
            system=SYSTEM_PROMPT,
            messages=[{
                "role": "user",
                "content": text
            }]
        )
        
        # Extract response
        result = response.content[0].text
        
        # Publish response
        await redis_client.publish('agent:responses', json.dumps({
            'clientId': client_id,
            'response': {
                'text': result,
                'model': 'claude-sonnet-4',
                'timestamp': datetime.now().isoformat()
            }
        }))
        
        print(f"[Orchestrator] Response sent to {client_id}")
        
    except Exception as e:
        print(f"[Orchestrator] Error processing request: {e}")
        
        # Send error response
        await redis_client.publish('agent:responses', json.dumps({
            'clientId': client_id,
            'response': {
                'text': f"Error: {str(e)}",
                'error': True,
                'timestamp': datetime.now().isoformat()
            }
        }))


async def listen_for_requests():
    """
    Listen for agent requests via Redis pub/sub
    """
    global redis_client
    redis_client = await redis.from_url(REDIS_URL)
    
    pubsub = redis_client.pubsub()
    await pubsub.subscribe('agent:requests')
    
    print("[Orchestrator] Listening for requests...")
    
    async for message in pubsub.listen():
        if message['type'] == 'message':
            try:
                data = json.loads(message['data'])
                client_id = data.get('clientId')
                text = data.get('text')
                
                if client_id and text:
                    # Process in background
                    asyncio.create_task(process_request(client_id, text))
                    
            except Exception as e:
                print(f"[Orchestrator] Error parsing message: {e}")


async def main():
    """
    Main entry point
    """
    print("[Orchestrator] SPIRIT Orchestrator Agent starting...")
    print(f"[Orchestrator] Model: claude-sonnet-4")
    print(f"[Orchestrator] Redis: {REDIS_URL}")
    
    try:
        await listen_for_requests()
    except KeyboardInterrupt:
        print("\n[Orchestrator] Shutting down...")
    except Exception as e:
        print(f"[Orchestrator] Fatal error: {e}")
        raise


if __name__ == "__main__":
    asyncio.run(main())
