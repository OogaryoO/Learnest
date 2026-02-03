import os
import json
from firebase_functions import https_fn
from firebase_functions import params
from firebase_functions.options import set_global_options
from firebase_admin import initialize_app
from youtube_transcript_api import YouTubeTranscriptApi

from google import genai
from google.genai import types


set_global_options(max_instances=10)

initialize_app()

google_api_key = params.SecretParam('GOOGLE_API_KEY')
# GOOGLE_API_KEY = os.environ.get("GOOGLE_API_KEY", "YOUR_API_KEY_HERE")
# genai.configure(api_key=GOOGLE_API_KEY)

@https_fn.on_call(secrets=[google_api_key])
def process_video_resource(req: https_fn.CallableRequest):
    
    # set api key
    api_key = google_api_key.value
    genai.configure(api_key=api_key)

    # get video_id from app
    video_id = req.data.get("video_id")
    
    if not video_id:
        return {"status": "error", "message": "Missing video_id"}

    full_transcript = ""
    try:
        # chinese first, then English
        transcript_list = YouTubeTranscriptApi.get_transcript(
            video_id, 
            languages=['zh-Hant', 'en', 'en-US']
        )
        
        full_transcript = " ".join([item['text'] for item in transcript_list])
        
        if len(full_transcript) < 50:
             return {"status": "error", "message": "Transcript too short or unavailable."}

    except Exception as e:
        
        return {
            "status": "error", 
            "message": f"Failed to fetch transcript: {str(e)}"
        }

    # call Gemini API
    try:
        model = genai.GenerativeModel('gemini-2.5-flash')
        client = genai.Client(api_key=api_key)
        
        prompt = f"""
        # Role
        你是一位資深的「微學習（Micro-learning）」設計專家。

        # Task
        請分析以下 YouTube 影片的逐字稿，並產出結構化的學習資源。你的輸出必須嚴格遵守 JSON 格式，以便程式解析。

        # Transcript
        {full_transcript}

        # Output Format (JSON)
        請直接回傳一個 JSON 物件，不要包含 Markdown 標籤 (如 ```json)。格式如下：
        {{
          "title": "影片核心主題",
          "summary": "一段 100 字以內的繁體中文摘要。概述影片最關鍵的知識點。",
          "learning_points": ["重點 1", "重點 2", "重點 3"],
          "flashcards": [
            {{
              "question": "針對關鍵概念的提問（主動回憶）",
              "answer": "簡短精確的回答 (50字內)"
            }},
            {{
              "question": "應用型問題（例如：在什麼情境下會使用...？）",
              "answer": "實踐導向的回答",
            }}
          ]
        }}

        # Constraints
        1. 語言：請使用「繁體中文」輸出。
        2. 簡潔性：每張小卡的回答不超過 50 字，符合「微學習」碎片化閱讀的特性。
        3. 準確性：只根據提供的影片內容產出，不要虛構事實。
        4. 純淨輸出：只回傳 JSON 物件本身，不要包含任何 Markdown 代碼塊標籤（如 ```json）或額外的文字說明。
        """

        # send request and force response to be JSON format
        response = client.models.generate_content(
            model='gemini-2.5-flash',
            contents=prompt,
            config=types.GenerateContentConfig(
                response_mime_type='application/json', # 強制 JSON
                temperature=0.2
            )
        )

        # more robust way to ensure is't JSON
        ai_response_text = response.text
        result_json = json.loads(ai_response_text)

        return {
            "status": "success",
            "data": result_json
        }

    except json.JSONDecodeError:
        return {
            "status": "error",
            "message": "AI generation failed to produce valid JSON."
        }
    except Exception as e:
        return {
            "status": "error",
            "message": f"AI processing error: {str(e)}"
        }