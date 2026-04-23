import 'dotenv/config';
import express from "express";
import cors from "cors";
import axios from "axios";

const app = express();
app.use(cors());
app.use(express.json());

const API_KEY = process.env.DEEPSEEK_API_KEY;

if (!API_KEY) {
  console.error("❌ DEEPSEEK_API_KEY 未设置");
  process.exit(1);
}

// ===== 调用 DeepSeek =====
async function callDeepSeek(query) {
  const res = await axios.post(
    "https://api.deepseek.com/v1/chat/completions",
    {
      model: "deepseek-chat",
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
      timeout: 30000,
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
    console.error("❌ DeepSeek error:", e.response?.data || e.message);
    res.status(500).json({ error: "AI调用失败" });
  }
});

// ===== 启动 =====
console.log("API_KEY:", API_KEY);
app.listen(3000, () => {
  console.log("✅ DeepSeek server running: http://localhost:3000");
});