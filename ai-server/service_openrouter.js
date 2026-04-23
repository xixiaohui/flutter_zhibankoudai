import express from "express";
import cors from "cors";
import axios from "axios";

import 'dotenv/config';

const app = express();
app.use(cors());
app.use(express.json());

const API_KEY = process.env.OPENROUTER_API_KEY;

// ===== DeepSeek 调用 =====
async function callDeepSeek(query) {
  const res = await axios.post(
    "https://openrouter.ai/api/v1/chat/completions",
    {
      model: "deepseek/deepseek-chat",
      messages: [
        {
          role: "system",
          content: "你是一个材料行业专家，擅长分析玻璃纤维、FRP、复合材料。",
        },
        {
          role: "user",
          content: query,
        },
      ],
      temperature: 0.7,
      max_tokens: 1000,
    },
    {
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        "Content-Type": "application/json",
      },
    }
  );

  return res.data.choices[0].message.content;
}

// ===== API =====
app.post("/ai", async (req, res) => {
  try {
    const { query } = req.body;

    const result = await callDeepSeek(query);

    res.json({ result });
  } catch (e) {
    console.error("❌ AI error:", e.response?.data || e.message);
    res.status(500).json({ error: "AI调用失败" });
  }
});

console.log("API_KEY:", API_KEY);

// ===== 启动 =====
app.listen(3000, () => {
  console.log("✅ DeepSeek API server: http://localhost:3000");
});