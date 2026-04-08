import os
import asyncio
from browser_use import Agent
from browser_use.llm.openai.chat import ChatOpenAI
from browser_use.llm.messages import UserMessage

# Configuration provided by the user
NVIDIA_NIM_KEY = os.getenv('NVIDIA_NIM_API_KEY', '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')
NIM_MODEL = 'moonshotai/kimi-k2.5'

async def main():
    # Configuration for NVIDIA NIM
    # Using browser_use's builtin ChatOpenAI for proper identification
    print(f"Initializing connection to NVIDIA NIM via OpenAI wrapper...")
    llm = ChatOpenAI(
        model=NIM_MODEL,
        api_key=NVIDIA_NIM_KEY,
        base_url="https://integrate.api.nvidia.com/v1"
    )

    # 1. Simple Connectivity Check
    print(f"Testing connectivity with model: {NIM_MODEL}...")
    try:
        test_msg = await llm.ainvoke([UserMessage(content="Hello, are you functional?")])
        print(f"NIM Connection Success! Response: {test_msg.completion[:50]}...")
    except Exception as e:
        print(f"NIM Connection Failed: {e}")
        return

    # 2. Initialize the Browser-Use Agent
    print(f"Initializing Browser-Use agent for navigation task...")
    agent = Agent(
        task="Go to https://www.google.com and search for 'NVIDIA NIM browser-use integration'",
        llm=llm,
    )

    # Run the agent
    print(f"Running agent with model: {NIM_MODEL}")
    result = await agent.run()
    
    # Print the result
    print("-" * 30)
    print("Agent Execution Result:")
    print(result)
    print("-" * 30)

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except Exception as e:
        print(f"An error occurred during agent run: {e}")
