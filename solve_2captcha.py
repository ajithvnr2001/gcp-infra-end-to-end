import os
import asyncio
from browser_use import Agent
from browser_use.llm.openai.chat import ChatOpenAI

# Configuration provided by the user
NVIDIA_NIM_KEY = os.getenv('NVIDIA_NIM_API_KEY', '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')
NIM_MODEL = 'moonshotai/kimi-k2.5'
NIM_BASE_URL = "https://integrate.api.nvidia.com/v1"

# 2Captcha Credentials
TWOCAPTCHA_EMAIL = "ajithvnr2001@gmail.com"
TWOCAPTCHA_PASSWORD = "nyYfD6RT4GCs"

async def main():
    # 1. Initialize LLM (NVIDIA NIM via OpenAI wrapper)
    print("Initialising NVIDIA NIM connectivity...")
    llm = ChatOpenAI(
        model=NIM_MODEL,
        api_key=NVIDIA_NIM_KEY,
        base_url=NIM_BASE_URL
    )

    # 2. Define the automation task
    # We provide a very clear set of instructions for the agent to follow.
    # The '100 captchas' requirement is handled by asking the agent to repeat the process.
    task = f"""
    1. Go to https://2captcha.com/auth/login
    2. Login using email: {TWOCAPTCHA_EMAIL} and password: {TWOCAPTCHA_PASSWORD}
    3. Once logged in, navigate to the 'Worker' cabinet or the 'Start Work' section.
    4. Begin solving captchas.
    5. CRITICAL: Continue solving captchas one by one until you have successfully solved 100. 
       - After each successful solve, wait for the next captcha to appear.
       - Track your progress mentally or in your memory.
       - Do not stop until the count reaches 100.
    6. If you encounter any 'I am a human' checks for the session itself, solve them as well.
    """

    print(f"Starting 2Captcha automation with model: {NIM_MODEL}")
    print("The agent will now log in and begin the solving loop. This may take significant time.")

    # 3. Create and run the Agent in a retry loop
    # We set max_steps to a high value (e.g. 500) to allow for many iterations of captcha solving.
    # We use a retry loop to handle the "Frame not found" CDP errors common on dynamic pages.
    max_retries = 3
    for attempt in range(max_retries):
        print(f"Agent Run Attempt {attempt + 1}/{max_retries}...")
        agent = Agent(
            task=task,
            llm=llm,
            max_steps=500,
            step_timeout=300, # Increase step timeout for stability
            llm_timeout=120  # Increase LLM timeout
        )

        try:
            result = await agent.run()
            print("-" * 30)
            print("Final Result Summary:")
            print(result)
            print("-" * 30)
            break # Success, exit loop
        except Exception as e:
            print(f"An error occurred during execution: {e}")
            if "frameId" in str(e) or "ax_tree" in str(e):
                print("Detected dynamic frame issue. Retrying in 10 seconds...")
                await asyncio.sleep(10)
            else:
                break

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except Exception as e:
        print(f"The script failed to start: {e}")
