import 'dotenv/config';
import express from "express";
import cors from "cors";
import axios from "axios";

import { genkit } from "genkit";
import { z } from "zod";

const app = express();
app.use(cors());
app.use(express.json());

const API_KEY = process.env.DEEPSEEK_API_KEY;

if (!API_KEY) {
  console.error("❌ DEEPSEEK_API_KEY 未设置");
  process.exit(1);
}

// ===== DeepSeek 调用 =====
async function callDeepSeek(messages) {
  const res = await axios.post(
    "https://api.deepseek.com/v1/chat/completions",
    {
      model: "deepseek-chat",
      messages,
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

// ===== 初始化 Genkit =====
const ai = genkit();

// ===== 定义 Flow（核心）=====
const analyzeFlow = ai.defineFlow(
  {
    name: "analyzeFlow",
    inputSchema: z.object({
      query: z.string(),
    }),
    outputSchema: z.string(),
  },
  async ({ query }) => {
    const messages = [
      {
        role: "system",
        content: "你是材料行业专家，擅长分析玻璃纤维、FRP、复合材料。",
      },
      {
        role: "user",
        content: `
请分析以下问题：

${query}

请按格式输出：
【结论】
【原因】
【建议】
`,
      },
    ];

    const result = await callDeepSeek(messages);

    return result;
  }
);

// ===== API =====
app.post("/ai", async (req, res) => {
  try {
    const { query } = req.body;

    const result = await analyzeFlow({ query });

    res.json({ result });
  } catch (e) {
    console.error("❌ AI error:", e.response?.data || e.message);
    res.status(500).json({ error: "AI调用失败" });
  }
});

console.log("✅ Genkit + DeepSeek server initialized");
console.log("API_KEY:", API_KEY);
// ===== 启动 =====
app.listen(3000, () => {
  console.log("✅ Genkit + DeepSeek server: http://localhost:3000");
});